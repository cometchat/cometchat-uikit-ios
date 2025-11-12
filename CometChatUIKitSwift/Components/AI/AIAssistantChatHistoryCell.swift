//
//  AIAssistantChatHistoryCell.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 18/09/25.
//

import Foundation
import UIKit
import CometChatSDK

class AIAssistantChatHistoryCell: UITableViewCell {
    static let identifier = "AIAssistantChatHistoryCell"

    public let messageLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Body.regular
        label.textColor = CometChatTheme.textColorPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.text = nil
    }

    func configure(with message: BaseMessage) {
        if let textMessage = message as? TextMessage {
            messageLabel.text = textMessage.text
        }
    }
}

