//
//  CometChatCallHistoyTVC.swift
//  Sample App
//
//  Created by Dawinder on 30/10/24.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift

#if canImport(CometChatCallsSDK)
public class CallHistoyTVC: UITableViewCell {
    static let identifier = "CallHistoyTVC"
    
    public lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        return imageView
    }()
    
    public lazy var titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = CometChatSpacing.Spacing.s1
        return stackView
    }()

    public lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Heading4.medium
        label.textColor = CometChatTheme.textColorPrimary
        return label
    }()

    public lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Body.regular
        label.textColor = CometChatTheme.textColorSecondary
        return label
    }()

    public lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Caption1.medium
        label.textAlignment = .right
        return label
    }()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setupUI() {
        selectionStyle = .none
        contentView.addSubview(cellImageView)
        contentView.addSubview(titleStack)
        titleStack.addArrangedSubview(nameLabel)
        titleStack.addArrangedSubview(dateLabel)
        contentView.addSubview(durationLabel)
        
        cellImageView.translatesAutoresizingMaskIntoConstraints = false
        titleStack.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            heightAnchor.constraint(equalToConstant: 65),
            
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cellImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            titleStack.leadingAnchor.constraint(equalTo: cellImageView.trailingAnchor, constant: 12),
            titleStack.centerYAnchor.constraint(equalTo: cellImageView.centerYAnchor),
            
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            durationLabel.centerYAnchor.constraint(equalTo: titleStack.centerYAnchor)
        ])
    }
}
#endif
