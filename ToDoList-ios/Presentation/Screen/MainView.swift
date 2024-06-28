//
//  MainView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 15.06.2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @StateObject var modalState = ModalState()
    
    var menu: some View {
        Menu {
            Button(
                action: {
                    viewModel.changeShowButtonValue()
                    viewModel.updateSortedItems()
                },
                label: {
                    Text(viewModel.showButtonText)
                }
            )
            Button(
                action: {
                    viewModel.changeSortButtonValue()
                    viewModel.updateSortedItems()
                },
                label: {
                    Text(viewModel.sortButtonText)
                }
            )
        } label: {
            Label {
                Image(systemName: "slider.horizontal.3")
                    .resizable()
                    .frame(width: 18, height: 18)
            } icon: {
                Text("")
            }
        }
    }
    
    var sectionHeader: some View {
        HStack() {
            Text("Выполнено — \(viewModel.count)")
                .frame(maxWidth: .infinity, alignment: .leading)
            menu
        }
        .textCase(nil)
        .font(.system(size: 17))
        .padding(.bottom, 12)
    }
    
    var footer: some View {
        Text("Новое")
            .padding(.leading, 34)
            .padding([.bottom, .top], 8)
            .foregroundStyle(.gray)
    }
    
    var section: some View {
        Section {
            ForEach($viewModel.sortedItems) { item in
                TaskView(item: item)
                    .environmentObject(viewModel)
                    .environmentObject(modalState)
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.updateItem(item: viewModel.createItemWithAnotherIsDone(item: item.wrappedValue))
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteItem(id: item.wrappedValue.id)
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                        Button {
                            modalState.changeValues(item: item.wrappedValue)
                        } label: {
                            Image(systemName: "info.circle.fill")
                        }
                        .tint(.buttonGray)
                    }
            }
            footer
                .gesture(
                    TapGesture().onEnded {
                        modalState.changeValues(item: nil)
                    }
                )
        } header: {
            sectionHeader
        }
    }
    
    var plusButton: some View {
        Button(
            action: {
                modalState.changeValues(item: nil)
            },
            label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .shadow(color: Color.shadow, radius: 20, x: 0, y: 8)
                    .modifier(SheetModifier(modalState: modalState, viewModel: viewModel))

            }
        )
    }
    
    var content: some View {
        VStack {
            List() {
                section
            }
            .navigationTitle("Мои дела")
            .scrollContentBackground(.hidden)
            .background(Color.primaryBG)
        }.safeAreaInset(edge: VerticalEdge.bottom) {
            plusButton
        }
    }
    
    var body: some View {
        chooseView()
        .onAppear {
            do {
                try viewModel.loadItemsFromJSON()
            } catch {
                print("Ошибка при загрузке данных из JSON: \(error)")
            }
        }
    }
    
    @ViewBuilder
    func chooseView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationSplitView {
                content
            } detail: {
                if modalState.activateModalView {
                    DetailsView(modalState: modalState)
                        .environmentObject(viewModel)
                }
            }
        } else {
            NavigationStack {
                content
            }
        }
    }
}

#Preview {
    MainView()
}

