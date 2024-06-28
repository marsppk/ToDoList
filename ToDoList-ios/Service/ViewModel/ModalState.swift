//
//  ModalState.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.06.2024.
//

import Foundation

final class ModalState: ObservableObject {
    @Published var activateModalView = false
    @Published var selectedItem: TodoItem?
    
    func changeValues(item: TodoItem?) {
        selectedItem = item
        activateModalView = true
    }
}


