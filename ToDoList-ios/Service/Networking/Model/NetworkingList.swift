//
//  NetworkingList.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 17.07.2024.
//

import Foundation

struct NetworkingList: Codable {
    let status: String
    let list: [NetworkingElement]
    let revision: Int?
    init(status: String = "ok", list: [NetworkingElement], revision: Int? = nil) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}
