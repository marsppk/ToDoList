//
//  UINavigationController+Extension.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 12.07.2024.
//

import UIKit

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
    }
}
