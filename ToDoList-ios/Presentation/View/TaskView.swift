//
//  TaskView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 22.06.2024.
//

import SwiftUI

struct TaskView: View {
    @Binding var item: TodoItem
    @EnvironmentObject var viewModel: MainViewModel
    @EnvironmentObject var modalState: ModalState
    
    var circleBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(item.importance == .important && !item.isDone ? .red.opacity(0.2) : .clear)
            .frame(width: 24, height: 24)
    }
    
    var circleImage: some View {
        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(item.isDone ? .green : (item.importance == .important ? .red : .gray))
            .background(circleBackground)
            .gesture(
                TapGesture().onEnded {
                    viewModel.updateItem(item: viewModel.createItemWithAnotherIsDone(item: item))
                }
            )
    }
    
    var textWithExclamationMark: some View {
        Text(Image(systemName: "exclamationmark.2")).foregroundStyle(.red) + Text(item.text)
    }
    
    var chevronButton: some View {
        Button(
            action: {
                modalState.changeValues(item: item)
            },
            label: {
                Image(systemName: "chevron.right")
            }
        )
    }
    
    var deadlineLabel: some View {
        (Text(Image(systemName: "calendar")) + Text(item.deadline?.makePrettyString(dateFormat: "d MMMM") ?? ""))
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        HStack {
            circleImage
            VStack {
                chooseTextStyle()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .modifier(ColorModifier(todoItem: $item))
                if item.deadline != nil {
                    deadlineLabel
                }
            }
            chevronButton
                .foregroundStyle(.gray)
                .modifier(SheetModifier(modalState: modalState, viewModel: viewModel))
            
        }
        .lineLimit(3)
        .padding([.bottom, .top], 8)
    }
    
    @ViewBuilder
    func chooseTextStyle() -> some View {
        switch (item.importance, item.isDone) {
        case (.important, false):
            textWithExclamationMark
        default:
            Text(item.text)
        }
    }
}

