//
//  AIRepliesCell.swift
//  
//
//  Created by SuryanshBisen on 17/09/23.
//

import UIKit

class AIRepliesCell: UITableViewCell {
    
    let cellLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()
    let containerView = UIView().withoutAutoresizingMaskConstraints()
    var onButtonClicked: ((String) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
    
        selectionStyle = .none
        // Configure containerView
        containerView.backgroundColor = .clear
        containerView.addSubview(cellLabel)
        contentView.addSubview(containerView)
        
        // Apply constraints for cellLabel
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CometChatSpacing.Padding.p2),
            cellLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            cellLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            cellLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -CometChatSpacing.Padding.p2)
        ])
        
        // Apply constraints for containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CometChatSpacing.Padding.p1),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CometChatSpacing.Padding.p1)
        ])
    }
}
