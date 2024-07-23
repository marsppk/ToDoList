//
//  FileCache + SwiftData.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.07.2024.
//

import Foundation
import SwiftData
import CocoaLumberjackSwift

protocol StorableInSwiftData {
    @MainActor func insert(_ todoItem: TodoItem)
    @MainActor func fetch() -> [TodoItem]
    @MainActor func delete(_ todoItem: TodoItem)
    @MainActor func update(_ todoItem: TodoItem)
    @MainActor func fetchSorted(sortType: SortType, filterType: FilterType) -> [TodoItem]
}

extension FileCache: StorableInSwiftData {
    @MainActor
    func insert(_ todoItem: TodoItem) {
        modelContainer.mainContext.insert(todoItem)
    }
    @MainActor
    func fetch() -> [TodoItem] {
        let fetchDescriptor = FetchDescriptor<TodoItem>()
        do {
            defer {
                DDLogInfo("\(#function): the items have been loaded from SwiffData successfully")
            }
            return try modelContainer.mainContext.fetch(fetchDescriptor)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            return []
        }
    }
    @MainActor
    func delete(_ todoItem: TodoItem) {
        modelContainer.mainContext.delete(todoItem)
        DDLogInfo("\(#function): the item has been deleted from SwiffData successfully")
    }
    @MainActor
    func update(_ todoItem: TodoItem) {
        let item = get(todoItem.id)
        guard let item = item else { return }
        delete(item)
        insert(todoItem)
        DDLogInfo("\(#function): the item has been updated in SwiffData successfully")
    }
    @MainActor
    func get(_ id: UUID) -> TodoItem? {
        let predicate = #Predicate<TodoItem> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let item = try modelContainer.mainContext.fetch(descriptor)
            DDLogInfo("\(#function): the item has been fetched from SwiffData successfully")
            return item[0]
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            return nil
        }
    }
    @MainActor
    func fetchSorted(sortType: SortType, filterType: FilterType) -> [TodoItem] {
        let predicate = getPredicate(filterType: filterType)
        let sortDescriptors = getSortDescriptors(sortType: sortType)
        let fetchDescriptor = FetchDescriptor<TodoItem>(predicate: predicate, sortBy: sortDescriptors)
        do {
            defer {
                DDLogInfo("\(#function): the sorted items have been loaded from SwiffData successfully")
            }
            return try modelContainer.mainContext.fetch(fetchDescriptor)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            return []
        }
    }
    private func getPredicate(filterType: FilterType) -> Predicate<TodoItem>? {
        switch filterType {
        case .hide:
            return #Predicate { item in
                item.isDone == false
            }
        case .show:
            return nil
        }
    }
    private func getSortDescriptors(sortType: SortType) -> [SortDescriptor<TodoItem>] {
        switch sortType {
        case .date:
            return [SortDescriptor(\.createdAt)]
        case .significance:
            return [SortDescriptor(\.importance, order: .reverse), SortDescriptor(\.createdAt)]
        }
    }
}
