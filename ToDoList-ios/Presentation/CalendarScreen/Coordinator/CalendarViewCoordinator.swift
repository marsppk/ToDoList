//
//  CalendarViewCoordinator.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 03.07.2024.
//

import UIKit
import Combine
import CocoaLumberjackSwift

@MainActor
class CalendarViewCoordinator: NSObject {
    var storage: StorageLogic
    var apiManager: DefaultNetworkingService
    var sections: [Date]
    var selectedItem = IndexPath(row: 0, section: 0)
    var isSelectedInCollectionView = false
    var view: CalendarView
    var modalState: ModalState
    var cancellables = Set<AnyCancellable>()
    init(storage: StorageLogic, modalState: ModalState, uiview: CalendarView, apiManager: DefaultNetworkingService) {
        self.apiManager = apiManager
        self.storage = storage
        self.sections = storage.getSections()
        self.view = uiview
        self.modalState = modalState
        super.init()
        storage.$isUpdated
            .sink { [weak self] value in
                guard let self = self else { return }
                if value {
                    DispatchQueue.main.async {
                        self.sections = self.storage.getSections()
                        self.reloadData()
                        storage.isUpdated = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    @objc func plusButtonPressed() {
        modalState.changeValues(item: nil)
    }
    func reloadData() {
        view.collectionView.reloadData()
        view.tableView.reloadData()
    }
    func updateData() {
        storage.loadItemsFromPersistence()
    }
    func countNumberOfSections() -> Int {
        var anotherCategory = 0
        if storage.getItemsForSection(section: sections.count).count != 0 {
            anotherCategory = 1
        }
        return storage.getItems().count == 0 ? 0 : sections.count + anotherCategory
    }
    func updateToDoItem(item: TodoItem) {
        storage.updateItemInPersistence(item: item)
        apiManager.incrementNumberOfTasks()
        updateToDoItemOnServer(item: item)
    }
    private func updateToDoItemOnServer(item: TodoItem, retryDelay: Int = Delay.minDelay) {
        Task {
            do {
                try await apiManager.updateTodoItem(item: item)
                storage.isUpdated = true
                apiManager.decrementNumberOfTasks()
                apiManager.isShownAlertWithNoConnection = false
                DDLogInfo("\(#function): the item has been updated successfully")
            } catch {
                DDLogError("\(#function): \(error.localizedDescription)")
                let error = error as? NetworkingErrors
                let isNeededRetry = error == NetworkingErrors.serverError || error == NetworkingErrors.noConnection
                if retryDelay < Delay.maxDelay, isNeededRetry {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                        self.updateToDoItemOnServer(
                            item: item,
                            retryDelay: Delay.countNextDelay(from: retryDelay)
                        )
                    }
                } else {
                    storage.updateIsDirty(value: true)
                    apiManager.decrementNumberOfTasks()
                    storage.isUpdated = true
                }
            }
        }
    }
}

extension CalendarViewCoordinator: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        countNumberOfSections()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        storage.getItemsForSection(section: section).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CalendarTableViewCell.identifier,
            for: indexPath
        ) as? CalendarTableViewCell else {
            return UITableViewCell()
        }
        let item = storage.getItemsForSection(section: indexPath.section)[indexPath.row]
        cell.setupTextLabel(item: item)
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == sections.count {
            return "Другое"
        }
        return sections[section].makePrettyString(dateFormat: "dd MMMM")
    }
}

extension CalendarViewCoordinator: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let doneAction = makeAction(isLeading: true, indexPath: indexPath, tableView: tableView)
        doneAction.image = UIImage(systemName: "checkmark.circle")
        doneAction.backgroundColor = .systemGreen
        let configuration = UISwipeActionsConfiguration(actions: [doneAction])
        return configuration
    }
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let unreadyAction = makeAction(isLeading: false, indexPath: indexPath, tableView: tableView)
        unreadyAction.image = UIImage(systemName: "checkmark.circle.badge.xmark")
        unreadyAction.backgroundColor = .systemGray
        let configuration = UISwipeActionsConfiguration(actions: [unreadyAction])
        return configuration
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        if let currentText = header.textLabel?.text {
            header.textLabel?.text = currentText == "ДРУГОЕ" ? currentText.capitalized : currentText.lowercased()
            header.textLabel?.font = .systemFont(ofSize: 16)
        }
    }
    func makeAction(isLeading: Bool, indexPath: IndexPath, tableView: UITableView) -> UIContextualAction {
        return UIContextualAction(style: .normal, title: nil) { (_, _, completionHandler) in
            let item = self.storage.getItemsForSection(section: indexPath.section)[indexPath.row]
            let check = isLeading ? !item.isDone : item.isDone
            if check {
                let newItem = self.storage.createItemWithAnotherIsDone(item: item)
                self.updateToDoItem(item: newItem)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            completionHandler(true)
        }
    }
}

extension CalendarViewCoordinator: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        countNumberOfSections()
    }
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarCollectionViewCell.identifier,
            for: indexPath
        ) as? CalendarCollectionViewCell else {
            return UICollectionViewCell()
        }
        if indexPath == selectedItem {
            cell.isSelected = true
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        if indexPath.row == sections.count {
            cell.setupUI(day: "Другое", month: "", isAnother: true)
        } else {
            let day = sections[indexPath.row].makePrettyString(dateFormat: "dd")
            let month = sections[indexPath.row].makePrettyString(dateFormat: "MMMM")
            cell.setupUI(day: day, month: month)
        }
        return cell
    }
}

extension CalendarViewCoordinator: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedItem != indexPath else { return }
        selectedItem = indexPath
        let indexPath = IndexPath(row: 0, section: indexPath.row)
        if isSelectedInCollectionView == false {
            isSelectedInCollectionView = true
        }
        view.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        view.collectionView.reloadData()
    }
}

extension CalendarViewCoordinator: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isSelectedInCollectionView = false
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableView = view.tableView
        if scrollView == tableView && !isSelectedInCollectionView {
            if let topIndexPath = tableView.indexPathsForVisibleRows?.first {
                let indexPath = IndexPath(row: topIndexPath.section, section: 0)
                selectedItem = indexPath
                view.collectionView.reloadData()
            }
        }
    }
}
