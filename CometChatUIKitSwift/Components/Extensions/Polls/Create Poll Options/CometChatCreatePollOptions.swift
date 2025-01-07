//
//  CometChatCreatePollOptions.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 16/09/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit

protocol CometChatCreatePollOptionsDelegate: AnyObject {
    func didStartEditingOption(at index: Int, with string: String)
}

class CometChatCreatePollOptions: UITableViewCell, UITextFieldDelegate {

    // MARK: - UI Elements
    lazy var containerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    lazy var options: UITextField = {
        let textField = UITextField().withoutAutoresizingMaskConstraints()
        textField.placeholder = "Add"
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    lazy var reorderButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.pin(anchors: [.height, .width], to: 24)
        return button
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.pin(anchors: [.height, .width], to: 24)
        return button
    }()
    
    lazy var optionStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [reorderButton, containerView, deleteButton]).withoutAutoresizingMaskConstraints()
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = CometChatSpacing.Spacing.s2
        return stack
    }()
    
    var index: Int?
    weak var delegate: CometChatCreatePollOptionsDelegate?
    var textChanged: ((String?, Int) -> Void)?
    var editingEnd: ((String) -> ())?
    var deleteOption: (() -> ())?

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup UI
    private func setupCell() {
        self.selectionStyle = .none
        
        contentView.addSubview(optionStack)
        containerView.addSubview(options)
        
        setupConstraints()
        options.delegate = self
    }
    
    // MARK: - Constraints Setup
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Constraints for optionStack in contentView
            optionStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CometChatSpacing.Spacing.s2),
            optionStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CometChatSpacing.Spacing.s4),
            optionStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -(CometChatSpacing.Spacing.s1)),
            optionStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(CometChatSpacing.Spacing.s4)),

            // Constraints for containerView
            containerView.heightAnchor.constraint(equalToConstant: 36),

            // Constraints for options (UITextField) inside containerView
            options.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Padding.p2),
            options.topAnchor.constraint(equalTo: containerView.topAnchor),
            options.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            options.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -(CometChatSpacing.Padding.p2))
        ])
        deleteButton.addTarget(self, action: #selector(onDeleteOption), for: .touchUpInside)
    }
    
    @objc func onDeleteOption(){
        self.deleteOption?()
    }

    // MARK: - UITextFieldDelegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let index = index {
            delegate?.didStartEditingOption(at: index, with: textField.text ?? "")
        }
    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        if let index = index {
            textChanged?(textField.text, index)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        editingEnd?(textField.text ?? "")
    }
}

