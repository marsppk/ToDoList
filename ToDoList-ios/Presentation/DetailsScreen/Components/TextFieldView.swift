//
//  TextFieldView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 09.07.2024.
//

import SwiftUI

struct TextFieldView: View {
    @ObservedObject var viewModel: DetailsViewModel
    @Binding var currentColor: Color
    var customPlaceholder: some View {
        Text("Что надо сделать?")
            .foregroundStyle(.gray)
    }
    var textField: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.text.isEmpty {
                customPlaceholder
            }
            TextField("", text: $viewModel.text, axis: .vertical)
                .multilineTextAlignment(.leading)
                .lineLimit(.none)
                .modifier(TextFieldFrameModifier())
        }
        .padding()
        .padding(.bottom, 6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.secondaryBG)
        )
    }
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            textField
            Rectangle()
                .fill(currentColor)
                .frame(width: 7)
                .frame(maxHeight: .infinity)
        }
        .cornerRadius(16)
        .frame(maxHeight: .infinity, alignment: .leading)
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
    }
}
