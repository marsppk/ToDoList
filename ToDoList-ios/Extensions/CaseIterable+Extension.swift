//
//  CaseIterable+Extension.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 25.06.2024.
//

import Foundation

extension CaseIterable where Self: Equatable {
    func getIndex() -> Self.AllCases.Index {
        return Self.allCases.firstIndex(of: self)!
    }
}
