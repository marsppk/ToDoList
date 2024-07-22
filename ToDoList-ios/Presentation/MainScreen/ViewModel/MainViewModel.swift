//
//  MainViewModel.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 21.06.2024.
//

import Foundation
import Combine
import CocoaLumberjackSwift

@MainActor
final class MainViewModel: ObservableObject {
    @Published var storage = StorageLogic()
    @Published var showButtonText = "Показать выполненное"
    @Published var sortButtonText = "Сортировать по важности"
    @Published var sortedItems: [TodoItem] = []
    @Published var count = 0
    @Published var isActive = false
    private var deviceID: String
    private var cancellables = Set<AnyCancellable>()
    lazy var apiManager: DefaultNetworkingService = {
        let apiManager = DefaultNetworkingService(token: setupToken(), deviceID: deviceID)
        return apiManager
    }()
    init(deviceID: String) {
        self.deviceID = deviceID
        storage.$isUpdated
            .sink { [weak self] value in
                guard let self = self else { return }
                if value {
                    updateSortedItems(items: Array(storage.getItems().values))
                    storage.isUpdated = false
                }
            }
            .store(in: &cancellables)
        apiManager.$numberOfTasks
            .sink { [weak self] value in
                guard let self = self else { return }
                if value > 0 {
                    self.isActive = true
                } else {
                    self.isActive = false
                }
            }
            .store(in: &cancellables)
    }
    func updateSortedItems(items: [TodoItem]) {
        sortedItems = showButtonText == "Показать выполненное" ?
        Array(items.filter({ $0.isDone == false })) :
        Array(items)
        if sortButtonText == "Сортировать по добавлению" {
            sortedItems.sort(by: {$0.importance.getIndex() > $1.importance.getIndex()})
        } else {
            sortedItems.sort(by: {$0.createdAt < $1.createdAt})
        }
        count = items.filter({ $0.isDone == true }).count
    }
    func changeShowButtonValue() {
        showButtonText = showButtonText == "Показать выполненное" ? "Скрыть выполненное" : "Показать выполненное"
    }
    func changeSortButtonValue() {
        sortButtonText = sortButtonText == "Сортировать по важности" ?
        "Сортировать по добавлению" :
        "Сортировать по важности"
    }
    // MARK: - Networking
    func loadItems() {
        storage.loadItemsFromSwiftData()
        updateSortedItems(items: Array(storage.getItems().values))
        if !storage.checkIsDirty() {
            loadItemsFromServer()
        } else {
            syncItems()
        }
    }
    func updateItem(item: TodoItem) {
        storage.updateItemInSwiftData(item: item)
        if !storage.checkIsDirty() {
            apiManager.incrementNumberOfTasks()
            updateItemOnServer(item: item)
        } else {
            syncItems()
        }
    }
    func deleteItem(item: TodoItem) {
        storage.deleteItemInSwiftData(item: item)
        if !storage.checkIsDirty() {
            apiManager.incrementNumberOfTasks()
            deleteItemOnServer(id: item.id)
        } else {
            syncItems()
        }
    }
    private func setupToken() -> String {
        if let loadedToken = KeychainService.loadToken(forKey: Constants.key) {
            return loadedToken
        } else {
            let token = "Faelivrin"
            if KeychainService.saveToken(token: token, forKey: Constants.key) {
                return KeychainService.loadToken(forKey: Constants.key) ?? ""
            } else {
                return ""
            }
        }
    }
    private func loadItemsFromServer() {
        Task {
            apiManager.incrementNumberOfTasks()
            do {
                let items = try await apiManager.getTodoList()
                storage.deleteAllItemsThatNotInBackend(items: items)
                items.forEach(self.storage.updateItemAfterLoading(item:))
                DDLogInfo("\(#function): the items have been loaded successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                apiManager.alertData = AlertData(message: error.localizedDescription)
            }
            apiManager.decrementNumberOfTasks()
        }
    }
    private func syncItems() {
        Task {
            apiManager.incrementNumberOfTasks()
            do {
                let items = try await apiManager.updateTodoList(todoList: Array(self.storage.getItems().values))
                storage.deleteAllItemsThatNotInBackend(items: items)
                items.forEach(self.storage.updateItemAfterLoading(item:))
                storage.updateIsDirty(value: false)
                DDLogInfo("\(#function): the items have been synchronized successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                apiManager.alertData = AlertData(message: error.localizedDescription)
            }
            apiManager.decrementNumberOfTasks()
        }
    }
    private func updateItemOnServer(item: TodoItem, retryDelay: Int = Delay.minDelay) {
        Task {
            do {
                try await apiManager.updateTodoItem(item: item)
                DDLogInfo("\(#function): the item have been updated successfully")
                apiManager.decrementNumberOfTasks()
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                let error = error as? NetworkingErrors
                let isServerError = error?.localizedDescription == NetworkingErrors.serverError.localizedDescription
                if retryDelay < Delay.maxDelay, isServerError {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                        self.updateItemOnServer(item: item, retryDelay: Delay.countNextDelay(from: retryDelay))
                    }
                } else {
                    storage.updateIsDirty(value: true)
                    apiManager.decrementNumberOfTasks()
                    syncItems()
                }
            }
        }
    }
    private func deleteItemOnServer(id: UUID, retryDelay: Int = Delay.minDelay) {
        Task {
            do {
                try await apiManager.deleteTodoItem(id: id.uuidString)
                apiManager.decrementNumberOfTasks()
                DDLogInfo("\(#function): the item have been deleted successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                let error = error as? NetworkingErrors
                let isServerError = error?.localizedDescription == NetworkingErrors.serverError.localizedDescription
                if retryDelay < Delay.maxDelay, isServerError {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(retryDelay))) {
                        self.deleteItemOnServer(id: id, retryDelay: Delay.countNextDelay(from: retryDelay))
                    }
                } else {
                    storage.updateIsDirty(value: true)
                    apiManager.decrementNumberOfTasks()
                    syncItems()
                }
            }
        }
    }
}
