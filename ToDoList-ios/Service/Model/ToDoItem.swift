//
//  ToDoItem.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 15.06.2024.
//

import Foundation

struct TodoItem {
    enum CodingKeys: String, CaseIterable {
        case id
        case text
        case importance
        case deadline
        case isDone = "is_done"
        case createdAt = "created_at"
        case changedAt = "changed_at"
    }
    
    let id: UUID
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let changedAt: Date?
    
    init(
        id: UUID = UUID(),
        text: String,
        importance: Importance,
        deadline: Date? = nil,
        isDone: Bool = false,
        createdAt: Date = Date(),
        changedAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
}

// MARK: - JSON

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard
            let dictionary = json as? [String:Any],
            let id = (dictionary[CodingKeys.id.rawValue] as? String).map(UUID.init(uuidString:)) ?? nil,
            let text = dictionary[CodingKeys.text.rawValue] as? String,
            let importance = (dictionary[CodingKeys.importance.rawValue] as? String).map(Importance.init(rawValue:)) ?? .usual,
            let isDone = dictionary[CodingKeys.isDone.rawValue] as? Bool,
            let createdAt = (dictionary[CodingKeys.createdAt.rawValue] as? TimeInterval)
                .map(Date.init(timeIntervalSince1970:))
        else { return nil }
        let deadline = (dictionary[CodingKeys.deadline.rawValue] as? TimeInterval)
            .map { interval in Date(timeIntervalSince1970: interval) }
        let changedAt = (dictionary[CodingKeys.changedAt.rawValue] as? TimeInterval)
            .map { interval in Date(timeIntervalSince1970: interval) }
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changedAt: changedAt
        )
    }
    
    var json: Any {
        var dataDict: [String: Any] = [:]
        dataDict[CodingKeys.id.rawValue] = id.uuidString
        dataDict[CodingKeys.text.rawValue] = text
        if importance != .usual {
            dataDict[CodingKeys.importance.rawValue] = importance.rawValue
        }
        if let deadline = deadline {
            dataDict[CodingKeys.deadline.rawValue] = deadline.timeIntervalSince1970
        }
        dataDict[CodingKeys.isDone.rawValue] = isDone
        dataDict[CodingKeys.createdAt.rawValue] = createdAt.timeIntervalSince1970
        if let changedAt = changedAt {
            dataDict[CodingKeys.changedAt.rawValue] = changedAt.timeIntervalSince1970
        }
        return dataDict
    }
}

// MARK: - CSV

extension TodoItem {
    static let csvColumnsDelimiter = ","
    static let csvRowsDelimiter = "\r"
    
    static func parse(csv: Any) -> TodoItem? {
        guard let csv = csv as? String else { return nil }
        let columnsData = csv.components(separatedBy: TodoItem.csvColumnsDelimiter)
        guard
            columnsData.count == 7,
            let id = UUID(uuidString: columnsData[0]),
            let importance = (columnsData[2].isEmpty ? nil : columnsData[2])
                .map(Importance.init(rawValue:)) ?? .usual,
            let isDone = Bool(columnsData[4]),
            let createdAtInterval = TimeInterval(columnsData[5])
        else { return nil }
        let text = columnsData[1]
        let createdAt = Date(timeIntervalSince1970: createdAtInterval)
        let deadline = TimeInterval(columnsData[3])
            .map { interval in Date(timeIntervalSince1970: interval) }
        let changedAt = TimeInterval(columnsData[6])
            .map { interval in Date(timeIntervalSince1970: interval) }
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            changedAt: changedAt
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
        dataArray.append(importance != .usual ? importance.rawValue : "")
        dataArray.append(deadline?.timeIntervalSince1970.description ?? "")
        dataArray.append(isDone.description)
        dataArray.append(createdAt.timeIntervalSince1970.description)
        dataArray.append(changedAt?.timeIntervalSince1970.description ?? "")
        return dataArray.joined(separator: TodoItem.csvColumnsDelimiter)
    }
}
