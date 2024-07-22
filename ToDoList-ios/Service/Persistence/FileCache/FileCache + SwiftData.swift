//
//  FileCache + SwiftData.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.07.2024.
//

import Foundation
import SwiftData
import CocoaLumberjackSwift

extension FileCache {
    @MainActor
    func insert(_ todoItem: TodoItem) {
        modelContainer.mainContext.insert(todoItem)
    }
    @MainActor
    func fetch() -> [TodoItem] {
        let fetchDescriptor = FetchDescriptor<TodoItem>()
        do {
            return try modelContainer.mainContext.fetch(fetchDescriptor)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            return []
        }
    }
    @MainActor
    func delete(_ todoItem: TodoItem) {
        modelContainer.mainContext.delete(todoItem)
    }
    @MainActor
    func update(_ todoItem: TodoItem) {
        let item = get(todoItem.id)
        guard let item = item else { return }
        delete(item)
        insert(todoItem)
    }
    @MainActor
    func get(_ id: UUID) -> TodoItem? {
        let predicate = #Predicate<TodoItem> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            let item = try modelContainer.mainContext.fetch(descriptor)
            return item[0]
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            return nil
        }
    }
}
