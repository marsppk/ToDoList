//
//  CategoryView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 09.07.2024.
//

import SwiftUI

struct CategoryView: View {
    @ObservedObject var viewModel: DetailsViewModel
    @Binding var currentCategoryColor: Color
    var body: some View {
        HStack {
            Text("Категория")
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .foregroundStyle(Color(UIColor.label))
            HStack {
                Circle()
                    .fill(currentCategoryColor)
                    .frame(width: 15)
                Picker(selection: $viewModel.selectionCategory, label: Text("Select a category")) {
                    ForEach(viewModel.categories.indices, id: \.self) { index in
                        Text(viewModel.categories[index].name).tag(index)
                        if viewModel.categories[index].name == "Без категории" {
                            Divider()
                        }
                    }
                    Divider()
                    Text("Новое").tag(viewModel.categories.count)
                }
            }
        }
        .frame(height: 40)
    }
}
