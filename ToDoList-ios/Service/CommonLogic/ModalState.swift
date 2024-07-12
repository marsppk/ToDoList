//
//  ModalState.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.06.2024.
//

import Foundation

final class ModalState: ObservableObject {
    @Published var activateModalView = false
    @Published var activateCalendarView = false
    @Published var selectedItem: TodoItem?
    @Published var didDismiss = false
    func changeValues(item: TodoItem?) {
        selectedItem = item
        activateModalView = true
        activateCalendarView = false
    }
}
