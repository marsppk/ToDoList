//
//  MockTodoItems.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 11.07.2024.
//

import Foundation

@MainActor
class MockTodoItems {
    static let itemWithAllProperties = TodoItem(
        text: "5",
        importance: Importance.important.rawValue,
        deadline: Date(),
        isDone: false,
        changedAt: Date(),
        color: "#FFFFFF",
        category: Category(
            name: "Учеба",
            color: "#5F82FF"
        )
    )
    static let itemWithoutDeadline = TodoItem(
        text: "5",
        importance: Importance.important.rawValue,
        isDone: false,
        changedAt: Date(),
        color: "#FFFFFF",
        category: Category(
            name: "Учеба",
            color: "#5F82FF"
        )
    )
    static let itemWithoutColor = TodoItem(
        text: "5",
        importance: Importance.important.rawValue,
        deadline: Date(),
        isDone: false,
        changedAt: Date(),
        category: Category(
            name: "Учеба",
            color: "#5F82FF"
        )
    )
    static let itemWithoutCategoryColor = TodoItem(
        text: "5",
        importance: Importance.important.rawValue,
        deadline: Date(),
        isDone: false,
        changedAt: Date(),
        color: "#FFFFFF",
        category: Category(
            name: "Без категории",
            color: nil
        )
    )
    static let itemWithoutChangedAt = TodoItem(
        text: "5",
        importance: Importance.important.rawValue,
        deadline: Date(),
        isDone: false,
        color: "#FFFFFF",
        category: Category(
            name: "Учеба",
            color: "#5F82FF"
        )
    )
    static let itemWithBasicImportance = TodoItem(
        text: "5",
        importance: Importance.basic.rawValue,
        deadline: Date(),
        isDone: false,
        changedAt: Date(),
        color: "#FFFFFF",
        category: Category(
            name: "Учеба",
            color: "#5F82FF"
        )
    )
}
