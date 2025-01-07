//
//  CometChatCreatePollQuestions.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 16/09/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit

class CometChatCreatePollQuestions: UITableViewCell, UITextFieldDelegate {

    lazy var question: UITextField = {
        let textField = UITextField().withoutAutoresizingMaskConstraints()
        textField.placeholder = "Ask question"
        textField.borderStyle = .none
        return textField
    }()
    
    lazy var containerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
        question.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupCell() {
        self.selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(question)
        
        setupConstraints()
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Constraints for containerView
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.heightAnchor.pin(equalToConstant: 44),

            // Constraints for question textField inside containerView
            question.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Padding.p4),
            question.topAnchor.constraint(equalTo: containerView.topAnchor, constant: CometChatSpacing.Padding.p2),
            question.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -(CometChatSpacing.Padding.p2)),
            question.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -(CometChatSpacing.Padding.p4))
        ])
    }
}
