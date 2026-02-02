//
//  UnreadMessageSeparatorCell.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 07/01/26.
//

import Foundation
import UIKit

final class UnreadSeparatorCell: UITableViewCell {
    
    static let identifier = "UnreadSeparatorCell"

    private let label: UILabel = {
        let l = UILabel()
        l.text = "New"
        l.textAlignment = .center
        return l
    }()

    private let lineLeft = UIView()
    private let lineRight = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        // Disable autoresizing masks
        lineLeft.translatesAutoresizingMaskIntoConstraints = false
        lineRight.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [lineLeft, label, lineRight])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill // Changed from fillProportionally

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Line heights
            lineLeft.heightAnchor.constraint(equalToConstant: 1),
            lineRight.heightAnchor.constraint(equalToConstant: 1),
            
            // Make lines equal width and flexible
            lineLeft.widthAnchor.constraint(equalTo: lineRight.widthAnchor),
        ])
        
        // Label should hug its content
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func setStyle(_ style: MessageListStyle) {
        label.font = style.newMessageIndicatorTextFont
        label.textColor = style.newMessageIndicatorTextColor
        lineLeft.backgroundColor = style.newMessageIndicatorBackgroundColor
        lineRight.backgroundColor = style.newMessageIndicatorBackgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCustomView(_ view: UIView) {
        label.isHidden = true
        lineLeft.isHidden = true
        lineRight.isHidden = true
        
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}

