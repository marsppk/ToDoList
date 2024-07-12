//
//  CalendarView.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 03.07.2024.
//

import SwiftUI

struct CalendarView: UIViewRepresentable {
    @Binding var storage: StorageLogic
    @ObservedObject var modalState: ModalState
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(CalendarTableViewCell.self, forCellReuseIdentifier: CalendarTableViewCell.identifier)
        tableView.backgroundColor = .primaryBG
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            CalendarCollectionViewCell.self,
            forCellWithReuseIdentifier: CalendarCollectionViewCell.identifier
        )
        collectionView.backgroundColor = .primaryBG
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    private let plusButton: UIButton = {
        guard let image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.systemBlue) else { return UIButton() }
        let resizedImage = image.resize(withSize: CGSize(width: 50, height: 50))
        let plusButton = UIButton()
        plusButton.addShadow(height: 8, radius: 10)
        plusButton.setImage(resizedImage, for: .normal)
        return plusButton
    }()
    func makeCoordinator() -> CalendarViewCoordinator {
        CalendarViewCoordinator(storage: storage, modalState: modalState, uiview: self)
    }
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        setupCoordinatorProperties(context: context)
        let divider1 = makeDivider()
        let divider2 = makeDivider()
        [divider1, collectionView, divider2, tableView, plusButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        NSLayoutConstraint.activate([
            divider1.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.topAnchor.constraint(equalTo: divider1.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 96),
            divider2.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: divider2.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        if modalState.didDismiss {
            DispatchQueue.main.async {
                context.coordinator.updateData()
                modalState.didDismiss = false
            }
        }
    }
    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .gray
        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        return divider
    }
    private func setupCoordinatorProperties(context: Context) {
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.delegate = context.coordinator
        plusButton.addTarget(context.coordinator, action: #selector(Coordinator.plusButtonPressed), for: .touchUpInside)
    }
}
