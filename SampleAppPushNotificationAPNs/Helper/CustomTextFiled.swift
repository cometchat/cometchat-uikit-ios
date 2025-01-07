//
//  CustomTextFiled.swift
//  CometChatUIKit
//
//  Created by Suryansh on 25/12/24.
//

import UIKit
import CometChatUIKitSwift

class CustomTextFiled: UIStackView {
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UID"
        label.textColor = CometChatTheme.textColorPrimary
        label.font = CometChatTypography.Body.regular
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        return label
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter Your UID"
        textField.font = CometChatTypography.Body.regular
        textField.textColor = CometChatTheme.textColorPrimary.withAlphaComponent(0.4)
        return textField
    }()
    
    init(leadingText: String, placeholderText: String) {
        super.init(frame: .infinite)
        
        label.text = leadingText
        textField.placeholder = placeholderText
        buildUI()
    }
    
    func buildUI() {
        self.spacing = 0
        self.axis = .horizontal
        self.distribution = .fillProportionally
        self.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let bottomBorderView = UIView()
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        bottomBorderView.backgroundColor = CometChatTheme.textColorPrimary.withAlphaComponent(0.4)
        self.addSubview(bottomBorderView)
        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: bottomBorderView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: bottomBorderView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: bottomBorderView.trailingAnchor)
        ])
        
        self.addArrangedSubview(label)
        self.addArrangedSubview(textField)

    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
