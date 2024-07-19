//
//  AlertModifier.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 18.07.2024.
//

import SwiftUI

struct AlertModifier: ViewModifier {
    @ObservedObject var apiManager: DefaultNetworkingService
    func body(content: Content) -> some View {
        content
            .alert(item: $apiManager.alertData) { alert in
                Alert(
                    title: Text("Ошибка"),
                    message: Text(alert.message),
                    dismissButton: .default(Text("OK")) {
                        apiManager.alertData = nil
                    }
                )
            }
    }
}
