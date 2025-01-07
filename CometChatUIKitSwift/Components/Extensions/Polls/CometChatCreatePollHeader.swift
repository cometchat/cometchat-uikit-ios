//
//  CometChatCreatePollHeader.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 12/10/24.
//

import UIKit

class CometChatCreatePollHeader: UITableViewCell {
    
    lazy var backView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    lazy var headerLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = "Create Poll"
        return label
    }()
    
    lazy var headerCrossButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.pin(anchors: [.height, .width], to: 24)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.imageView?.tintColor = CometChatTheme.iconColorPrimary
        button.addTarget(self, action: #selector(crossButtonPressed), for: .touchUpInside)
        return button
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height], to: 1)
        return view
    }()
    
    var onCrossTapped: (() -> ())?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        // Adding subviews and setting constraints
        contentView.embed(backView)
        backView.addSubview(headerLabel)
        backView.addSubview(headerCrossButton)
        backView.addSubview(separatorView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Constraints for the separator
        separatorView.pin(anchors: [.leading, .bottom, .trailing], to: backView)
        
        // Constraints for the header label
        headerLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: CometChatSpacing.Padding.p3).isActive = true
        headerLabel.trailingAnchor.constraint(equalTo: headerCrossButton.leadingAnchor, constant: -CometChatSpacing.Padding.p3).isActive = true
        headerLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: CometChatSpacing.Padding.p3).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: separatorView.topAnchor, constant: -CometChatSpacing.Padding.p3).isActive = true
        
        // Constraints for the cross button
        headerCrossButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -CometChatSpacing.Padding.p3).isActive = true
        headerCrossButton.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor).isActive = true
    }
    
    @objc func crossButtonPressed() {
        onCrossTapped?()
    }
}
