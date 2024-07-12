//
//  Color+Extension.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 25.06.2024.
//

import SwiftUI

extension Color {
    func toHexString() -> String {
        let uic = UIColor(self)
        let components = uic.cgColor.components!
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        var alpha = Float(1.0)
        if components.count >= 4 {
            alpha = Float(components[3])
        }
        if alpha != Float(1.0) {
            return String(
                format: "#%02lX%02lX%02lX%02lX",
                lroundf(red * 255),
                lroundf(green * 255),
                lroundf(blue * 255),
                lroundf(alpha * 255)
            )
        } else {
            return String(
                format: "#%02lX%02lX%02lX",
                lroundf(red * 255),
                lroundf(green * 255),
                lroundf(blue * 255)
            )
        }
    }
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 1.0
        let length = hexSanitized.count
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        if length == 6 {
            red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            blue = CGFloat(rgb & 0x0000FF) / 255.0
        } else if length == 8 {
            red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            alpha = CGFloat(rgb & 0x000000FF) / 255.0
        }
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}
