//
//  ToDoList_iosCSVTests.swift
//  ToDoList-iosTests
//
//  Created by Maria Slepneva on 15.06.2024.
//

import XCTest
@testable import ToDoList_ios

final class ToDoList_iosCSVTests: XCTestCase {

    func testCorrectnessOfCSVVariable() throws {
        let todoitem = TodoItem(text: "5", importance: .important, deadline: Date(), isDone: false, changedAt: Date(), color: "#FFFFFF")
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw NSError(domain: "Вычислимое свойство CSV работает некорректно", code: 0, userInfo: nil) }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssertEqual(arrayOfData[0], todoitem.id.uuidString)
        XCTAssertEqual(arrayOfData[1], todoitem.text)
        XCTAssertEqual(arrayOfData[2], todoitem.importance.rawValue)
        XCTAssertEqual(arrayOfData[3], todoitem.deadline?.timeIntervalSince1970.description)
        XCTAssertEqual(arrayOfData[4], todoitem.isDone.description)
        XCTAssertEqual(arrayOfData[5], todoitem.createdAt.timeIntervalSince1970.description)
        XCTAssertEqual(arrayOfData[6], todoitem.changedAt?.timeIntervalSince1970.description)
        XCTAssertEqual(arrayOfData[7], todoitem.color)
    }
    
    func testCSVWithoutDeadline() throws {
        let todoitem = TodoItem(text: "5", importance: .important, isDone: false, changedAt: Date(), color: "#FFFFFF")
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw NSError(domain: "Вычислимое свойство CSV работает некорректно", code: 0, userInfo: nil) }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 8)
        XCTAssert(arrayOfData[3].isEmpty)
    }
    
    func testCSVWithoutColor() throws {
        let todoitem = TodoItem(text: "5", importance: .important, deadline: Date(), isDone: false, changedAt: Date())
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw NSError(domain: "Вычислимое свойство CSV работает некорректно", code: 0, userInfo: nil) }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 8)
        XCTAssert(arrayOfData[7].isEmpty)
    }
    
    func testCSVWithoutChangedAt() throws {
        let todoitem = TodoItem(text: "5", importance: .important, deadline: Date(), isDone: false, color: "#FFFFFF")
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw NSError(domain: "Вычислимое свойство CSV работает некорректно", code: 0, userInfo: nil) }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 8)
        XCTAssert(arrayOfData[6].isEmpty)
    }
    
    func testCSVWithUsualImportance() throws {
        let todoitem = TodoItem(text: "5", importance: .usual, deadline: Date(), isDone: false, changedAt: Date(), color: "#FFFFFF")
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw NSError(domain: "Вычислимое свойство CSV работает некорректно", code: 0, userInfo: nil) }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 8)
        XCTAssert(arrayOfData[2].isEmpty)
    }

    func testCorrectnessOfCSVParsing() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг CSV работает некорректно", code: 0, userInfo: nil) }
        XCTAssertEqual(todoitem.id.uuidString, values[0])
        XCTAssertEqual(todoitem.text, values[1])
        XCTAssertEqual(todoitem.importance, .important)
        XCTAssertEqual(todoitem.deadline?.timeIntervalSince1970.description, values[3])
        XCTAssertEqual(todoitem.isDone.description, values[4])
        XCTAssertEqual(todoitem.createdAt.timeIntervalSince1970.description, values[5])
        XCTAssertEqual(todoitem.changedAt?.timeIntervalSince1970.description, values[6])
        XCTAssertEqual(todoitem.color, values[7])
    }
    
    func testParcingWithoutImportance() throws {
        let values = [UUID().uuidString, "5", "", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг CSV работает некорректно", code: 0, userInfo: nil) }
        XCTAssertEqual(todoitem.importance, .usual)
    }
    
    func testParcingWithoutDeadline() throws {
        let values = [UUID().uuidString, "5", "important", "", "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг CSV работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(todoitem.deadline)
    }
    
    func testParcingWithoutChangedAt() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, "", "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг CSV работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(todoitem.changedAt)
    }
    
    func testParcingWithoutColor() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, ""]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг CSV работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(todoitem.color)
    }
    
    func testParcingWithIncorrectString() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: " ")
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectNumberOfColumns1() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF", "wrong"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectNumberOfColumns2() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithEmptyID() throws {
        let values = ["", "5", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectIsDoneValue() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "52", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectImportanceValue() throws {
        let values = [UUID().uuidString, "5", "cool", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectCreatedAtValue() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", "sdd", Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithEmptyCreatedAtValue() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", "", Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithEmptyIsDoneValue() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    
    func testParcingWithIncorrectDeadlineValue() throws {
        let values = [UUID().uuidString, "5", "important", "f", "false", Date().timeIntervalSince1970.description, Date().timeIntervalSince1970.description, "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг CSV работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(todoitem.deadline)
    }
    
    func testParcingWithIncorrectChangedAtValue() throws {
        let values = [UUID().uuidString, "5", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, "r", "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг CSV работает некорректно", code: 0, userInfo: nil) }
        XCTAssertNil(todoitem.changedAt)
    }
    
    func testParcingWithCommaInText() throws {
        let values = [UUID().uuidString, "5, 3", "important", Date().timeIntervalSince1970.description, "false", Date().timeIntervalSince1970.description, "r", "#FFFFFF"]
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw NSError(domain: "Парсинг CSV работает некорректно", code: 0, userInfo: nil) }
        XCTAssertEqual(todoitem.text, values[1])
    }
}
