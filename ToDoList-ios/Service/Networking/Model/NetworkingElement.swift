//
//  NetworkingElement.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 17.07.2024.
//

import Foundation

struct NetworkingElement: Codable {
    let id: String
    let text: String
    let importance: String
    let deadline: Int?
    let isDone: Bool
    let color: String?
    let createdAt: Int
    let changedAt: Int
    let lastUpdatedBy: String
    let files: [String]?
    private enum CodingKeys: String, CodingKey {
        case id
        case text
        case importance
        case deadline
        case isDone = "done"
        case color
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
        case files
    }
}
