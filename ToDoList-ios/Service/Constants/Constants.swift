//
//  Constants.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 13.07.2024.
//

import Foundation
import SQLite

struct Constants {
    static let key: String = "token"
    static let httpStatusCodeSuccess = 200..<300
    struct SQLite {
        static let file = "ToDoListDB.sqlite3"
        static let todoListTable = Table("TodoList")
        static let idExpression = Expression<UUID>(TodoItem.CodingKeys.id.rawValue)
        static let textExpression = Expression<String>(TodoItem.CodingKeys.text.rawValue)
        static let importanceExpression = Expression<Int>(TodoItem.CodingKeys.importance.rawValue)
        static let deadlineExpression = Expression<Date?>(TodoItem.CodingKeys.deadline.rawValue)
        static let isDoneExpression = Expression<Bool>(TodoItem.CodingKeys.isDone.rawValue)
        static let createdAtExpression = Expression<Date>(TodoItem.CodingKeys.createdAt.rawValue)
        static let changedAtExpression = Expression<Date?>(TodoItem.CodingKeys.changedAt.rawValue)
        static let textColorExpression = Expression<String?>(TodoItem.CodingKeys.color.rawValue)
        static let categoryNameExpression = Expression<String>(TodoItem.CodingKeys.categoryName.rawValue)
        static let categoryColorExpression = Expression<String?>(TodoItem.CodingKeys.categoryColor.rawValue)
    }
}
