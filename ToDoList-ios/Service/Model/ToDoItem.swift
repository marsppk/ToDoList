//
//  TodoItem.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 15.06.2024.
//

import Foundation
import SwiftData

@Model
class TodoItem {
    enum CodingKeys: String, CaseIterable {
        case id
        case text
        case importance
        case deadline
        case isDone = "is_done"
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case color
        case categoryName = "category_name"
        case categoryColor = "category_color"
    }
    @Attribute(.unique) let id: UUID
    let text: String
    let importance: Importance.RawValue
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let changedAt: Date?
    let color: String?
    let category: Category
    init(
        id: UUID = UUID(),
        text: String,
        importance: Importance.RawValue,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        changedAt: Date? = nil,
        color: String? = nil,
        category: Category = Category(name: "Без категории", color: nil)
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.color = color
        self.category = category
    }
}

// MARK: - JSON

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard
            let dictionary = json as? [String: Any],
            let id = (dictionary[CodingKeys.id.rawValue] as? String).map(UUID.init(uuidString:)) ?? nil,
            let text = dictionary[CodingKeys.text.rawValue] as? String,
            let isDone = dictionary[CodingKeys.isDone.rawValue] as? Bool,
            let createdAt = (dictionary[CodingKeys.createdAt.rawValue] as? TimeInterval)
                .map(Date.init(timeIntervalSince1970:)),
            let categoryName = dictionary[CodingKeys.categoryName.rawValue] as? String
        else { return nil }
        var importance = Importance.basic.rawValue
        if let importanceValue = dictionary[CodingKeys.importance.rawValue] as? Int {
            importance = Importance(rawValue: importanceValue)?.rawValue ?? Importance.basic.rawValue
        }
        let deadline = (dictionary[CodingKeys.deadline.rawValue] as? TimeInterval)
            .map { interval in Date(timeIntervalSince1970: interval) }
        let changedAt = (dictionary[CodingKeys.changedAt.rawValue] as? TimeInterval)
            .map { interval in Date(timeIntervalSince1970: interval) }
        let color = dictionary[CodingKeys.color.rawValue] as? String
        let categoryColor = dictionary[CodingKeys.categoryColor.rawValue] as? String
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changedAt: changedAt,
            color: color,
            category: Category(
                name: categoryName,
                color: categoryColor
            )
        )
    }
    var json: Any {
        var dataDict: [String: Any] = [:]
        dataDict[CodingKeys.id.rawValue] = id.uuidString
        dataDict[CodingKeys.text.rawValue] = text
        if importance != Importance.basic.rawValue {
            dataDict[CodingKeys.importance.rawValue] = importance
        }
        if let deadline = deadline {
            dataDict[CodingKeys.deadline.rawValue] = deadline.timeIntervalSince1970
        }
        dataDict[CodingKeys.isDone.rawValue] = isDone
        dataDict[CodingKeys.createdAt.rawValue] = createdAt.timeIntervalSince1970
        if let changedAt = changedAt {
            dataDict[CodingKeys.changedAt.rawValue] = changedAt.timeIntervalSince1970
        }
        if let color = color {
            dataDict[CodingKeys.color.rawValue] = color
        }
        dataDict[CodingKeys.categoryName.rawValue] = category.name
        if let categoryColor = category.color {
            dataDict[CodingKeys.categoryColor.rawValue] = categoryColor
        }
        return dataDict
    }
}

// MARK: - CSV

extension TodoItem {
    static let csvColumnsDelimiter = ";"
    static let csvRowsDelimiter = "\r"
    static func parse(csv: Any) -> TodoItem? {
        guard let csv = csv as? String else { return nil }
        let columnsData = csv.components(separatedBy: TodoItem.csvColumnsDelimiter)
        guard
            columnsData.count == 10,
            let id = UUID(uuidString: columnsData[0]),
            let isDone = Bool(columnsData[4]),
            let createdAtInterval = TimeInterval(columnsData[5])
        else { return nil }
        let text = columnsData[1]
        let importanceString = columnsData[2].isEmpty ? "" : columnsData[2]
        var importance = Importance.basic
        if let intValue = Int(importanceString) {
            importance = Importance(rawValue: intValue) ?? Importance.basic
        }
        let importanceRawValue = importance.rawValue
        let createdAt = Date(timeIntervalSince1970: createdAtInterval)
        let deadline = TimeInterval(columnsData[3])
            .map { interval in Date(timeIntervalSince1970: interval) }
        let changedAt = TimeInterval(columnsData[6])
            .map { interval in Date(timeIntervalSince1970: interval) }
        let color = columnsData[7].isEmpty ? nil : columnsData[7]
        let categoryName = columnsData[8]
        let categoryColor = columnsData[9].isEmpty ? nil : columnsData[9]
        return TodoItem(
            id: id,
            text: text,
            importance: importanceRawValue,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changedAt: changedAt,
            color: color,
            category: Category(
                name: categoryName,
                color: categoryColor
            )
        )
    }
    static var csvTitles: Any {
        var titles: [String] = []
        for cases in CodingKeys.allCases {
            titles.append(cases.rawValue)
        }
        return titles.joined(separator: TodoItem.csvColumnsDelimiter)
    }
    var csv: Any {
        var dataArray: [String] = []
        dataArray.append(id.uuidString)
        dataArray.append(text)
        dataArray.append(importance != Importance.basic.rawValue ? String(importance) : "")
        dataArray.append(deadline?.timeIntervalSince1970.description ?? "")
        dataArray.append(isDone.description)
        dataArray.append(createdAt.timeIntervalSince1970.description)
        dataArray.append(changedAt?.timeIntervalSince1970.description ?? "")
        dataArray.append(color ?? "")
        dataArray.append(category.name)
        dataArray.append(category.color ?? "")
        return dataArray.joined(separator: TodoItem.csvColumnsDelimiter)
    }
}

// MARK: - Hashable

extension TodoItem: Hashable { }

// MARK: - Identifiable

extension TodoItem: Identifiable { }
