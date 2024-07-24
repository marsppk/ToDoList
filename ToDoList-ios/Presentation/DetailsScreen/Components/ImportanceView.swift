//
//  ImportanceView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 09.07.2024.
//

import SwiftUI

struct ImportanceView: View {
    @ObservedObject var viewModel: DetailsViewModel
    @ObservedObject var modalState: ModalState
    var body: some View {
        HStack {
            Text("Важность")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color(UIColor.label))
            Picker("Picker", selection: $viewModel.selection) {
                Image(systemName: "arrow.down").tag(0)
                    .foregroundStyle(.gray, .blue)
                Text("нет").tag(1)
                Image(systemName: "exclamationmark.2").tag(2)
                    .foregroundStyle(.red, .blue)
            }
            .frame(width: 150)
            .pickerStyle(SegmentedPickerStyle())
            .animation(nil)
        }
        .frame(height: 40)
    }
}
