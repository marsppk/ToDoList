//
//  NetworkingErrors.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 18.07.2024.
//

import Foundation

enum NetworkingErrors: Error {
    case incorrectURL(String)
    case unexpectedResponse(URLResponse)
    case badRequest
    case authError
    case notFound
    case serverError
    case unexpectedStatusCode(Int)
}

extension NetworkingErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .incorrectURL(let url):
            return "The url \(url) does not exist"
        case .unexpectedResponse:
            return "Unexpected response from server"
        case .badRequest:
            return "Wrong request or unsynchronized data"
        case .authError:
            return "Wrong authorization"
        case .notFound:
            return "Element not found"
        case .serverError:
            return "Server error"
        case .unexpectedStatusCode(let code):
            return "Unexpected status code: \(code)"
        }
    }
}
