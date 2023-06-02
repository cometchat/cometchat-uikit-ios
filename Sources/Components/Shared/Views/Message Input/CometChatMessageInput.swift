//
//  CometChatMessageInput.swift
//  
//
//  Created by Ajay Verma on 16/12/22.
//

import UIKit

public enum AuxilaryButtonAlignment {
    case left
    case right
}

@objc @IBDesignable public class CometChatMessageInput: UIView {
    //MARK: Declaration of outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var buttonsContainer: UIStackView!
    @IBOutlet weak var secondaryButtonContainer: UIStackView!
    @IBOutlet weak var auxilaryButtonsContainer: UIStackView!
    @IBOutlet weak var primaryButtonContainer: UIStackView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    //MARK: Declaration of variables
    private(set) var text: String?
    private(set) var maxLine: Int? = 5
    var onChange: ((String) -> ())?
    var shouldBeginEditing: ((Bool) -> ())?
    var shouldEndEditing: ((Bool) -> ())?
    private(set) var auxilaryButtonAignment: AuxilaryButtonAlignment = .left
    private(set) var secondaryButtonView: UIView?
    private(set) var auxilaryButtonView: UIView?
    private(set) var primaryButtonView: UIView?
    private(set) var placeholderText: String = "TYPE_A_MESSAGE".localize()
    private(set) var messageInputStyle = MessageInputStyle()


    // MARK: - Initialization of required Methods
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        setupAppearance()
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
    }
    
    private func setupAppearance() {
        self.textView.delegate = self
        topView.roundViewCorners(corner: CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: false, bottomRight: false, cornerRadius: 18))
        bottomView.roundViewCorners(corner: CometChatCornerStyle(topLeft: false, topRight: false, bottomLeft: true, bottomRight: true, cornerRadius: 18))
        self.containerView.backgroundColor = messageInputStyle.background
    }
    
}

extension CometChatMessageInput: GrowingTextViewDelegate {
    
    public func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
        self.heightConstant.constant = height
    }
    
    public func growingTextViewDidChange(_ growingTextView: GrowingTextView) {
        onChange?(growingTextView.text ?? "")
        if growingTextView.text?.count == 0 {
            
        }
    }
    
    func growingTextViewShouldBeginEditing(_ growingTextView: GrowingTextView) -> Bool {
        shouldBeginEditing?(true)
        return true
    }
    
    func growingTextViewShouldEndEditing(_ growingTextView: GrowingTextView) -> Bool {
        shouldEndEditing?(true)
        return true
    }
}

extension CometChatMessageInput {
    
    @discardableResult
    public func set(messageInputStyle: MessageInputStyle) -> Self {
        set(textFont: messageInputStyle.textFont)
        set(textColor: messageInputStyle.textColor)
        set(placeHolderTextColor: messageInputStyle.placeHolderTextColor)
        set(placeHolderTextFont: messageInputStyle.placeHolderTextFont)
        set(dividerColor: messageInputStyle.dividerColor)
        set(inputBackgroundColor: messageInputStyle.inputBackground)
        return self
    }
    
    @discardableResult
    @objc public func set(maxLines: Int) -> Self {
        self.textView.maxNumberOfLines = maxLines
        return self
    }
    
    @discardableResult
    public func set(text: String) ->  Self {
        self.text = text
        textView.text = text
        onChange?(text)
        return self
    }
    
    @discardableResult
    public func append(text: String) -> Self {
        textView.text?.append(text)
        onChange?(text)
        return self
    }
    
    @discardableResult
    public func set(primaryButtonView: UIView) -> Self {
        self.primaryButtonView = primaryButtonView
        primaryButtonContainer.subviews.forEach({ $0.removeFromSuperview() })
        primaryButtonContainer.addArrangedSubview(primaryButtonView)
        return self
    }
    
    @discardableResult
    public func set(secondaryButtonView: UIView) -> Self {
        self.secondaryButtonView = secondaryButtonView
        secondaryButtonContainer.subviews.forEach({ $0.removeFromSuperview() })
        secondaryButtonContainer.addArrangedSubview(secondaryButtonView)
        return self
    }
    
    @discardableResult
    public func set(auxilaryButtonView: UIView) -> Self {
        self.auxilaryButtonView = auxilaryButtonView
        self.auxilaryButtonsContainer.subviews.forEach({ $0.removeFromSuperview() })
        self.auxilaryButtonsContainer.addArrangedSubview(auxilaryButtonView)
        return self
    }
    
    @discardableResult
    public func set(auxilaryButtonAignment: AuxilaryButtonAlignment) -> Self {
        self.auxilaryButtonAignment = auxilaryButtonAignment
        if auxilaryButtonAignment == .right {
            self.buttonsContainer.removeArrangedSubview(auxilaryButtonsContainer)
            self.buttonsContainer.insertArrangedSubview(auxilaryButtonsContainer, at: 2)
            self.buttonsContainer.setNeedsLayout()
            self.buttonsContainer.layoutIfNeeded()
        }
        return self
    }
    
    @discardableResult
    public func set(placeholderText: String) -> Self {
        self.placeholderText = placeholderText
        self.textView.placeholder = NSAttributedString(string:  self.placeholderText, attributes: [.foregroundColor: messageInputStyle.placeHolderTextColor,.font:  messageInputStyle.placeHolderTextFont])
        return self
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        self.textView.font = messageInputStyle.textFont
        return self
    }
    
    @discardableResult
    public func set(cornerRadius: CometChatCornerStyle) -> Self {
        self.topView.roundViewCorners(corner: CometChatCornerStyle(topLeft: true, topRight:  true, bottomLeft: false, bottomRight:false, cornerRadius: cornerRadius.cornerRadius))
        self.bottomView.roundViewCorners(corner: CometChatCornerStyle(topLeft: false, topRight:  false, bottomLeft: true, bottomRight: true, cornerRadius: cornerRadius.cornerRadius))
        return self
    }

    @discardableResult
    public func set(textColor: UIColor) -> Self {
        self.textView.textColor = textColor
        return self
    }

    @discardableResult
    public func set(placeHolderTextColor: UIColor) -> Self {
        self.textView.placeholder = NSAttributedString(string:  placeholderText, attributes: [.foregroundColor: placeHolderTextColor,.font:  messageInputStyle.placeHolderTextFont])
        return self
    }

    @discardableResult
    public func set(placeHolderTextFont: UIFont) -> Self {
        self.textView.placeholder = NSAttributedString(string:  placeholderText, attributes: [.foregroundColor: messageInputStyle.placeHolderTextColor,.font:  messageInputStyle.placeHolderTextFont])
        return self
    }

    @discardableResult
    public func set(dividerColor: UIColor) -> Self {
        self.divider.backgroundColor = dividerColor
        return self
    }

    @discardableResult
    public func set(inputBackgroundColor: UIColor) -> Self {
        self.bottomView.backgroundColor = inputBackgroundColor
        self.topView.backgroundColor = inputBackgroundColor
        return self
    }

    public func build() {
        self.textView.font = messageInputStyle.textFont
        self.textView.textColor = messageInputStyle.textColor
        self.divider.backgroundColor = messageInputStyle.dividerColor
        self.bottomView.backgroundColor = messageInputStyle.inputBackground
        self.topView.backgroundColor = messageInputStyle.inputBackground
        self.textView.placeholder = NSAttributedString(string:  placeholderText, attributes: [.foregroundColor: messageInputStyle.placeHolderTextColor,.font:  messageInputStyle.placeHolderTextFont])
        self.textView.maxNumberOfLines = self.maxLine
    }
    
}


