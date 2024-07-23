//
//  Importance.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 15.06.2024.
//

import Foundation

enum Importance: Int, Codable {
    case low
    case basic
    case important
    var title: String {
        switch self {
        case .low:
            return "low"
        case .basic:
            return "basic"
        case .important:
            return "important"
        }
    }
    static func calculateImportance(string: String) -> Importance.RawValue? {
        switch string {
        case "low":
            return Importance.low.rawValue
        case "important":
            return Importance.important.rawValue
        case "basic":
            return Importance.basic.rawValue
        default:
            return nil
        }
    }
}
