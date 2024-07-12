//
//  CalendarTableViewCell.swift
//  ToDoList-ios
//
//  Created by Maria Slepneva on 03.07.2024.
//

import SwiftUI

class CalendarTableViewCell: UITableViewCell {
    static let identifier = "StrikethroughTableViewCell"
    var circle: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        view.layer.cornerRadius = view.bounds.size.width/2
        view.addShadow(height: 4, radius: 3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    override func prepareForReuse() {
        textLabel?.attributedText = nil
        circle.removeFromSuperview()
    }
    func setupTextLabel(item: TodoItem) {
        self.addSubview(circle)
        NSLayoutConstraint.activate([
            circle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            circle.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            circle.widthAnchor.constraint(equalToConstant: 15),
            circle.heightAnchor.constraint(equalToConstant: 15)
        ])
        if item.isDone {
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
            ]
            let attributedText = NSAttributedString(string: item.text, attributes: attributes)
            textLabel?.attributedText = attributedText
            textLabel?.textColor = .gray
            circle.backgroundColor = .clear
        } else {
            textLabel?.text = item.text
            textLabel?.textColor = .label
            if let color = item.category.color {
                circle.backgroundColor = UIColor(Color(hex: color))
            } else {
                circle.backgroundColor = .clear
            }
        }
    }
}
