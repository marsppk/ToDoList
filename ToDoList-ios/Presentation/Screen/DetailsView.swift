//
//  DetailsView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.06.2024.
//

import SwiftUI

struct DetailsView: View {
    @ObservedObject var modalState: ModalState
    @EnvironmentObject var storage: StorageLogic
    @State var categories: [Category] = []
    @State var text: String = ""
    @State var title: String = ""
    @State var selection = 2
    @State var selectionCategory = 0
    @State var showDate = false
    @State var showCalendar = false
    @State var showColor = false
    @State var showPicker = false
    @State var showCategoryColorPicker = false
    @State var currentColor: Color = .clear
    @State var currentCategoryColor: Color = .clear
    @State var customCategoryColor: Color = .orange
    @State var date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State var isHidden = false
    @State var isDisabledSave = true
    @State var isDisabledDelete = false
    @State var showCategoryAddition = false
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var currentColorHex: String {
        currentColor.toHexString()
    }
    
    var customPlaceholder: some View {
        Text("Что надо сделать?")
            .foregroundStyle(.gray)
    }
    
    var importance: some View {
        HStack {
            Text("Важность")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color(UIColor.label))
            Picker("Picker", selection: $selection) {
                Image(systemName: "arrow.down").tag(0)
                    .foregroundStyle(.gray, .blue)
                Text("нет").tag(1)
                Image(systemName: "exclamationmark.2").tag(2)
                    .foregroundStyle(.red, .blue)
            }
            .onChange(of: selection) {
                isDisabledSave = checkIsDisabledToSave()
            }
            .animation(nil)
            .frame(width: 150)
            .pickerStyle(SegmentedPickerStyle())
        }
        .frame(height: 40)
    }
    
    var deadline: some View {
        HStack {
            VStack(spacing: 0) {
                Text("Сделать до")
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .foregroundStyle(Color(UIColor.label))
                if showDate {
                    Text(date.makePrettyString(dateFormat: "d MMMM yyyy"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.blue)
                        .font(.system(size: 13))
                        .gesture(
                            TapGesture().onEnded({
                                withAnimation {
                                    showCalendar.toggle()
                                }
                            })
                        )
                }
            }
            .frame(height: 40)
            Toggle("", isOn: $showDate)
                .onReceive([showDate].publisher.first(), perform: { value in
                if !value {
                    showCalendar = false
                }
                isDisabledSave = checkIsDisabledToSave()
            })
        }
    }
    
    var picker: some View {
        HStack {
            VStack(spacing: 0) {
                Text("Цвет")
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .foregroundStyle(Color(UIColor.label))
                if showColor {
                    Text(currentColorHex)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.blue)
                        .font(.system(size: 13))
                        .gesture(
                            TapGesture().onEnded({
                                withAnimation {
                                    showPicker.toggle()
                                }
                            })
                        )
                }
            }
            .frame(height: 40)
            Toggle("", isOn: $showColor).onReceive([showColor].publisher.first(), perform: { value in
                if !value {
                    showPicker = false
                }
                isDisabledSave = checkIsDisabledToSave()
            })
        }
    }
    
    var textField: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                customPlaceholder
            }
            TextField("", text: $text, axis: .vertical)
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

    
    var deleteButton: some View {
        Button(action: {
            if let id = modalState.selectedItem?.id {
                storage.deleteItem(id: id)
            }
            modalState.activateModalView = false
        }, label: {
            Text("Удалить")
                .foregroundStyle(isDisabledDelete ? .gray : .red)
        }).disabled(isDisabledDelete)
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
            selection: $date,
            displayedComponents: [.date]
        )
        .datePickerStyle(.graphical)
    }
    
    var textArea: some View {
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
    
    var category: some View {
        HStack {
            Text("Категория")
                .frame(maxWidth: .infinity, alignment: .bottomLeading)
                .foregroundStyle(Color(UIColor.label))
            HStack {
                Circle()
                    .fill(currentCategoryColor)
                    .frame(width: 15)
                Picker(selection: $selectionCategory, label: Text("Select a category")) {
                    ForEach(Array(categories.enumerated()), id: \.offset) { (index, category) in
                        Text(category.name).tag(index)
                        if category.name == "Без категории" {
                            Divider()
                        }
                    }
                    Divider()
                    Text("Новое").tag(categories.count + 1)
                }
                .onChange(of: selectionCategory) {
                    if selectionCategory < categories.count {
                        showCategoryAddition = false
                        if let color = categories[selectionCategory].color {
                            currentCategoryColor = Color(hex: color)
                        } else {
                            currentCategoryColor = .clear
                        }
                    } else {
                        showCategoryAddition = true
                        currentCategoryColor = .clear
                    }
                    isDisabledSave = checkIsDisabledToSave()
                }
            }
        }
        .frame(height: 40)
    }
    
    var categoryAddition: some View {
        HStack {
            TextField("Название категории", text: $title, axis: .vertical)
                .frame(height: 40)
                .foregroundStyle(.blue)
            Circle()
                .fill(customCategoryColor)
                .frame(height: 20)
                .gesture(TapGesture().onEnded({
                    showCategoryColorPicker.toggle()
                }))
        }
    }
    
    var settings: some View {
        VStack {
            VStack {
                importance
                Divider()
                category
                if showCategoryAddition {
                    Divider()
                    categoryAddition
                    if showCategoryColorPicker {
                        Divider()
                        ColorPickerView(chosenColor: $customCategoryColor)
                    }
                }
                Divider()
                picker
                if showPicker {
                    ColorPickerView(chosenColor: $currentColor)
                }
                Divider()
                deadline
                if showCalendar {
                    Divider()
                    datePicker
                }
            }
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
                            saveItem()
                        }.disabled(isDisabledSave)
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
                .modifier(KeyboardModifier(isHidden: $isHidden))
                .onChange(of: text) {
                    isDisabledSave = checkIsDisabledToSave()
                }
                .onChange(of: showColor) {
                    updateCurrentColor(showColor)
                }
                .onChange(of: showDate) {
                    updateDate(showDate)
                }
        }
    }

    private func updateForm(_ selectedItem: TodoItem?) {
        categories = storage.getCategories()
        if let selectedItem {
            text = selectedItem.text
            selection = Int(selectedItem.importance.getIndex())
            if let color = selectedItem.color {
                currentColor = Color(hex: color)
                showColor = true
            }
            if let deadline = selectedItem.deadline {
                date = deadline
                showDate = true
            }
            if let index = categories.firstIndex(of: selectedItem.category) {
                selectionCategory = index
                if let categoryColor = selectedItem.category.color {
                    currentCategoryColor = Color(hex: categoryColor)
                }
            }
        } else {
            isDisabledDelete = true
        }
    }

    private func updateCurrentColor(_ showColor: Bool) {
        currentColor = showColor ? (currentColor == .clear) ? Color(UIColor.red) : currentColor : .clear
        isDisabledSave = checkIsDisabledToSave()
    }

    private func updateDate(_ showDate: Bool) {
        date = !showDate ? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date() : date
        isDisabledSave = checkIsDisabledToSave()
    }

    private func saveItem() {
        let deadline = showDate ? date : nil
        let color = showColor ? currentColorHex : nil
        let category: Category = selectionCategory > categories.count ? Category(name: title, color: customCategoryColor.toHexString()) : categories[selectionCategory]
        storage.updateItem(item: storage.createNewItem(item: modalState.selectedItem, text: text, importance: selection, deadline: deadline, color: color, category: category))
        modalState.activateModalView = false
    }
    
    @ViewBuilder
    private func chooseRightView() -> some View {
        if verticalSizeClass == .compact || horizontalSizeClass == .regular {
            HStack(spacing: 16) {
                ScrollView {
                    textArea
                }
                if !isHidden {
                    ScrollView {
                        settings
                    }
                }
            }
        } else {
            VStack(spacing: 16) {
                ScrollView {
                    textArea
                    settings
                }
            }
        }
    }
    
    private func checkIsDisabledToSave() -> Bool {
        guard !text.isEmpty,
              currentColorHex != modalState.selectedItem?.color && showColor ||
              !showColor && modalState.selectedItem?.color != nil ||
              !date.isEqualDay(with: modalState.selectedItem?.deadline) && showDate ||
              !showDate && modalState.selectedItem?.deadline != nil ||
              selection != modalState.selectedItem?.importance.getIndex() ||
              text != modalState.selectedItem?.text ||
              selectionCategory > categories.count && title != "" ||
              selectionCategory < categories.count && categories[selectionCategory].name != modalState.selectedItem?.category.name
        else { return true }
        return false
    }
}

#Preview {
    DetailsView(modalState: ModalState())
        .environmentObject(MainViewModel().storage)
}

