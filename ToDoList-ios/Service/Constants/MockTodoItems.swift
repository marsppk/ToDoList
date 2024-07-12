//
//  MockTodoItems.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 11.07.2024.
//

import Foundation

class MockTodoItems {
    static let itemWithAllProperties = TodoItem(
        text: "5",
        importance: .important,
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
        importance: .important,
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
        importance: .important,
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
        importance: .important,
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
        importance: .important,
        deadline: Date(),
        isDone: false,
        color: "#FFFFFF",
        category: Category(
            name: "Учеба",
            color: "#5F82FF"
        )
    )
    static let itemWithUsualImportance = TodoItem(
        text: "5",
        importance: .usual,
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
