//
//  UIView+Extension.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 04.07.2024.
//

import UIKit

extension UIView {
    func addShadow(height: Double, radius: CGFloat) {
        self.layer.shadowOffset = CGSize(width: 0.0, height: height)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = radius
    }
}
