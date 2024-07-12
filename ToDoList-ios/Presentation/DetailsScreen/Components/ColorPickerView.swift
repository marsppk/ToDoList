//
//  ColorPickerView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 09.07.2024.
//

import SwiftUI

struct ColorPicker: View {
    @ObservedObject var viewModel: DetailsViewModel
    @Binding var currentColor: Color
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                Text("Цвет")
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .foregroundStyle(Color(UIColor.label))
                if viewModel.showColor {
                    Text(currentColor.toHexString())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.blue)
                        .font(.system(size: 13))
                        .gesture(
                            TapGesture().onEnded({
                                withAnimation {
                                    viewModel.showPicker.toggle()
                                }
                            })
                        )
                }
            }
            .frame(height: 40)
            Toggle("", isOn: $viewModel.showColor)
        }
    }
}
