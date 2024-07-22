//
//  StorageLogic + SwiftData.swift
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
            fileCache.delete(item)
        }
        loadItemsFromSwiftData()
    }
    @MainActor
    func loadItemsFromSwiftData() {
        fileCache.removeAllItems()
        let items = fileCache.fetch()
        for item in items {
            fileCache.addNewItem(item: item)
        }
        isUpdated = true
    }
    @MainActor
    func insertItemInSwiftData(item: TodoItem) {
        fileCache.insert(item)
        loadItemsFromSwiftData()
    }
    @MainActor
    func deleteItemInSwiftData(item: TodoItem) {
        fileCache.delete(item)
        loadItemsFromSwiftData()
    }
    @MainActor
    func updateItemInSwiftData(item: TodoItem) {
        fileCache.update(item)
        loadItemsFromSwiftData()
    }
    @MainActor
    func updateItemInSwiftDataAfterLoading(item: TodoItem) {
        guard let oldItem = fileCache.get(item.id) else { return fileCache.update(item) }
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
