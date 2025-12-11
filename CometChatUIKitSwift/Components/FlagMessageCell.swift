//
//  FlagMessageCell.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 20/11/25.
//

import Foundation
import UIKit
import CometChatSDK

final class FlagMessageCell: UICollectionViewCell {

    static let reuseId = "ReportReasonCell"

    private let label = UILabel()

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    private func setup() {
        contentView.layer.cornerRadius = 14
        contentView.layer.borderWidth = 1

        label.font = CometChatTypography.Body.regular
        label.textColor = CometChatTheme.textColorPrimary

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])

        updateAppearance()
    }

    private func updateAppearance() {
        if isSelected {
            contentView.backgroundColor = CometChatTheme.extendedPrimaryColor100
            contentView.layer.borderColor = CometChatTheme.extendedPrimaryColor200.cgColor
            label.textColor = CometChatTheme.textColorHighlight
        } else {
            contentView.backgroundColor = CometChatTheme.backgroundColor01
            contentView.layer.borderColor = CometChatTheme.borderColorDefault.cgColor
            label.textColor = CometChatTheme.textColorPrimary
        }
    }

    func configure(_ item: String) {
        label.text = item
    }
}
