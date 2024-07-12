//
//  UIImage+Extension.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 03.07.2024.
//

import UIKit

extension UIImage {
    func resize(withSize size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
