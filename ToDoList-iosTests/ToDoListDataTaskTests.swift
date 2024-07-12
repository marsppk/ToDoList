//
//  ToDoListDataTaskTests.swift
//  ToDoList-iosTests
//
//  Created by Maria Slepneva on 07.07.2024.
//

import XCTest
@testable import ToDoList_ios

final class ToDoListDataTaskTests: XCTestCase {
    let httpStatusCodeSuccess = 200..<300
    let baseURL = "https://baldezh.top/uploads/posts/2023-12"
    let imageName = "/1703023305_baldezh-top-p-goluboe-ozero-shveitsariya-pinterest-69.jpg"
    func testCustomDataForFunc() async throws {
        guard let url = URL(string: baseURL + imageName) else { return }
        let request = URLRequest(url: url)
        let (ans, response) = try await URLSession.shared.dataTask(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkingErrors.unexpectedResponse(response)
        }
        guard self.httpStatusCodeSuccess.contains(response.statusCode) else {
            throw NetworkingErrors.failedResponse(response)
        }
        XCTAssertNotNil(ans)
    }
    func testCustomDataForFuncWithCancel() async throws {
        guard let url = URL(string: baseURL + imageName) else { return }
        let request = URLRequest(url: url)
        let task = Task {
            try await URLSession.shared.dataTask(for: request)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            task.cancel()
        }
        do {
            _ = try await task.value
        } catch {
            XCTAssertEqual(error.localizedDescription, "cancelled")
        }
    }
}

enum NetworkingErrors: Error {
    case unexpectedResponse(URLResponse)
    case failedResponse(HTTPURLResponse)
}
