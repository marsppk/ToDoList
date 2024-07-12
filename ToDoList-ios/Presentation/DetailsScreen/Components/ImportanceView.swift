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
                Image(systemName: "arrow.down").tag("unimportant")
                    .foregroundStyle(.gray, .blue)
                Text("нет").tag("usual")
                Image(systemName: "exclamationmark.2").tag("important")
                    .foregroundStyle(.red, .blue)
            }
            .animation(nil)
            .frame(width: 150)
            .pickerStyle(SegmentedPickerStyle())
        }
        .frame(height: 40)
    }
}
