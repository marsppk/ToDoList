//
//  DetailsView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.06.2024.
//

import SwiftUI

struct DetailsView: View {
    @ObservedObject var modalState: ModalState
    @EnvironmentObject var viewModel: MainViewModel
    @State var text: String = ""
    @State var selection = 2
    @State var showDate = false
    @State var showCalendar = false
    @State var showColor = false
    @State var showPicker = false
    @State var currentColor: Color = .clear
    @State var date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State var isHidden = false
    @State var isDisabledSave = true
    @State var isDisabledDelete = false
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
            Toggle("", isOn: $showDate).onReceive([showDate].publisher.first(), perform: { value in
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
                .fill(.secondaryBG)
        )
    }
    
    var deleteButton: some View {
        Button(action: {
            if let id = modalState.selectedItem?.id {
                viewModel.deleteItem(id: id)
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
            RoundedRectangle(cornerRadius: 16)
                .fill(currentColor)
                .frame(width: 15, height: 5)
                .padding()
        }
        .frame(maxHeight: .infinity, alignment: .leading)
        .onTapGesture {
            UIApplication.shared.closeKeyboard()
        }
    }
    
    var settings: some View {
        VStack {
            VStack {
                importance
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
                            let deadline = showDate ? date : nil
                            let color = showColor ? currentColorHex : nil
                            viewModel.updateItem(item: viewModel.createNewItem(item: modalState.selectedItem, text: text, importance: selection, deadline: deadline, color: color))
                            modalState.activateModalView = false
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
        }
        .onReceive(modalState.$selectedItem) { selectedItem in
            if selectedItem == nil {
                isDisabledDelete = true
            }
            text = selectedItem?.text ?? ""
            selection = Int(selectedItem?.importance.getIndex() ?? 2)
            if let color = selectedItem?.color {
                currentColor = Color(hex: color)
                showColor = true
            }
            if let deadline = selectedItem?.deadline {
                date = deadline
                showDate = true
            }
        }
        .onChange(of: text) {
            isDisabledSave = checkIsDisabledToSave()
        }
        .onChange(of: showColor) {
            currentColor = showColor ? (currentColor == .clear) ? Color(UIColor.red) : currentColor : .clear
            isDisabledSave = checkIsDisabledToSave()
        }
        .onChange(of: showDate) {
            date = !showDate ? Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date() : date
            isDisabledSave = checkIsDisabledToSave()
        }
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
    
    @ViewBuilder
    func chooseRightView() -> some View {
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
    
    func checkIsDisabledToSave() -> Bool {
        guard !text.isEmpty,
              currentColorHex != modalState.selectedItem?.color && showColor ||
              !showColor && modalState.selectedItem?.color != nil ||
              !date.isEqualDay(with: modalState.selectedItem?.deadline) && showDate ||
              !showDate && modalState.selectedItem?.deadline != nil ||
              selection != modalState.selectedItem?.importance.getIndex() ||
              text != modalState.selectedItem?.text
        else { return true }
        return false
    }
}

#Preview {
    DetailsView(modalState: ModalState())
        .environmentObject(MainViewModel())
}

