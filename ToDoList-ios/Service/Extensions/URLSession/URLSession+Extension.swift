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
        task = dataTask
    }

    func isTaskCancelled() -> Bool {
        isCancelled
    }
}

extension URLSession {
    func dataTask(for request: URLRequest) async throws -> (Data, URLResponse) {
        let taskManager = URLSessionDataTaskManager()
        return try await withTaskCancellationHandler(
            operation: {
                try await withCheckedThrowingContinuation { continuation in
                    Task {
                        let dataTask = self.dataTask(with: request) { data, response, error in
                            if let error = error {
                                continuation.resume(throwing: error)
                            } else if let data = data, let response = response {
                                continuation.resume(returning: (data, response))
                            } else {
                                continuation.resume(throwing: URLError(.unknown))
                            }
                        }
                        await taskManager.set(dataTask)
                        let isCancelled = await taskManager.isTaskCancelled()
                        switch isCancelled {
                        case false:
                            dataTask.resume()
                        case true:
                            continuation.resume(throwing: CancellationError())
                        }
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
