//
//  SheetModifier.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.06.2024.
//

import SwiftUI

struct SheetModifier: ViewModifier {
    @ObservedObject var modalState: ModalState
    @ObservedObject var viewModel: MainViewModel
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad {
            content
                .sheet(isPresented: $modalState.activateModalView, onDismiss: {
                    modalState.selectedItem = nil
                }) {
                    DetailsView(modalState: modalState)
                        .environmentObject(viewModel)
                }
        } else {
            content
        }
    }
}
