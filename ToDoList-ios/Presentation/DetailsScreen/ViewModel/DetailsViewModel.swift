//
//  DetailsViewModel.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 09.07.2024.
//

import Foundation
import Combine
import CocoaLumberjackSwift

@MainActor
final class DetailsViewModel: ObservableObject {
    @Published var text: String = ""
    @Published var title: String = ""
    @Published var categories: [Category] = []
    @Published var selection = "important"
    @Published var selectionCategory = 0
    @Published var date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @Published var showDate = false
    @Published var showCalendar = false
    @Published var showColor = false
    @Published var showPicker = false
    @Published var showCategoryColorPicker = false
    @Published var showCategoryAddition = false
    @Published var isHidden = false
    @Published var isDisabledSave = true
    @Published var isDisabledDelete = false
    var apiManager: DefaultNetworkingService
    var cancellables = Set<AnyCancellable>()
    init(apiManager: DefaultNetworkingService) {
        self.apiManager = apiManager
    }
    func getCategories(storage: StorageLogic) {
        categories = storage.getCategories()
    }
    func updateValues(item: TodoItem?) {
        if let item {
            text = item.text
            selection = item.importance.rawValue
            if let deadline = item.deadline {
                date = deadline
                showDate = true
            }
        } else {
            isDisabledDelete = true
        }
    }
    func updateDate() {
        date = !showDate ? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date() : date
    }
    func saveItem(state: ModalState, hexColorTask: String, hexColorCategory: String, storage: StorageLogic) {
        let deadline = showDate ? date : nil
        let color = showColor ? hexColorTask : nil
        let category: Category = selectionCategory == categories.count ?
        Category(name: title, color: hexColorCategory) :
        categories[selectionCategory]
        let item = storage.createNewItem(
            item: state.selectedItem,
            textAndImportance: (text, selection),
            deadline: deadline,
            color: color,
            category: category
        )
        if state.selectedItem == nil {
            addToDoItem(item: item, storage: storage)
        } else {
            updateToDoItem(item: item, storage: storage)
        }
        state.activateModalView = false
    }
    func checkIsDisabledToSave(selectedItem: TodoItem?, hexColor: String) {
        guard !text.isEmpty,
              hexColor != selectedItem?.color && showColor ||
              !showColor && selectedItem?.color != nil ||
              !date.isEqualDay(with: selectedItem?.deadline) && showDate ||
              !showDate && selectedItem?.deadline != nil ||
              selection != selectedItem?.importance.rawValue ||
              text != selectedItem?.text ||
              selectionCategory == categories.count && title != "" ||
              selectionCategory < categories.count && categories[selectionCategory].name != selectedItem?.category.name
        else {
            isDisabledSave = true
            return
        }
        isDisabledSave = false
    }
    func addToDoItem(item: TodoItem, storage: StorageLogic) {
        storage.insertItemInSwiftData(item: item)
        apiManager.incrementNumberOfTasks()
        addToDoItemOnServer(item: item, storage: storage)
    }
    func addToDoItemOnServer(item: TodoItem, storage: StorageLogic, retryDelay: Int = Delay.minDelay) {
        Task {
            do {
                try await apiManager.addTodoItem(item: item)
                apiManager.decrementNumberOfTasks()
                DDLogInfo("\(#function): the item have been added successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                let error = error as? NetworkingErrors
                let isServerError = error?.localizedDescription == NetworkingErrors.serverError.localizedDescription
                if retryDelay < Delay.maxDelay, isServerError {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                        self.addToDoItemOnServer(
                            item: item,
                            storage: storage,
                            retryDelay: Delay.countNextDelay(from: retryDelay)
                        )
                    }
                } else {
                    storage.updateIsDirty(value: true)
                    apiManager.decrementNumberOfTasks()
                }
            }
        }
    }
    func updateToDoItem(item: TodoItem, storage: StorageLogic) {
        storage.updateItemInSwiftData(item: item)
        apiManager.incrementNumberOfTasks()
        updateToDoItemOnServer(item: item, storage: storage)
    }
    func updateToDoItemOnServer(item: TodoItem, storage: StorageLogic, retryDelay: Int = Delay.minDelay) {
        Task {
            do {
                try await apiManager.updateTodoItem(item: item)
                apiManager.decrementNumberOfTasks()
                DDLogInfo("\(#function): the item have been updated successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                let error = error as? NetworkingErrors
                let isServerError = error?.localizedDescription == NetworkingErrors.serverError.localizedDescription
                if retryDelay < Delay.maxDelay, isServerError {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                        self.updateToDoItemOnServer(
                            item: item,
                            storage: storage,
                            retryDelay: Delay.countNextDelay(from: retryDelay)
                        )
                    }
                } else {
                    storage.updateIsDirty(value: true)
                    apiManager.decrementNumberOfTasks()
                }
            }
        }
    }
    func deleteToDoItem(item: TodoItem, storage: StorageLogic) {
        storage.deleteItemInSwiftData(item: item)
        apiManager.incrementNumberOfTasks()
        deleteToDoItemOnServer(id: item.id, storage: storage)
    }
    func deleteToDoItemOnServer(id: UUID, storage: StorageLogic, retryDelay: Int = Delay.minDelay) {
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                        self.deleteToDoItemOnServer(
                            id: id,
                            storage: storage,
                            retryDelay: Delay.countNextDelay(from: retryDelay)
                        )
                    }
                } else {
                    storage.updateIsDirty(value: true)
                    apiManager.decrementNumberOfTasks()
                }
            }
        }
    }
}
