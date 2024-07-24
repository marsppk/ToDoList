//
//  ToDoListJSONTests.swift
//  ToDoList-iosTests
//
//  Created by Maria Slepneva on 15.06.2024.
//

import XCTest
@testable import ToDoList_ios

final class ToDoListJSONTests: XCTestCase {
    enum JSONErrors: Error {
        case jsonParsingIncorrect
        case jsonComputedPropertyIncorrect
    }
    func testCorrectnessOfJSONVariable() throws {
        let todoitem = MockTodoItems.itemWithAllProperties
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw JSONErrors.jsonComputedPropertyIncorrect }
        XCTAssertEqual(jsonData["id"] as? String, todoitem.id.uuidString)
        XCTAssertEqual(jsonData["text"] as? String, todoitem.text)
        XCTAssertEqual(jsonData["importance"] as? Int, todoitem.importance)
        XCTAssertEqual(jsonData["deadline"] as? TimeInterval, todoitem.deadline?.timeIntervalSince1970)
        XCTAssertEqual(jsonData["is_done"] as? Bool, todoitem.isDone)
        XCTAssertEqual(jsonData["created_at"] as? TimeInterval, todoitem.createdAt.timeIntervalSince1970)
        XCTAssertEqual(jsonData["changed_at"] as? TimeInterval, todoitem.changedAt?.timeIntervalSince1970)
        XCTAssertEqual(jsonData["color"] as? String, todoitem.color)
        XCTAssertEqual(jsonData["category_name"] as? String, todoitem.category.name)
        XCTAssertEqual(jsonData["category_color"] as? String, todoitem.category.color)
    }

    func testJSONWithoutDeadline() throws {
        let todoitem = MockTodoItems.itemWithoutDeadline
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw JSONErrors.jsonComputedPropertyIncorrect }
        XCTAssertNil(jsonData["deadline"])
    }
    func testJSONWithoutCategoryColor() throws {
        let todoitem = MockTodoItems.itemWithoutCategoryColor
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw JSONErrors.jsonComputedPropertyIncorrect }
        XCTAssertNil(jsonData["category_color"])
    }
    func testJSONWithoutChangedAt() throws {
        let todoitem = MockTodoItems.itemWithoutChangedAt
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw JSONErrors.jsonComputedPropertyIncorrect }
        XCTAssertNil(jsonData["changed_at"])
    }
    func testJSONWithoutColor() throws {
        let todoitem = MockTodoItems.itemWithoutColor
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw JSONErrors.jsonComputedPropertyIncorrect }
        XCTAssertNil(jsonData["color"])
    }
    func testJSONWithBasicImportance() throws {
        let todoitem = MockTodoItems.itemWithBasicImportance
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw JSONErrors.jsonComputedPropertyIncorrect }
        XCTAssertNil(jsonData["importance"])
    }
    @MainActor func testCorrectnessOfJSONParsing() throws {
        let values: [Any] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertEqual(todoitem.id.uuidString, values[0] as? String)
        XCTAssertEqual(todoitem.text, values[1] as? String)
        XCTAssertEqual(todoitem.importance, Importance.important.rawValue)
        XCTAssertEqual(todoitem.deadline?.timeIntervalSince1970, values[3] as? TimeInterval)
        XCTAssertEqual(todoitem.isDone, values[4] as? Bool)
        XCTAssertEqual(todoitem.createdAt.timeIntervalSince1970, values[5] as? TimeInterval)
        XCTAssertEqual(todoitem.changedAt?.timeIntervalSince1970, values[6] as? TimeInterval)
        XCTAssertEqual(todoitem.color, values[7] as? String)
        XCTAssertEqual(todoitem.category.name, values[8] as? String)
        XCTAssertEqual(todoitem.category.color, values[9] as? String)
    }
    @MainActor func testParcingWithoutImportance() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.importance.rawValue] = nil
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertEqual(todoitem.importance, Importance.basic.rawValue)
    }
    @MainActor func testParcingWithoutColor() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.color.rawValue] = nil
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertEqual(todoitem.color, nil)
    }
    @MainActor func testParcingWithoutCategoryColor() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.categoryColor.rawValue] = nil
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertEqual(todoitem.category.color, nil)
    }
    @MainActor func testParcingWithoutDeadline() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.deadline.rawValue] = nil
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertNil(todoitem.deadline)
    }
    @MainActor func testParcingWithoutChangedAt() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.changedAt.rawValue] = nil
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertNil(todoitem.changedAt)
    }
    func testParcingWithIncorrectData() throws {
        let wrongData: String = "asbsjs"
        let todoitem = TodoItem.parse(json: wrongData)
        XCTAssertNil(todoitem)
    }
    func testParcingWithIncorrectDictionary1() throws {
        var dictionary: [String: Any] = [:]
        dictionary["id"] = UUID().uuidString
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectDictionary2() throws {
        let values: [Any] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary["8"] = 6
        let todoitem = TodoItem.parse(json: dictionary)
        _ = try XCTUnwrap(todoitem)
    }
    @MainActor func testParcingWithEmptyID() throws {
        let values: [Any] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.id.rawValue] = nil
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectIsDoneValue() throws {
        let values: [Any] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.isDone.rawValue] = "false"
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectImportanceValue() throws {
        let values: [Any] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.importance.rawValue] = 3
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertEqual(todoitem.importance, Importance.basic.rawValue)
    }
    @MainActor func testParcingWithIncorrectCreatedAtValue() throws {
        let values: [Any] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.createdAt.rawValue] = "date"
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithEmptyCreatedAtValue() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.createdAt.rawValue] = nil
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithEmptyIsDoneValue() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.isDone.rawValue] = nil
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectDeadlineValue() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.deadline.rawValue] = "/"
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertNil(todoitem.deadline)
    }
    @MainActor func testParcingWithIncorrectChangedAtValue() throws {
        let values: [Any?] = DataForParsing.itemWithAllPropertiesForJSON
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary[TodoItem.CodingKeys.changedAt.rawValue] = ":"
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw JSONErrors.jsonParsingIncorrect }
        XCTAssertNil(todoitem.changedAt)
    }
}
