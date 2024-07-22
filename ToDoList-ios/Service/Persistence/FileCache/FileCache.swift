//
//  FileCache.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 15.06.2024.
//

import Foundation
import SwiftData
import CocoaLumberjackSwift

class FileCache {
    private(set) var todoItems: [UUID: TodoItem] = [:]
    private(set) var isDirty: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isDirty")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isDirty")
        }
    }
    internal var modelContainer: ModelContainer
    init() {
        do {
            self.modelContainer = try ModelContainer(for: TodoItem.self)
        } catch {
            DDLogError("\(#function): \(error.localizedDescription)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    func updateIsDirtyValue(by newValue: Bool) {
        isDirty = newValue
    }
    func addNewItem(item: TodoItem) {
        todoItems[item.id] = item
    }
    func removeItem(by id: UUID) -> TodoItem? {
        defer {
            todoItems[id] = nil
        }
        return todoItems[id]
    }
    func removeAllItems() {
        todoItems.removeAll()
    }
    func saveJSON(fileName: String) throws {
        let jsonData = todoItems.values.map(\.json)
        let encodedData = try JSONSerialization.data(withJSONObject: jsonData, options: [.prettyPrinted, .sortedKeys])
        try saveToJSONFile(fileName: "\(fileName).json", jsonData: encodedData)
    }
    func saveCSV(fileName: String) throws {
        let csvData = [TodoItem.csvTitles] + todoItems.values.map(\.csv)
        guard let csvData = csvData as? [String] else { return }
        let csvString = csvData.joined(separator: TodoItem.csvRowsDelimiter)
        try saveToCSVFile(fileName: "\(fileName).csv", csvString: csvString)
    }
    func getItemsFromJSON(fileName: String) throws {
        let jsonData = try getFromJSONFile(fileName: "\(fileName).json")
        let decodedData = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let newItems = decodedData as? [[String: Any]] else { return }
        for todoItem in newItems {
            if let item = TodoItem.parse(json: todoItem) {
                addNewItem(item: item)
            }
        }
    }
    func getItemsFromCSV(fileName: String) throws {
        let csvString = try getFromCSVFile(fileName: "\(fileName).csv")
        let items = csvString.split(separator: TodoItem.csvRowsDelimiter)
        for index in 1..<items.count {
            if let item = TodoItem.parse(csv: String(items[index])) {
                addNewItem(item: item)
            }
        }
    }
    private func getDocumentsDirectoryURL() -> URL {
        let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectoryUrl
    }
    private func getURL(for fileName: String) -> URL {
        return getDocumentsDirectoryURL().appendingPathComponent(fileName)
    }
    private func saveToJSONFile(fileName: String, jsonData: Data) throws {
        try jsonData.write(to: getURL(for: fileName))
    }
    private func saveToCSVFile(fileName: String, csvString: String) throws {
        try csvString.write(to: getURL(for: fileName), atomically: true, encoding: .utf8)
    }
    private func getFromCSVFile(fileName: String) throws -> String {
        return try String(contentsOf: getURL(for: fileName), encoding: .utf8)
    }
    private func getFromJSONFile(fileName: String) throws -> Data {
        return try Data(contentsOf: getURL(for: fileName))
    }
}
