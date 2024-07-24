//
//  FileCache + SQLite.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 24.07.2024.
//

import Foundation
import SQLite
import CocoaLumberjackSwift

protocol StorableInSQLite {
    @MainActor func insertInSQL(_ todoItem: TodoItem)
    @MainActor func fetchFromSQL() -> [TodoItem]
    @MainActor func deleteFromSQL(_ todoItem: TodoItem)
    @MainActor func updateInSQL(_ todoItem: TodoItem)
}

extension FileCache: StorableInSQLite {
    func createTable(ifNotExists: Bool) {
        do {
            defer {
                DDLogInfo("\(#function): the table for SQLite have been created successfully")
            }
            guard let connection = dbConnection else {
                throw SQLiteErrors.connectionError
            }
            let createTableQuery = Constants.SQLite.todoListTable.create(ifNotExists: ifNotExists) { table in
                table.column(Constants.SQLite.idExpression, primaryKey: true)
                table.column(Constants.SQLite.textExpression)
                table.column(Constants.SQLite.importanceExpression)
                table.column(Constants.SQLite.deadlineExpression)
                table.column(Constants.SQLite.isDoneExpression)
                table.column(Constants.SQLite.createdAtExpression)
                table.column(Constants.SQLite.changedAtExpression)
                table.column(Constants.SQLite.textColorExpression)
                table.column(Constants.SQLite.categoryNameExpression)
                table.column(Constants.SQLite.categoryColorExpression)
            }
            try connection.run(createTableQuery)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
        }
    }
    func insertInSQL(_ todoItem: TodoItem) {
        do {
            defer {
                DDLogInfo("\(#function): the item have been inserted in SQLite successfully")
            }
            guard let connection = dbConnection else {
                throw SQLiteErrors.connectionError
            }
            let insertRequest = Constants.SQLite.todoListTable.insert(
                or: .replace,
                Constants.SQLite.idExpression <- todoItem.id,
                Constants.SQLite.textExpression <- todoItem.text,
                Constants.SQLite.importanceExpression <- todoItem.importance,
                Constants.SQLite.deadlineExpression <- todoItem.deadline,
                Constants.SQLite.isDoneExpression <- todoItem.isDone,
                Constants.SQLite.createdAtExpression <- todoItem.createdAt,
                Constants.SQLite.changedAtExpression <- todoItem.changedAt,
                Constants.SQLite.textColorExpression <- todoItem.color,
                Constants.SQLite.categoryNameExpression <- todoItem.category.name,
                Constants.SQLite.categoryColorExpression <- todoItem.category.color
            )
            try connection.run(insertRequest)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
        }
    }
    func fetchFromSQL() -> [TodoItem] {
        do {
            defer {
                DDLogInfo("\(#function): the items have been loaded from SQLite successfully")
            }
            guard let connection = dbConnection else {
                throw SQLiteErrors.connectionError
            }
            var newTodoItems: [TodoItem] = []
            for todoRow in try connection.prepare(Constants.SQLite.todoListTable) {
                let todoItem = mapTodoItem(from: todoRow)
                newTodoItems.append(todoItem)
            }
            return newTodoItems
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            return []
        }
    }
    func deleteFromSQL(_ todoItem: TodoItem) {
        do {
            defer {
                DDLogInfo("\(#function): the item have been deleted from SQLite successfully")
            }
            guard let connection = dbConnection else {
                throw SQLiteErrors.connectionError
            }
            let existingTodoItem = Constants.SQLite.todoListTable.filter(Constants.SQLite.idExpression == todoItem.id)
            let deleteRequest = existingTodoItem.delete()
            try connection.run(deleteRequest)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
        }
    }
    func updateInSQL(_ todoItem: TodoItem) {
        do {
            defer {
                DDLogInfo("\(#function): the item have been updated in SQLite successfully")
            }
            guard let connection = dbConnection else {
                throw SQLiteErrors.connectionError
            }
            let existingTodoItem = Constants.SQLite.todoListTable.filter(Constants.SQLite.idExpression == todoItem.id)
            let updateRequest = existingTodoItem.update(
                Constants.SQLite.textExpression <- todoItem.text,
                Constants.SQLite.importanceExpression <- todoItem.importance,
                Constants.SQLite.deadlineExpression <- todoItem.deadline,
                Constants.SQLite.isDoneExpression <- todoItem.isDone,
                Constants.SQLite.createdAtExpression <- todoItem.createdAt,
                Constants.SQLite.changedAtExpression <- todoItem.changedAt,
                Constants.SQLite.textColorExpression <- todoItem.color,
                Constants.SQLite.categoryNameExpression <- todoItem.category.name,
                Constants.SQLite.categoryColorExpression <- todoItem.category.color
            )
            if try connection.run(updateRequest) <= 0 {
                throw SQLiteErrors.notFound
            }
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
        }
    }
    func getFromSQL(_ id: UUID) -> TodoItem? {
        do {
            defer {
                DDLogInfo("\(#function): the item have been loaded from SQLite successfully")
            }
            guard let connection = dbConnection else {
                throw SQLiteErrors.connectionError
            }
            let existingTodoItem = Constants.SQLite.todoListTable.filter(Constants.SQLite.idExpression == id)
            var list: [TodoItem] = []
            for todoRow in try connection.prepare(existingTodoItem) {
                let todoItem = mapTodoItem(from: todoRow)
                list.append(todoItem)
            }
            if list.count == 0 {
                throw SQLiteErrors.notFound
            }
            return list[0]
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            return nil
        }
    }
    private func mapTodoItem(from row: Row) -> TodoItem {
        return TodoItem(
            id: row[Constants.SQLite.idExpression],
            text: row[Constants.SQLite.textExpression],
            importance: row[Constants.SQLite.importanceExpression],
            deadline: row[Constants.SQLite.deadlineExpression],
            isDone: row[Constants.SQLite.isDoneExpression],
            createdAt: row[Constants.SQLite.createdAtExpression],
            changedAt: row[Constants.SQLite.changedAtExpression],
            color: row[Constants.SQLite.textColorExpression],
            category: Category(
                name: row[Constants.SQLite.categoryNameExpression],
                color: row[Constants.SQLite.categoryColorExpression]
            )
        )
    }
}

enum SQLiteErrors: Error {
    case connectionError
    case notFound
}
