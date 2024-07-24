//
//  ToDoListCSVTests.swift
//  ToDoList-iosTests
//
//  Created by Maria Slepneva on 15.06.2024.
//

import XCTest
@testable import ToDoList_ios

final class ToDoListCSVTests: XCTestCase {
    enum CSVErrors: Error {
        case csvParsingIncorrect
        case csvComputedPropertyIncorrect
    }

    func testCorrectnessOfCSVVariable() throws {
        let todoitem = MockTodoItems.itemWithAllProperties
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw CSVErrors.csvComputedPropertyIncorrect }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssertEqual(arrayOfData[0], todoitem.id.uuidString)
        XCTAssertEqual(arrayOfData[1], todoitem.text)
        XCTAssertEqual(arrayOfData[2], String(todoitem.importance))
        XCTAssertEqual(arrayOfData[3], todoitem.deadline?.timeIntervalSince1970.description)
        XCTAssertEqual(arrayOfData[4], todoitem.isDone.description)
        XCTAssertEqual(arrayOfData[5], todoitem.createdAt.timeIntervalSince1970.description)
        XCTAssertEqual(arrayOfData[6], todoitem.changedAt?.timeIntervalSince1970.description)
        XCTAssertEqual(arrayOfData[7], todoitem.color)
        XCTAssertEqual(arrayOfData[8], todoitem.category.name)
        XCTAssertEqual(arrayOfData[9], todoitem.category.color)
    }
    func testCSVWithoutDeadline() throws {
        let todoitem = MockTodoItems.itemWithoutDeadline
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw CSVErrors.csvComputedPropertyIncorrect }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 10)
        XCTAssert(arrayOfData[3].isEmpty)
    }
    func testCSVWithoutColor() throws {
        let todoitem = MockTodoItems.itemWithoutColor
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw CSVErrors.csvComputedPropertyIncorrect }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 10)
        XCTAssert(arrayOfData[7].isEmpty)
    }
    func testCSVWithoutCategoryColor() throws {
        let todoitem = MockTodoItems.itemWithoutCategoryColor
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw CSVErrors.csvComputedPropertyIncorrect }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 10)
        XCTAssert(arrayOfData[9].isEmpty)
    }
    func testCSVWithoutChangedAt() throws {
        let todoitem = MockTodoItems.itemWithoutChangedAt
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw CSVErrors.csvComputedPropertyIncorrect }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 10)
        XCTAssert(arrayOfData[6].isEmpty)
    }
    func testCSVWithBasicImportance() throws {
        let todoitem = MockTodoItems.itemWithBasicImportance
        let csvString = todoitem.csv
        guard let csvString = csvString as? String else { throw CSVErrors.csvComputedPropertyIncorrect }
        let arrayOfData = csvString.components(separatedBy: TodoItem.csvColumnsDelimiter)
        XCTAssert(arrayOfData.count == 10)
        XCTAssert(arrayOfData[2].isEmpty)
    }

    @MainActor func testCorrectnessOfCSVParsing() throws {
        let values = DataForParsing.itemWithAllProperties
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertEqual(todoitem.id.uuidString, values[0])
        XCTAssertEqual(todoitem.text, values[1])
        XCTAssertEqual(todoitem.importance, Importance.important.rawValue)
        XCTAssertEqual(todoitem.deadline?.timeIntervalSince1970.description, values[3])
        XCTAssertEqual(todoitem.isDone.description, values[4])
        XCTAssertEqual(todoitem.createdAt.timeIntervalSince1970.description, values[5])
        XCTAssertEqual(todoitem.changedAt?.timeIntervalSince1970.description, values[6])
        XCTAssertEqual(todoitem.color, values[7])
    }
    @MainActor func testParcingWithoutImportance() throws {
        let values = DataForParsing.itemWithoutImportance
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertEqual(todoitem.importance, Importance.basic.rawValue)
    }
    @MainActor func testParcingWithoutDeadline() throws {
        let values = DataForParsing.itemWithoutDeadline
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertNil(todoitem.deadline)
    }
    @MainActor func testParcingWithoutCategoryColor() throws {
        let values = DataForParsing.itemWithoutCategoryColor
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertNil(todoitem.category.color)
    }
    @MainActor func testParcingWithoutChangedAt() throws {
        let values = DataForParsing.itemWithoutChangedAt
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertNil(todoitem.changedAt)
    }
    @MainActor func testParcingWithoutColor() throws {
        let values = DataForParsing.itemWithoutColor
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertNil(todoitem.color)
    }
    @MainActor func testParcingWithIncorrectString() throws {
        let values = DataForParsing.itemWithAllProperties
        let csvString = values.joined(separator: " ")
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectNumberOfColumns1() throws {
        let values = DataForParsing.itemWithExtraLine
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectNumberOfColumns2() throws {
        let values = DataForParsing.itemWithoutNecessaryProperties
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithEmptyID() throws {
        let values = DataForParsing.itemWithoutId
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectIsDoneValue() throws {
        let values = DataForParsing.itemWithIncorrectIsDone
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectImportanceValue() throws {
        let values = DataForParsing.itemWithIncorrectImportance
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertEqual(todoitem.importance, Importance.basic.rawValue)
    }
    @MainActor func testParcingWithIncorrectCreatedAtValue() throws {
        let values = DataForParsing.itemWithIncorrectCreatedAt
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithEmptyCreatedAtValue() throws {
        let values = DataForParsing.itemWithoutCreatedAt
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithEmptyIsDoneValue() throws {
        let values = DataForParsing.itemWithEmptyIsDone
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        XCTAssertNil(todoitem)
    }
    @MainActor func testParcingWithIncorrectDeadlineValue() throws {
        let values = DataForParsing.itemWithIncorrectDeadline
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertNil(todoitem.deadline)
    }
    @MainActor func testParcingWithIncorrectChangedAtValue() throws {
        let values = DataForParsing.itemWithIncorrectChangedAt
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertNil(todoitem.changedAt)
    }
    @MainActor func testParcingWithCommaInText() throws {
        let values = DataForParsing.itemWithCommaInText
        let csvString = values.joined(separator: TodoItem.csvColumnsDelimiter)
        let todoitem = TodoItem.parse(csv: csvString)
        guard let todoitem = todoitem else { throw CSVErrors.csvParsingIncorrect }
        XCTAssertEqual(todoitem.text, values[1])
    }
}
