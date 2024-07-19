//
//  MainView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 15.06.2024.
//

import SwiftUI
import CocoaLumberjackSwift

struct MainView: View {
    @StateObject private var viewModel = MainViewModel(
        deviceID: UIDevice.current.identifierForVendor?.uuidString ?? ""
    )
    @StateObject private var modalState = ModalState()
    init() {
        setupLogger()
    }
    var menu: some View {
        Menu {
            Button(
                action: {
                    viewModel.changeShowButtonValue()
                    viewModel.updateSortedItems(items: Array(viewModel.storage.getItems().values))
                },
                label: {
                    Text(viewModel.showButtonText)
                }
            )
            Button(
                action: {
                    viewModel.changeSortButtonValue()
                    viewModel.updateSortedItems(items: Array(viewModel.storage.getItems().values))
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
        HStack {
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
                            viewModel.updateItem(
                                item: viewModel.storage.createItemWithAnotherIsDone(
                                    item: item.wrappedValue
                                )
                            )
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
                    .frame(minHeight: 56)
            }
            footer
                .gesture(
                    TapGesture().onEnded {
                        modalState.changeValues(item: nil)
                    }
                )
                .frame(minHeight: 56)
        } header: {
            sectionHeader
                .frame(minHeight: 45)
                .padding(.trailing, 16)
        }
        .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 0))
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
            }
        )
    }
    var calendarView: some View {
        CalendarView(storage: $viewModel.storage, apiManager: $viewModel.apiManager, modalState: modalState)
            .navigationTitle("Мои дела")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color.primaryBG)
            .onAppear {
                DDLogInfo("\(#function): CalendarView appeared")
            }
            .onDisappear {
                DDLogInfo("\(#function): CalendarView disappeared")
            }
    }
    var content: some View {
        VStack {
            List {
                section
            }
            .navigationTitle("Мои дела")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        Button(action: {
                            modalState.activateModalView = false
                            modalState.activateCalendarView = true
                        }, label: {
                            Image(systemName: "calendar")
                        })
                    } else {
                        NavigationLink {
                            calendarView
                        } label: {
                            Image(systemName: "calendar")
                        }
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isActive {
                        ProgressView()
                    }
                }
            }
        }.safeAreaInset(edge: VerticalEdge.bottom) {
            plusButton
        }
    }
    var body: some View {
        chooseView()
        .onAppear {
            DDLogInfo("\(#function): MainView appeared")
            viewModel.loadItems()
        }
        .onDisappear {
            DDLogInfo("\(#function): MainView disappeared")
        }
        .modifier(SheetModifier(modalState: modalState, storage: viewModel.storage, apiManager: viewModel.apiManager))
        .modifier(AlertModifier(apiManager: viewModel.apiManager))
    }
    @ViewBuilder
    func chooseView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationSplitView {
                content
            } detail: {
                if modalState.activateModalView {
                    DetailsView(modalState: modalState, viewModel: DetailsViewModel(apiManager: viewModel.apiManager))
                        .environmentObject(viewModel.storage)
                }
                if modalState.activateCalendarView {
                    calendarView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        } else {
            NavigationStack {
                content
            }
        }
    }
    func setupLogger() {
        let consoleLogger = DDOSLogger.sharedInstance
        consoleLogger.logFormatter = LogFormatter()
        DDLog.add(consoleLogger)
    }
}

#Preview {
    MainView()
}
