//
//  ColorModifier.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 25.06.2024.
//

import SwiftUI

struct ColorModifier: ViewModifier {
    @Binding var todoItem: TodoItem
    func body(content: Content) -> some View {
        if todoItem.isDone {
            content
                .foregroundStyle(.gray)
                .strikethrough(color: .gray)
        } else {
            content
                .foregroundStyle(.primary)
                .strikethrough(false)
        }
    }
}
