//
//  AIConversationStarterCell.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 18/11/24.
//

import Foundation
import UIKit

class AIConversationStarterCell: UITableViewCell {

    let cellLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let containerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    var onButtonClicked: ((String) -> Void)?
    
    private var trailingConstraint: NSLayoutConstraint!
    
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
        contentView.addSubview(containerView)
        containerView.addSubview(cellLabel)
        
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CometChatSpacing.Padding.p2),
            cellLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Padding.p5),
            cellLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -CometChatSpacing.Padding.p2)
        ])
        
        trailingConstraint = cellLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -CometChatSpacing.Padding.p5)
        trailingConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CometChatSpacing.Padding.p1),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CometChatSpacing.Padding.p),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CometChatSpacing.Padding.p1)
        ])
        
        trailingConstraint = containerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -CometChatSpacing.Padding.p)
        trailingConstraint.isActive = true
    }
    
    func configure(with text: String, maxWidth: CGFloat) {
        cellLabel.text = text
        
        if cellLabel.intrinsicContentSize.width > (self.contentView.frame.width + 50){
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -CometChatSpacing.Padding.p).isActive = true
        }else{
            trailingConstraint.isActive = false
        }
                
        layoutIfNeeded()
    }
}

