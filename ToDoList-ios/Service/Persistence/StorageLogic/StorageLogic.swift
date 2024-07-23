//
//  StorageLogic.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 30.06.2024.
//

import Foundation
import CocoaLumberjackSwift

final class StorageLogic: ObservableObject {
    @Published var isUpdated = false
    @Published var isShouldSync = false
    var fileCache = FileCache()
    private var categories = [
        Category(name: "Без категории", color: nil),
        Category(name: "Работа", color: "#FB5E5E"),
        Category(name: "Учеба", color: "#5F82FF"),
        Category(name: "Хобби", color: "#8CE555")
    ]
    func createNewItem(
        item: TodoItem?,
        textAndImportance: (String, Int),
        deadline: Date?,
        color: String?,
        category: Category
    ) -> TodoItem {
        updateCategories(category: category)
        let (text, importance) = textAndImportance
        if let item = item {
            defer {
                DDLogInfo("\(#function): Item successfully updated")
            }
            return TodoItem(
                id: item.id,
                text: text,
                importance: importance,
                deadline: deadline,
                isDone: false,
                createdAt: item.createdAt,
                changedAt: Date(),
                color: color,
                category: category
            )
        } else {
            defer {
                DDLogInfo("\(#function): Item successfully created")
            }
            return TodoItem(
                text: text,
                importance: importance,
                deadline: deadline,
                isDone: false,
                createdAt: Date(),
                changedAt: nil,
                color: color,
                category: category
            )
        }
    }
    func updateCategories(category: Category) {
        if !categories.contains(category) {
            categories.append(category)
            decodeCategories()
        }
    }
    func getCategories() -> [Category] {
        if UserDefaults.standard.object(forKey: "categories") == nil {
            decodeCategories()
        } else {
            encodeCategories()
        }
        return categories
    }
    func decodeCategories() {
        do {
            let data = try JSONEncoder().encode(categories)
            UserDefaults.standard.set(data, forKey: "categories")
            DDLogInfo("\(#function): Categories successfully installed")
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
        }
    }
    func encodeCategories() {
        if let data = UserDefaults.standard.data(forKey: "categories") {
            do {
                let loadedCategories = try JSONDecoder().decode([Category].self, from: data)
                categories = loadedCategories
                DDLogInfo("\(#function): Categories successfully loaded")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
            }
        } else {
            DDLogError("\(#function): No categories found in UserDefaults")
        }
    }
    func createItemWithAnotherIsDone(item: TodoItem) -> TodoItem {
        defer {
            DDLogInfo("\(#function): Item successfully created")
        }
        return TodoItem(
            id: item.id,
            text: item.text,
            importance: item.importance,
            deadline: item.deadline,
            isDone: !item.isDone,
            createdAt: item.createdAt,
            changedAt: item.changedAt,
            color: item.color,
            category: item.category
        )
    }
    func updateItem(item: TodoItem) {
        fileCache.addNewItem(item: item)
    }
    @MainActor
    func updateItemAfterLoading(item: TodoItem) {
        guard let oldItem = fileCache.todoItems[item.id] else { return insertItemInSwiftData(item: item) }
        updateItemInSwiftData(
            item: TodoItem(
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
    @discardableResult
    func deleteItem(id: UUID) -> TodoItem? {
        return fileCache.removeItem(by: id)
    }
    func loadItemsFromJSON() throws {
        try fileCache.getItemsFromJSON(fileName: "test1")
    }
    func saveItemsToJSON() {
        Task(priority: .userInitiated) {
            do {
                try fileCache.saveJSON(fileName: "test1")
                DDLogInfo("\(#function): Items successfully saved")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
            }
        }
    }
    func getItems() -> [UUID: TodoItem] {
        return fileCache.todoItems
    }
    func getSections() -> [Date] {
        Set(fileCache.todoItems.values.compactMap({ item in
            guard let deadline = item.deadline else { return nil }
            return deadline.makeEqualDates()
        })).sorted(by: <)
    }
    func getItemsForSection(section: Int) -> [TodoItem] {
        let sections = getSections()
        if section == sections.count {
            return fileCache.todoItems.values.filter({ $0.deadline == nil }).sorted(by: { $0.createdAt < $1.createdAt })
        }
        return fileCache.todoItems.values.filter({
            ($0.deadline != nil) && $0.deadline!.makeEqualDates() == sections[section]
        }).sorted(by: { $0.createdAt < $1.createdAt })
    }
    func checkIsDirty() -> Bool {
        return fileCache.isDirty
    }
    func updateIsDirty(value: Bool) {
        fileCache.updateIsDirtyValue(by: value)
    }
    func getCount() -> Int {
        return fileCache.count
    }
}
