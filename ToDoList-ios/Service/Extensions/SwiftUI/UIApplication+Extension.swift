//
//  UIApplication+Extension.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 26.06.2024.
//

import SwiftUI

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
