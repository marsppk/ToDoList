//
//  MainViewModel.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 21.06.2024.
//

import Foundation
import Combine
import CocoaLumberjackSwift

enum SortType: String {
    case significance = "Сортировать по добавлению"
    case date = "Сортировать по важности"
}

enum FilterType: String {
    case show = "Скрыть выполненное"
    case hide = "Показать выполненное"
}

@MainActor
final class MainViewModel: ObservableObject {
    @Published var storage = StorageLogic()
    @Published var sortedItems: [TodoItem] = []
    @Published var count = 0
    @Published var isActive = false
    @Published var sortType: SortType = .date
    @Published var filterType: FilterType = .hide
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
                    updateSortedItems()
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
    func updateSortedItems() {
        sortedItems = storage.loadSortedItemsFromPersistence(sortType: sortType, filterType: filterType)
        count = storage.getCount()
    }
    func changeShowButtonValue() {
        filterType = filterType == .hide ? .show : .hide
        updateSortedItems()
    }
    func changeSortButtonValue() {
        sortType = sortType == .significance ? .date : .significance
        updateSortedItems()
    }
    // MARK: - Networking
    func loadItems() {
        storage.loadItemsFromPersistence()
        if !storage.checkIsDirty() {
            loadItemsFromServer()
        } else {
            syncItems()
        }
    }
    func updateItem(item: TodoItem) {
        storage.updateItemInPersistence(item: item)
        updateSortedItems()
        if !storage.checkIsDirty() {
            apiManager.incrementNumberOfTasks()
            updateItemOnServer(item: item)
        } else {
            syncItems()
        }
    }
    func deleteItem(item: TodoItem) {
        storage.deleteItemInPersistence(item: item)
        updateSortedItems()
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
                items.forEach(self.storage.updateItemInPersistenceAfterLoading(item:))
                storage.loadItemsFromPersistence()
                apiManager.isShownAlertWithNoConnection = false
                DDLogInfo("\(#function): the items have been loaded successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                guard isShowAlert(error: error) else { return }
                if let error = error as? NetworkingErrors, error == .noConnection {
                    apiManager.isShownAlertWithNoConnection = true
                }
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
                items.forEach(self.storage.updateItemInPersistenceAfterLoading(item:))
                storage.loadItemsFromPersistence()
                storage.updateIsDirty(value: false)
                apiManager.isShownAlertWithNoConnection = false
                DDLogInfo("\(#function): the items have been synchronized successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                guard isShowAlert(error: error) else { return }
                if let error = error as? NetworkingErrors, error == .noConnection {
                    apiManager.isShownAlertWithNoConnection = true
                }
                apiManager.alertData = AlertData(message: error.localizedDescription)
            }
            apiManager.decrementNumberOfTasks()
        }
    }
    private func updateItemOnServer(item: TodoItem, retryDelay: Int = Delay.minDelay) {
        Task {
            do {
                try await apiManager.updateTodoItem(item: item)
                apiManager.decrementNumberOfTasks()
                apiManager.isShownAlertWithNoConnection = false
                DDLogInfo("\(#function): the item has been updated successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                let error = error as? NetworkingErrors
                let isNeededRetry = error == NetworkingErrors.serverError || error == NetworkingErrors.noConnection
                if retryDelay < Delay.maxDelay, isNeededRetry {
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
                apiManager.isShownAlertWithNoConnection = false
                DDLogInfo("\(#function): the item has been deleted successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                let error = error as? NetworkingErrors
                let isNeededRetry = error == NetworkingErrors.serverError || error == NetworkingErrors.noConnection
                if retryDelay < Delay.maxDelay, isNeededRetry {
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
    private func isShowAlert(error: Error) -> Bool {
        guard let error = error as? NetworkingErrors, error == .noConnection else {
            return true
        }
        return !apiManager.isShownAlertWithNoConnection
    }
}
