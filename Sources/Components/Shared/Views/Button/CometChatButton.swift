//
//  CometChatImageBubble.swift
//
//
//  Created by Abdullah Ansari on 19/12/22.
//

import UIKit
import QuickLook

public class CometChatButton: UIStackView {
    
    private (set) var icon: UIImage? = UIImage(systemName: "xmark")
    private (set) var text: String?
    private (set) var style: ButtonStyle?
    private (set) var button : UIButton?
    private (set) var label : UILabel?
    private (set) var controller: UIViewController?
    private (set) var onClick: (() -> Void)?
    
    public init(width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.axis = .vertical
        self.alignment = .center
        self.spacing = 2
        
        button = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        if let button = button {
            button.addTarget(self, action: #selector(onButtonClick), for: .touchUpInside)
            self.addArrangedSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 20))
        if let label = label {
            let emptyView = UIView()
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            emptyView.heightAnchor.constraint(equalToConstant: 10).isActive = true
            self.addArrangedSubview(label)
            self.addArrangedSubview(emptyView)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func set(text: String) -> Self {
        if !text.isEmpty {
            self.label?.text = text
            self.label?.isHidden = false
        } else {
            self.label?.text = ""
            self.label?.isHidden = true
        }
        return self
    }
    
    @discardableResult
    public func set(icon: UIImage) -> Self {
        button?.setImage(icon, for: .normal)
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (() -> Void)) -> Self {
        self.onClick = onClick
        return self
    }
    
    @discardableResult
    public func set(backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func set(cornerRadius: CometChatCornerStyle) -> Self {
        self.roundViewCorners(corner: cornerRadius)
        return self
    }
    
    @discardableResult
    private func set(borderWidth: CGFloat) -> Self {
        self.borderWith(width: borderWidth)
        return self
    }
    
    @discardableResult
    private func set(borderColor: UIColor) -> Self {
        self.borderColor(color: borderColor)
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func disable(button: Bool) -> Self {
        self.button?.isEnabled = !button
        return self
    }
    
    @objc func onButtonClick() {
        onClick?()
    }
    
    @discardableResult
    public func set(style: ButtonStyle) -> Self {
        self.style = style
        applyStyle(style: style)
        return self
    }
    
    private func applyStyle(style: ButtonStyle) {
        if let button = button {
            button.tintColor = style.iconTint
            button.backgroundColor = style.iconBackground
            button.layer.cornerRadius = style.iconCornerRadius ?? 0
            button.clipsToBounds  = true
        }
        if let label = label {
            label.textColor = style.textColor
            label.font = style.textFont
        }
    }
    
    
}


