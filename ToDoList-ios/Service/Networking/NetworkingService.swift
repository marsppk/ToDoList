//
//  NetworkingService.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 13.07.2024.
//

import Foundation

protocol NetworkingService {
    func getTodoList() async throws -> [TodoItem]
    func getTodoItem(id: String) async throws -> TodoItem?
    func updateTodoList(todoList: [TodoItem]) async throws -> [TodoItem]
    @discardableResult func deleteTodoItem(id: String) async throws -> TodoItem?
    @discardableResult func updateTodoItem(item: TodoItem) async throws -> TodoItem?
    @discardableResult func addTodoItem(item: TodoItem) async throws -> TodoItem?
}

protocol Countable {
    var numberOfTasks: Int { get }
    @MainActor func incrementNumberOfTasks()
    @MainActor func decrementNumberOfTasks()
}
