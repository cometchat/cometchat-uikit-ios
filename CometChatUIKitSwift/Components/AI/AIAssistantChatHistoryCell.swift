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
        label.adjustsFontForContentSizeCategory = true
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
            messageLabel.text = Self.previewText(for: textMessage)
        }
    }

    /// A single-line preview: mention tags become "@Name" and markdown markers are stripped,
    /// so a row never shows raw `<@uid:…>` or `*…*` syntax.
    static func previewText(for message: TextMessage) -> String {
        var text = message.text
        if let regex = try? NSRegularExpression(pattern: "<@(uid|all):([^>]+)>") {
            let names = Dictionary(message.mentionedUsers.compactMap { user in user.uid.map { ($0, user.name ?? $0) } },
                                   uniquingKeysWith: { first, _ in first })
            let ns = text as NSString
            var result = ""
            var cursor = 0
            for match in regex.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
                result += ns.substring(with: NSRange(location: cursor, length: match.range.location - cursor))
                let kind = ns.substring(with: match.range(at: 1))
                let id = ns.substring(with: match.range(at: 2))
                result += kind == "all" ? "@all" : "@" + (names[id] ?? id)
                cursor = match.range.location + match.range.length
            }
            result += ns.substring(from: cursor)
            text = result
        }
        return RichTextFormatterManager.shared.stripMarkdown(text)
    }
}

