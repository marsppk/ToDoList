//
//  URLSession+Extension.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 07.07.2024.
//

import Foundation

actor URLSessionDataTaskManager {
    var task: URLSessionDataTask?
    var isCancelled: Bool = false

    func cancel() {
        isCancelled = true
        task?.cancel()
    }

    func set(_ dataTask: URLSessionDataTask) {
        if isCancelled {
            dataTask.cancel()
        } else {
            task = dataTask
            dataTask.resume()
        }
    }
}

extension URLSession {
    enum Errors: Error {
        case badRequest
    }
    func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
        let taskManager = URLSessionDataTaskManager()
        return try await withTaskCancellationHandler(
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    let dataTask = self.dataTask(with: request) { data, response, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else if let data = data, let response = response {
                            continuation.resume(returning: (data, response))
                        } else {
                            continuation.resume(throwing: Errors.badRequest)
                        }
                    }
                    Task {
                        await taskManager.set(dataTask)
                    }
                }
            },
            onCancel: {
                Task {
                    await taskManager.cancel()
                }
            }
        )
    }
}
