//
//  DefaultNetworkingService.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 13.07.2024.
//

import Foundation

class DefaultNetworkingService: NetworkingService, ObservableObject, @unchecked Sendable {
    @Published var numberOfTasks = 0
    @Published var alertData: AlertData?
    @Published var isShownAlertWithNoConnection = false
    private let baseURL = "https://hive.mrdekk.ru/todo"
    private let token: String
    private var revision = 0
    private let deviceID: String
    init(token: String, deviceID: String) {
        self.token = token
        self.deviceID = deviceID
    }
    func getTodoList() async throws -> [TodoItem] {
        let request = try makeGetRequest(for: "/list")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(NetworkingList.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return response.list.compactMap(makeTodoItem(from:))
    }
    func getTodoItem(id: String) async throws -> TodoItem? {
        let request = try makeGetRequest(for: "/list/\(id)")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(NetworkingItem.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return makeTodoItem(from: response.element)
    }
    func updateTodoList(todoList: [TodoItem]) async throws -> [TodoItem] {
        let networkingList = NetworkingList(list: todoList.map(makeElement(from:)))
        let encodedData = try JSONEncoder().encode(networkingList)
        let request = try makePatchRequest(for: "/list", data: encodedData)
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(NetworkingList.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return response.list.compactMap(makeTodoItem(from:))
    }
    @discardableResult
    func deleteTodoItem(id: String) async throws -> TodoItem? {
        let request = try makeDeleteRequest(for: "/list/\(id)")
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(NetworkingItem.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return makeTodoItem(from: response.element)
    }
    @discardableResult
    func updateTodoItem(item: TodoItem) async throws -> TodoItem? {
        let networkingItem = NetworkingItem(element: makeElement(from: item))
        let encodedData = try JSONEncoder().encode(networkingItem)
        let request = try makePutRequest(for: "/list/\(item.id.uuidString)", data: encodedData)
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(NetworkingItem.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return makeTodoItem(from: response.element)
    }
    @discardableResult
    func addTodoItem(item: TodoItem) async throws -> TodoItem? {
        let networkingItem = NetworkingItem(element: makeElement(from: item))
        let encodedData = try JSONEncoder().encode(networkingItem)
        let request = try makePostRequest(for: "/list", data: encodedData)
        let (data, _) = try await performRequest(request)
        let response = try JSONDecoder().decode(NetworkingItem.self, from: data)
        if let revision = response.revision {
            self.revision = revision
        }
        return makeTodoItem(from: response.element)
    }
    private func makeURL(for path: String) throws -> URL {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkingErrors.incorrectURL(baseURL + path)
        }
        return url
    }
    private func makeGetRequest(for path: String) throws -> URLRequest {
        let url = try makeURL(for: path)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    private func makeDeleteRequest(for path: String) throws -> URLRequest {
        let url = try makeURL(for: path)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        return request
    }
    private func makePutRequest(for path: String, data: Data) throws -> URLRequest {
        let url = try makeURL(for: path)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = data
        return request
    }
    private func makePostRequest(for path: String, data: Data) throws -> URLRequest {
        let url = try makeURL(for: path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = data
        return request
    }
    private func makePatchRequest(for path: String, data: Data) throws -> URLRequest {
        let url = try makeURL(for: path)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        request.httpBody = data
        return request
    }
    private func performRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        guard Reachability.isConnectedToNetwork() else { 
            throw NetworkingErrors.noConnection
        }
        let (ans, response) = try await URLSession.shared.dataTask(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkingErrors.unexpectedResponse(response)
        }
        try checkStatusCode(response: response)
        return (ans, response)
    }
    private func checkStatusCode(response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200..<300:
            return
        case 400:
            throw NetworkingErrors.badRequest
        case 401:
            throw NetworkingErrors.authError
        case 404:
            throw NetworkingErrors.notFound
        case 500..<600:
            throw NetworkingErrors.serverError
        default:
            throw NetworkingErrors.unexpectedStatusCode(response.statusCode)
        }
    }
    private func makeTodoItem(from element: NetworkingElement) -> TodoItem? {
        guard
            let id = UUID(uuidString: element.id),
            let importance = Importance.calculateImportance(string: element.importance)
        else {
            return nil
        }
        let createdAt = Date(timeIntervalSince1970: TimeInterval(element.createdAt))
        let deadline = element.deadline.map { Date(timeIntervalSince1970: TimeInterval($0)) }
        let changedAt = Date(timeIntervalSince1970: TimeInterval(element.changedAt))
        return TodoItem(
            id: id,
            text: element.text,
            importance: importance,
            deadline: deadline,
            isDone: element.isDone,
            createdAt: createdAt,
            changedAt: changedAt,
            color: element.color
        )
    }
    private func makeElement(from todoItem: TodoItem) -> NetworkingElement {
        return NetworkingElement(
            id: todoItem.id.uuidString,
            text: todoItem.text,
            importance: Importance(rawValue: todoItem.importance)!.title,
            deadline: todoItem.deadline.map({ Int($0.timeIntervalSince1970) }),
            isDone: todoItem.isDone,
            color: todoItem.color,
            createdAt: Int(todoItem.createdAt.timeIntervalSince1970),
            changedAt: Int((todoItem.changedAt ?? todoItem.createdAt).timeIntervalSince1970),
            lastUpdatedBy: deviceID,
            files: nil
        )
    }
}

extension DefaultNetworkingService: Countable {
    @MainActor
    func incrementNumberOfTasks() {
        numberOfTasks += 1
    }
    @MainActor
    func decrementNumberOfTasks() {
        numberOfTasks -= 1
    }
}
