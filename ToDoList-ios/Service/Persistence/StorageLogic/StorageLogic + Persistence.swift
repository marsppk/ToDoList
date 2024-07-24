//
//  StorageLogic + Persistence.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.07.2024.
//

import Foundation

extension StorageLogic {
    @MainActor
    func deleteAllItemsThatNotInBackend(items: [TodoItem]) {
        let ids = items.compactMap({ $0.id })
        for item in fileCache.todoItems.values where !ids.contains(item.id) {
            switch fileCache.type {
            case .SQLite:
                fileCache.deleteFromSQL(item)
            case .swiftData:
                fileCache.delete(item)
            }
        }
        loadItemsFromPersistence()
    }
    @MainActor
    func loadItemsFromPersistence() {
        fileCache.removeAllItems()
        let items = fileCache.type == .swiftData ? fileCache.fetch() : fileCache.fetchFromSQL()
        for item in items {
            fileCache.addNewItem(item: item)
        }
        isUpdated = true
    }
    @MainActor
    func insertItemInPersistence(item: TodoItem) {
        switch fileCache.type {
        case .SQLite:
            fileCache.insertInSQL(item)
        case .swiftData:
            fileCache.insert(item)
        }
        loadItemsFromPersistence()
    }
    @MainActor
    func deleteItemInPersistence(item: TodoItem) {
        switch fileCache.type {
        case .SQLite:
            fileCache.deleteFromSQL(item)
        case .swiftData:
            fileCache.delete(item)
        }
        loadItemsFromPersistence()
    }
    @MainActor
    func updateItemInPersistence(item: TodoItem) {
        switch fileCache.type {
        case .SQLite:
            fileCache.updateInSQL(item)
        case .swiftData:
            fileCache.update(item)
        }
        loadItemsFromPersistence()
    }
    @MainActor
    func loadSortedItemsFromPersistence(sortType: SortType, filterType: FilterType) -> [TodoItem] {
        switch fileCache.type {
        case .SQLite:
            switch (sortType, filterType) {
            case (SortType.date, FilterType.hide):
                let sortedItems = fileCache.todoItems.values.filter({ $0.isDone == false })
                return sortedItems.sorted(by: {$0.createdAt < $1.createdAt})
            case (SortType.date, FilterType.show):
                let sortedItems = fileCache.todoItems.values
                return sortedItems.sorted(by: {$0.createdAt < $1.createdAt})
            case (SortType.significance, FilterType.hide):
                let sortedItems = fileCache.todoItems.values.filter({ $0.isDone == false })
                return sortedItems.sorted(by: {$0.importance > $1.importance})
            case (SortType.significance, FilterType.show):
                let sortedItems = fileCache.todoItems.values
                return sortedItems.sorted(by: {$0.importance > $1.importance})
            }
        case .swiftData:
            return fileCache.fetchSorted(sortType: sortType, filterType: filterType)
        }
    }
    @MainActor
    func updateItemInPersistenceAfterLoading(item: TodoItem) {
        switch fileCache.type {
        case .SQLite:
            guard let oldItem = fileCache.getFromSQL(item.id) else { return fileCache.insertInSQL(item) }
            fileCache.updateInSQL(
                 TodoItem(
                    id: item.id,
                    text: item.text,
                    importance: item.importance,
                    deadline: item.deadline,
                    isDone: item.isDone,
                    createdAt: item.createdAt,
                    changedAt: item.changedAt,
                    color: item.color,
                    category: oldItem.category
                )
            )
        case .swiftData:
            guard let oldItem = fileCache.get(item.id) else { return fileCache.insert(item) }
            fileCache.update(
                 TodoItem(
                    id: item.id,
                    text: item.text,
                    importance: item.importance,
                    deadline: item.deadline,
                    isDone: item.isDone,
                    createdAt: item.createdAt,
                    changedAt: item.changedAt,
                    color: item.color,
                    category: oldItem.category
                )
            )
        }
    }
}
