//
//  DetailsViewModel.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 09.07.2024.
//

import Foundation
import Combine

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
    var cancellables = Set<AnyCancellable>()
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
        storage.updateItem(
            item: storage.createNewItem(
                item: state.selectedItem,
                textAndImportance: (text, selection),
                deadline: deadline,
                color: color,
                category: category
            )
        )
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
}
