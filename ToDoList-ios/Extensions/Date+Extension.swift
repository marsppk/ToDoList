//
//  Date+Extension.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 26.06.2024.
//

import Foundation

extension Date {
    private func makeFormatter(dateFormat: String) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "ru")
        return dateFormatter
    }
    
    func makePrettyString(dateFormat: String) -> String {
        return makeFormatter(dateFormat: dateFormat).string(from: self)
    }
    
    func isEqualDay(with anotherDate: Date?) -> Bool {
        guard let anotherDate = anotherDate else { return false }
        let calendar = Calendar.current
        let result = calendar.compare(self, to: anotherDate, toGranularity: .day)
        switch result {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    
    func makeEqualDates() -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)
    }
}
