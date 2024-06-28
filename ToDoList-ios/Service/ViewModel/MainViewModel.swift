//
//  MainViewModel.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 21.06.2024.
//

import Foundation

final class MainViewModel: ObservableObject {
    private var fileCache = FileCache()
    @Published var showButtonText = "Показать"
    @Published var sortButtonText = "Сортировать по важности"
    @Published var sortedItems: [TodoItem] = []
    @Published var count = 0
    
    func updateCount() {
        count = fileCache.todoItems.filter({ $0.1.isDone == true }).count
    }
    
    func updateSortedItems() {
        sortedItems = showButtonText == "Показать" ? Array(fileCache.todoItems.values.filter({ $0.isDone == false })) : Array(fileCache.todoItems.values)
        if sortButtonText == "Сортировать по добавлению" {
            sortedItems.sort(by: {$0.importance.getIndex() > $1.importance.getIndex()})
        } else {
            sortedItems.sort(by: {$0.createdAt < $1.createdAt})
        }
    }
    
    func changeShowButtonValue() {
        showButtonText = showButtonText == "Показать выполненное" ? "Скрыть выполненное" : "Показать выполненное"
    }
    
    func changeSortButtonValue() {
        sortButtonText = sortButtonText == "Сортировать по важности" ? "Сортировать по добавлению" : "Сортировать по важности"
    }
    
    func createItemWithAnotherIsDone(item: TodoItem) -> TodoItem {
        TodoItem(id: item.id, text: item.text, importance: item.importance, deadline: item.deadline, isDone: !item.isDone, createdAt: item.createdAt, changedAt: item.changedAt, color: item.color)
    }
    
    func createNewItem(item: TodoItem?, text: String, importance: Int, deadline: Date?, color: String?) -> TodoItem {
        if let item = item {
            return TodoItem(id: item.id, text: text, importance: Importance.allCases[importance], deadline: deadline, isDone: false, createdAt: item.createdAt, changedAt: Date(), color: color)
        } else {
            return TodoItem(text: text, importance: Importance.allCases[importance], deadline: deadline, isDone: false, createdAt: Date(), changedAt: nil, color: color)
        }
    }
    
    func updateItem(item: TodoItem) {
        fileCache.addNewItem(item: item)
        saveItemsToJSON()
        prepare()
    }
    
    func deleteItem(id: UUID) {
        fileCache.removeItem(by: id)
        saveItemsToJSON()
        prepare()
    }
    
    func loadItemsFromJSON() throws {
        try fileCache.getItemsFromJSON(fileName: "test1")
        prepare()
    }
    
    func saveItemsToJSON() {
        do {
            try fileCache.saveJSON(fileName: "test1")
        } catch {
            print("Ошибка при сохранении данных в JSON: \(error)")
        }
    }
    
    func prepare() {
        updateSortedItems()
        updateCount()
    }
}
