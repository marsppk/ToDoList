//
//  MainViewModel.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 21.06.2024.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    @Published var storage = StorageLogic()
    @Published var showButtonText = "Показать выполненное"
    @Published var sortButtonText = "Сортировать по важности"
    @Published var sortedItems: [TodoItem] = []
    @Published var count = 0
    var cancellables = Set<AnyCancellable>()
    
    init() {
        storage.$isUpdated
            .sink { _ in
                self.prepare()
            }
            .store(in: &cancellables)
    }
    
    func updateCount() {
        let items = storage.getItems()
        count = items.filter({ $0.1.isDone == true }).count
    }
    
    func updateSortedItems() {
        let items = storage.getItems()
        sortedItems = showButtonText == "Показать выполненное" ? Array(items.values.filter({ $0.isDone == false })) : Array(items.values)
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

    func updateItem(item: TodoItem) {
        storage.updateItem(item: item)
    }
    
    func deleteItem(id: UUID) {
        storage.deleteItem(id: id)
    }
    
    func loadItems() throws {
        try storage.loadItemsFromJSON()
    }
    
    func prepare() {
        updateSortedItems()
        updateCount()
    }
}
