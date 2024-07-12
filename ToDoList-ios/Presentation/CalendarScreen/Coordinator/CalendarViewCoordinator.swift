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
    var sections: [Date]
    var selectedItem = IndexPath(row: 0, section: 0)
    var view: CalendarView
    var isSelectedFromCollectionView = false
    var modalState: ModalState
    var cancellables = Set<AnyCancellable>()
    init(storage: StorageLogic, modalState: ModalState, uiview: CalendarView) {
        self.storage = storage
        self.sections = storage.getSections()
        self.view = uiview
        self.modalState = modalState
        super.init()
        storage.$isUpdated
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.sections = self.storage.getSections()
                self.reloadData()
            }
            .store(in: &cancellables)
    }
    @objc func plusButtonPressed() {
        modalState.changeValues(item: nil)
    }
    func updateData() {
        do {
            try storage.loadItemsFromJSON()
        } catch {
           DDLogError("\(#function): \(error.localizedDescription)")
        }
    }
    func reloadData() {
        view.collectionView.reloadData()
        view.tableView.reloadData()
    }
    func countNumberOfSections() -> Int {
        var anotherCategory = 0
        if storage.getItemsForSection(section: sections.count).count != 0 {
            anotherCategory = 1
        }
        return storage.getItems().count == 0 ? 0 : sections.count + anotherCategory
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
                self.storage.updateItem(item: self.storage.createItemWithAnotherIsDone(item: item))
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
        view.collectionView.deselectItem(at: selectedItem, animated: false)
        [selectedItem, indexPath].forEach {
            if let cell = collectionView.cellForItem(at: $0) as? CalendarCollectionViewCell {
                cell.configureCell()
            }
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        selectedItem = indexPath
        let indexPath = IndexPath(row: 0, section: indexPath.row)
        isSelectedFromCollectionView = true
        view.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        isSelectedFromCollectionView = false
    }
}

extension CalendarViewCoordinator: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView, !isSelectedFromCollectionView else { return }
        if let topIndexPath = tableView.indexPathsForVisibleRows?.first {
            let indexPath = IndexPath(row: topIndexPath.section, section: 0)
            view.collectionView.deselectItem(at: selectedItem, animated: false)
            view.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            selectedItem = indexPath
            view.collectionView.reloadData()
        }
    }
}
