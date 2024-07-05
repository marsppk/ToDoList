//
//  ToDoList_iosJSONTests.swift
//  ToDoList-iosTests
//
//  Created by Maria Slepneva on 15.06.2024.
//

import XCTest
@testable import ToDoList_ios

final class ToDoList_iosJSONTests: XCTestCase {

    func testCorrectnessOfJSONVariable() throws {
        let todoitem = TodoItem(text: "5", importance: .important, deadline: Date(), isDone: false, changedAt: Date(), color: "#FFFFFF", category: Category(name: "Учеба", color: "#5F82FF"))
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw NSError(domain: "Вычислимое свойство JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertEqual(jsonData["id"] as? String, todoitem.id.uuidString)
        XCTAssertEqual(jsonData["text"] as? String, todoitem.text)
        XCTAssertEqual(jsonData["importance"] as? String, todoitem.importance.rawValue)
        XCTAssertEqual(jsonData["deadline"] as? TimeInterval, todoitem.deadline?.timeIntervalSince1970)
        XCTAssertEqual(jsonData["is_done"] as? Bool, todoitem.isDone)
        XCTAssertEqual(jsonData["created_at"] as? TimeInterval, todoitem.createdAt.timeIntervalSince1970)
        XCTAssertEqual(jsonData["changed_at"] as? TimeInterval, todoitem.changedAt?.timeIntervalSince1970)
        XCTAssertEqual(jsonData["color"] as? String, todoitem.color)
        XCTAssertEqual(jsonData["category_name"] as? String, todoitem.category.name)
        XCTAssertEqual(jsonData["category_color"] as? String, todoitem.category.color)
    }

    func testJSONWithoutDeadline() throws {
        let todoitem = TodoItem(text: "5", importance: .important, isDone: false, changedAt: Date(), color: "#FFFFFF", category: Category(name: "Учеба", color: "#5F82FF"))
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw NSError(domain: "Вычислимое свойство JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(jsonData["deadline"])
    }
    
    func testJSONWithoutCategoryColor() throws {
        let todoitem = TodoItem(text: "5", importance: .important, deadline: Date(), isDone: false, color: "#FFFFFF", category: Category(name: "Без категории", color: nil))
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw NSError(domain: "Вычислимое свойство JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(jsonData["category_color"])
    }
    
    func testJSONWithoutChangedAt() throws {
        let todoitem = TodoItem(text: "5", importance: .important, deadline: Date(), isDone: false, color: "#FFFFFF", category: Category(name: "Учеба", color: "#5F82FF"))
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw NSError(domain: "Вычислимое свойство JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(jsonData["changed_at"])
    }
    
    func testJSONWithoutColor() throws {
        let todoitem = TodoItem(text: "5", importance: .important, deadline: Date(), isDone: false, changedAt: Date(), category: Category(name: "Учеба", color: "#5F82FF"))
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw NSError(domain: "Вычислимое свойство JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(jsonData["color"])
    }
    
    func testJSONWithUsualImportance() throws {
        let todoitem = TodoItem(text: "5", importance: .usual, deadline: Date(), isDone: false, changedAt: Date(), color: "#FFFFFF", category: Category(name: "Учеба", color: "#5F82FF"))
        let jsonData = todoitem.json
        guard let jsonData = jsonData as? [String: Any] else { throw NSError(domain: "Вычислимое свойство JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(jsonData["importance"])
    }
    
    func testCorrectnessOfJSONParsing() throws {
        let values: [Any] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertEqual(todoitem.id.uuidString, values[0] as? String)
        XCTAssertEqual(todoitem.text, values[1] as? String)
        XCTAssertEqual(todoitem.importance, .important)
        XCTAssertEqual(todoitem.deadline?.timeIntervalSince1970, values[3] as? TimeInterval)
        XCTAssertEqual(todoitem.isDone, values[4] as? Bool)
        XCTAssertEqual(todoitem.createdAt.timeIntervalSince1970, values[5] as? TimeInterval)
        XCTAssertEqual(todoitem.changedAt?.timeIntervalSince1970, values[6] as? TimeInterval)
        XCTAssertEqual(todoitem.color, values[7] as? String)
        XCTAssertEqual(todoitem.category.name, values[8] as? String)
        XCTAssertEqual(todoitem.category.color, values[9] as? String)
    }
    
    func testParcingWithoutImportance() throws {
        let values: [Any?] = [UUID().uuidString, "5", nil, Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertEqual(todoitem.importance, .usual)
    }
    
    func testParcingWithoutColor() throws {
        let values: [Any?] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, nil, "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertEqual(todoitem.color, nil)
    }
    
    func testParcingWithoutCategoryColor() throws {
        let values: [Any?] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", nil]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertEqual(todoitem.category.color, nil)
    }
    
    func testParcingWithoutDeadline() throws {
        let values: [Any?] = [UUID().uuidString, "5", "important", nil, false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(todoitem.deadline)
    }
    
    func testParcingWithoutChangedAt() throws {
        let values: [Any?] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, nil, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг JSON работает некорректно", code: 0, userInfo: nil) }
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
    
    func testParcingWithIncorrectDictionary2() throws {
        let values: [Any] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        dictionary["8"] = 6
        let todoitem = TodoItem.parse(json: dictionary)
        _ = try XCTUnwrap(todoitem)
    }
    
    func testParcingWithEmptyID() throws {
        let values: [Any] = ["", "5", "important", Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectIsDoneValue() throws {
        let values: [Any] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, "false", Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectImportanceValue() throws {
        let values: [Any] = [UUID().uuidString, "5", "cool", Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectCreatedAtValue() throws {
        let values: [Any] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, false, "date", Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithEmptyCreatedAtValue() throws {
        let values: [Any?] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, false, nil, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithEmptyIsDoneValue() throws {
        let values: [Any?] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, nil, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectDeadlineValue() throws {
        let values: [Any?] = [UUID().uuidString, "5", "important", "/", false, Date().timeIntervalSince1970, Date().timeIntervalSince1970, "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(todoitem.deadline)
    }
    
    func testParcingWithIncorrectChangedAtValue() throws {
        let values: [Any?] = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970, false, Date().timeIntervalSince1970, ":", "#FFFFFF", "Учеба", "#5F82FF"]
        var dictionary: [String: Any] = [:]
        for elem in TodoItem.CodingKeys.allCases.enumerated() {
            dictionary[elem.element.rawValue] = values[elem.offset]
        }
        let todoitem = TodoItem.parse(json: dictionary)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг JSON работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(todoitem.changedAt)
    }
}
