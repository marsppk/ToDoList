//
//  LogFormatter.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 12.07.2024.
//

import CocoaLumberjackSwift

class LogFormatter: NSObject, DDLogFormatter {
    let dateFormatter: DateFormatter

    override init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        super.init()
    }

    func format(message logMessage: DDLogMessage) -> String? {
        let timestamp = dateFormatter.string(from: logMessage.timestamp)
        let logLevel = logMessage.level
        let logText = logMessage.message
        return "\(timestamp) [\(logLevel)] - \(logText)"
    }
}
