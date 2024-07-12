//
//  DetailsView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.06.2024.
//

import SwiftUI
import CustomColorPicker
import CocoaLumberjackSwift

struct DetailsView: View {
    @ObservedObject var modalState: ModalState
    @EnvironmentObject var storage: StorageLogic
    @StateObject var viewModel = DetailsViewModel()
    @State var currentCategoryColor: Color = .clear
    @State var customCategoryColor: Color = .orange
    @State var currentColor: Color = .clear
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var currentColorHex: String {
        currentColor.toHexString()
    }
    var categoryColorHex: String {
        customCategoryColor.toHexString()
    }
    var deleteButton: some View {
        Button(action: {
            if let id = modalState.selectedItem?.id {
                storage.deleteItem(id: id)
            }
            modalState.activateModalView = false
        }, label: {
            Text("Удалить")
                .foregroundStyle(viewModel.isDisabledDelete ? .gray : .red)
        }).disabled(viewModel.isDisabledDelete)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.secondaryBG)
        )
    }
    var datePicker: some View {
        DatePicker(
            "Date",
            selection: $viewModel.date,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
        .environment(\.locale, Locale(identifier: "ru_RU"))
    }
    var categoryAddition: some View {
        HStack {
            TextField("Название категории", text: $viewModel.title, axis: .vertical)
                .frame(height: 40)
                .foregroundStyle(.blue)
            Circle()
                .fill(customCategoryColor)
                .frame(height: 20)
                .gesture(TapGesture().onEnded({
                    viewModel.showCategoryColorPicker.toggle()
                }))
        }
    }
    var settingsWithoutDeleteButton: some View {
        VStack {
            ImportanceView(viewModel: viewModel, modalState: modalState)
            Divider()
            CategoryView(viewModel: viewModel, currentCategoryColor: $currentCategoryColor)
            if viewModel.showCategoryAddition {
                Divider()
                categoryAddition
                if viewModel.showCategoryColorPicker {
                    Divider()
                    ColorPickerView(chosenColor: $customCategoryColor)
                }
            }
            Divider()
            ColorPicker(viewModel: viewModel, currentColor: $currentColor)
            if viewModel.showPicker {
                ColorPickerView(chosenColor: $currentColor)
            }
            Divider()
            DeadlineView(viewModel: viewModel)
            if viewModel.showCalendar {
                Divider()
                datePicker
            }
        }
    }
    var settings: some View {
        VStack {
            settingsWithoutDeleteButton
                .padding([.top, .bottom], 10)
                .padding([.leading, .trailing], 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.secondaryBG)
                )
            deleteButton
        }
    }

    var body: some View {
        NavigationStack {
            chooseRightView()
                .scrollIndicators(.hidden)
                .padding(.all, 16)
                .navigationTitle("Дело")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Сохранить") {
                            viewModel.saveItem(
                                state: modalState,
                                hexColorTask: currentColorHex,
                                hexColorCategory: categoryColorHex,
                                storage: storage
                            )
                        }.disabled(viewModel.isDisabledSave)
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Отменить") {
                            modalState.activateModalView = false
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.primaryBG)
                .onReceive(modalState.$selectedItem, perform: updateForm)
                .modifier(KeyboardModifier(isHidden: $viewModel.isHidden))
                .onChange(of: [viewModel.text, viewModel.selection, currentColorHex, viewModel.title]) {
                    changeSaveButtonAvailability()
                }
                .onChange(of: viewModel.date) {
                    changeSaveButtonAvailability()
                }
                .onChange(of: viewModel.selectionCategory) {
                    updateCategory()
                }
                .onChange(of: viewModel.showDate) { _, value in
                    if !value {
                        viewModel.showCalendar = false
                    }
                    updateDate(viewModel.showDate)
                }
                .onChange(of: viewModel.showColor) { _, value in
                    if !value {
                        viewModel.showPicker = false
                    }
                    updateCurrentColor(viewModel.showColor)
                }
                .onAppear {
                    DDLogInfo("\(#function): DetailsView appeared")
                }
        }
    }
    @ViewBuilder
    private func chooseRightView() -> some View {
        if verticalSizeClass == .compact || horizontalSizeClass == .regular {
            HStack(spacing: 16) {
                ScrollView {
                    TextFieldView(viewModel: viewModel, currentColor: $currentColor)
                }
                if !viewModel.isHidden {
                    ScrollView {
                        settings
                    }
                }
            }
        } else {
            VStack(spacing: 16) {
                ScrollView {
                    TextFieldView(viewModel: viewModel, currentColor: $currentColor)
                    settings
                }
            }
        }
    }
    private func updateForm(_ selectedItem: TodoItem?) {
        viewModel.getCategories(storage: storage)
        viewModel.updateValues(item: modalState.selectedItem)
        if let selectedItem {
            if let color = selectedItem.color {
                currentColor = Color(hex: color)
                viewModel.showColor = true
            }
            if let index = viewModel.categories.firstIndex(of: selectedItem.category) {
                viewModel.selectionCategory = index
                if let categoryColor = selectedItem.category.color {
                    currentCategoryColor = Color(hex: categoryColor)
                }
            }
        }
    }

    private func updateCurrentColor(_ showColor: Bool) {
        currentColor = showColor ? (currentColor == .clear) ? Color(UIColor.red) : currentColor : .clear
        changeSaveButtonAvailability()
    }

    private func updateDate(_ showDate: Bool) {
        viewModel.updateDate()
        changeSaveButtonAvailability()
    }
    private func updateCategory() {
        if viewModel.selectionCategory < viewModel.categories.count {
            viewModel.showCategoryAddition = false
            if let color = viewModel.categories[viewModel.selectionCategory].color {
                currentCategoryColor = Color(hex: color)
            } else {
                currentCategoryColor = .clear
            }
        } else {
            viewModel.showCategoryAddition = true
            currentCategoryColor = .clear
        }
        changeSaveButtonAvailability()
    }
    private func changeSaveButtonAvailability() {
        viewModel.checkIsDisabledToSave(selectedItem: modalState.selectedItem, hexColor: currentColorHex)
    }
}

#Preview {
    DetailsView(modalState: ModalState())
        .environmentObject(MainViewModel().storage)
}
