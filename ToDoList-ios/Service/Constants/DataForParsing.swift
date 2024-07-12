//
//  DataForParsing.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 11.07.2024.
//

import Foundation

@MainActor
class DataForParsing {
    static let itemWithAllProperties = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithoutImportance = [
        UUID().uuidString,
        "5",
        "",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithoutDeadline = [
        UUID().uuidString,
        "5",
        "important",
        "",
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithoutCategoryColor = [
        UUID().uuidString,
        "5",
        "important",
        "",
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Без категории",
        ""
    ]
    static let itemWithoutChangedAt = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        "",
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithoutColor = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithExtraLine = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF",
        "wrong"
    ]
    static let itemWithoutNecessaryProperties = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description
    ]
    static let itemWithoutId = [
        "",
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithIncorrectIsDone = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "52",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithIncorrectImportance = [
        UUID().uuidString,
        "5",
        "cool",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithIncorrectCreatedAt = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        "sdd",
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithoutCreatedAt = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        "",
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithEmptyIsDone = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithIncorrectDeadline = [
        UUID().uuidString,
        "5",
        "important",
        "f",
        "false",
        Date().timeIntervalSince1970.description,
        Date().timeIntervalSince1970.description,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithIncorrectChangedAt = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        "r",
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithCommaInText = [
        UUID().uuidString,
        "5, 3",
        "important",
        Date().timeIntervalSince1970.description,
        "false",
        Date().timeIntervalSince1970.description,
        "r",
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
    static let itemWithAllPropertiesForJSON: [Any] = [
        UUID().uuidString,
        "5",
        "important",
        Date().timeIntervalSince1970,
        false,
        Date().timeIntervalSince1970,
        Date().timeIntervalSince1970,
        "#FFFFFF",
        "Учеба",
        "#5F82FF"
    ]
}
