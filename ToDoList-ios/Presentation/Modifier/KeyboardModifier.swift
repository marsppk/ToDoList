//
//  KeyboardModifier.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 05.07.2024.
//

import SwiftUI

struct KeyboardModifier: ViewModifier {
    @Binding var isHidden: Bool
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                withAnimation {
                    isHidden = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                withAnimation {
                    isHidden = false
                }
            }
    }
}
