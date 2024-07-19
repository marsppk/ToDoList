//
//  NetworkingItem.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 17.07.2024.
//

import Foundation

struct NetworkingItem: Codable {
    let status: String
    let element: NetworkingElement
    let revision: Int?
    init(status: String = "ok", element: NetworkingElement, revision: Int? = nil) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}
