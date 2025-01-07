//
//  CometChatMessageInput.swift
//  
//
//  Created by Ajay Verma on 16/12/22.
//

import UIKit

//public enum AuxilaryButtonAlignment {
//    case left
//    case right
//}
//
//@objc @IBDesignable public class CometChatMessageInput: UIView {
//    //MARK: Declaration of outlets
//    
//    @IBOutlet weak var containerStack: UIStackView!
//    @IBOutlet weak var topView: UIView!
//    @IBOutlet weak var textView: GrowingTextView!
//    @IBOutlet weak var buttonsContainer: UIStackView!
//    @IBOutlet weak var secondaryButtonContainer: UIStackView!
//    @IBOutlet weak var auxilaryButtonsContainer: UIStackView!
//    @IBOutlet weak var primaryButtonContainer: UIStackView!
//    @IBOutlet weak var divider: UIView!
//    @IBOutlet weak var bottomView: UIView!
//    @IBOutlet weak var heightConstant: NSLayoutConstraint!
//    @IBOutlet weak var containerView: UIView!
//    //MARK: Declaration of variables
//    private(set) var text: String?
//    private(set) var maxLine: Int? = 5
//    var onChange: ((String) -> ())?
//    var shouldBeginEditing: ((Bool) -> ())?
//    var shouldEndEditing: ((Bool) -> ())?
//    var didChangeSelection: ((_ growingTextView: GrowingTextView) -> ())?
//    var shouldChangeTextInRange: ((_ growingTextView: GrowingTextView, _ range: NSRange, _ text: String) -> Bool)?
//    private(set) var auxilaryButtonAignment: AuxilaryButtonAlignment = .left
//    private(set) var secondaryButtonView: UIView?
//    private(set) var auxilaryButtonView: UIView?
//    private(set) var primaryButtonView: UIView?
//    private(set) var placeholderText: String = "TYPE_A_MESSAGE".localize()
//    private(set) var messageInputStyle = MessageInputStyle()
//    private(set) var placeHolderTextFont : UIFont = CometChatTheme_v4.typography.text1
//    private(set) var placeHolderTextColor : UIColor = CometChatTheme_v4.palatte.accent500
//    
//    private(set) var textColor = CometChatTheme_v4.palatte.accent
//    private(set) var textFont = CometChatTheme_v4.typography.text1
//
//    // MARK: - Initialization of required Methods
//    override init(frame: CGRect) {
//        super.init(frame: UIScreen.main.bounds)
//        commonInit()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commonInit()
//        setupAppearance()
//    }
//    
//    private func commonInit() {
//        let loadedNib = CometChatUIKit.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
//        if let contentView = loadedNib?.first as? UIView  {
//            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//            contentView.frame = bounds
//            addSubview(contentView)
//        }
//    }
//    
//    private func setupAppearance() {
//        self.textView.delegate = self
//        topView.roundViewCorners(corner: CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: false, bottomRight: false, cornerRadius: 18))
//        bottomView.roundViewCorners(corner: CometChatCornerStyle(topLeft: false, topRight: false, bottomLeft: true, bottomRight: true, cornerRadius: 18))
//        containerStack.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 18))
//        self.containerView.backgroundColor = messageInputStyle.background
//    }
//    
//}
//
//extension CometChatMessageInput: GrowingTextViewDelegate {
//    
//    public func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
//        self.heightConstant.constant = height
//    }
//    
//    public func growingTextViewDidChange(_ growingTextView: GrowingTextView) {
//        onChange?(growingTextView.text ?? "")
//        if growingTextView.text?.count == 0 {
//            
//        }
//    }
//    
//    func growingTextViewShouldBeginEditing(_ growingTextView: GrowingTextView) -> Bool {
//        shouldBeginEditing?(true)
//        return true
//    }
//    
//    func growingTextViewShouldEndEditing(_ growingTextView: GrowingTextView) -> Bool {
//        shouldEndEditing?(true)
//        return true
//    }
//    
//    func growingTextViewDidChangeSelection(_ growingTextView: GrowingTextView) {
//        didChangeSelection?(growingTextView)
//    }
//    
//    func growingTextView(_ growingTextView: GrowingTextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if let shouldChangeTextInRange = shouldChangeTextInRange {
//            return shouldChangeTextInRange(growingTextView, range, text)
//        } else {
//            return true
//        }
//    }
//    
//}
//
//extension CometChatMessageInput {
//    
//    @discardableResult
//    public func set(messageInputStyle: MessageInputStyle) -> Self {
//        set(textFont: messageInputStyle.textFont)
//        set(textColor: messageInputStyle.textColor)
//        set(placeHolderTextColor: messageInputStyle.placeHolderTextColor)
//        set(placeHolderTextFont: messageInputStyle.placeHolderTextFont)
//        set(dividerColor: messageInputStyle.dividerColor)
//        set(inputBackgroundColor: messageInputStyle.inputBackground)
//        return self
//    }
//    
//    @discardableResult
//    @objc public func set(maxLines: Int) -> Self {
//        self.textView.maxNumberOfLines = maxLines
//        return self
//    }
//    
//    @discardableResult
//    public func set(text: String) ->  Self {
//        self.text = text
//        textView.text = text
//        onChange?(text)
//        return self
//    }
//    
//    @discardableResult
//    public func set(attributedText: NSAttributedString) -> Self {
//        self.text = attributedText.string
//        textView.attributedText = attributedText
//        onChange?(attributedText.string)
//        return self
//    }
//    
//    @discardableResult
//    public func append(text: String) -> Self {
//        textView.text?.append(text)
//        onChange?(text)
//        return self
//    }
//    
//    @discardableResult
//    public func set(primaryButtonView: UIView) -> Self {
//        self.primaryButtonView = primaryButtonView
//        primaryButtonContainer.subviews.forEach({ $0.removeFromSuperview() })
//        primaryButtonContainer.addArrangedSubview(primaryButtonView)
//        return self
//    }
//    
//    @discardableResult
//    public func set(secondaryButtonView: UIView) -> Self {
//        self.secondaryButtonView = secondaryButtonView
//        secondaryButtonContainer.subviews.forEach({ $0.removeFromSuperview() })
//        secondaryButtonContainer.addArrangedSubview(secondaryButtonView)
//        return self
//    }
//    
//    @discardableResult
//    public func set(auxilaryButtonView: UIView) -> Self {
//        self.auxilaryButtonView = auxilaryButtonView
//        self.auxilaryButtonsContainer.subviews.forEach({ $0.removeFromSuperview() })
//        self.auxilaryButtonsContainer.addArrangedSubview(auxilaryButtonView)
//        return self
//    }
//    
//    @discardableResult
//    public func set(auxilaryButtonAignment: AuxilaryButtonAlignment) -> Self {
//        self.auxilaryButtonAignment = auxilaryButtonAignment
//        self.buttonsContainer.removeArrangedSubview(auxilaryButtonsContainer)
//        if auxilaryButtonAignment == .right {
//            self.buttonsContainer.insertArrangedSubview(auxilaryButtonsContainer, at: 2)
//        }else{
//            self.buttonsContainer.insertArrangedSubview(auxilaryButtonsContainer, at: 1)
//        }
//        self.buttonsContainer.setNeedsLayout()
//        self.buttonsContainer.layoutIfNeeded()
//        return self
//    }
//    
//    @discardableResult
//    public func set(placeholderText: String) -> Self {
//        self.placeholderText = placeholderText
//        self.textView.placeholder = NSAttributedString(string:  self.placeholderText, attributes: [.foregroundColor: placeHolderTextColor,.font:  placeHolderTextFont])
//        return self
//    }
//    
//    @discardableResult
//    public func set(textFont: UIFont) -> Self {
//        self.textFont = textFont
//        self.textView.font = textFont
//        return self
//    }
//    
//    @discardableResult
//    public func set(cornerRadius: CometChatCornerStyle) -> Self {
//        self.topView.roundViewCorners(corner: CometChatCornerStyle(topLeft: true, topRight:  true, bottomLeft: false, bottomRight:false, cornerRadius: cornerRadius.cornerRadius))
//        self.bottomView.roundViewCorners(corner: CometChatCornerStyle(topLeft: false, topRight:  false, bottomLeft: true, bottomRight: true, cornerRadius: cornerRadius.cornerRadius))
//        self.containerStack.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: cornerRadius.cornerRadius))
//        return self
//    }
//
//    @discardableResult
//    public func set(textColor: UIColor) -> Self {
//        self.textColor = textColor
//        self.textView.textColor = textColor
//        return self
//    }
//
//    @discardableResult
//    public func set(placeHolderTextColor: UIColor) -> Self {
//        self.placeHolderTextColor = placeHolderTextColor
//        self.textView.placeholder = NSAttributedString(string:  placeholderText, attributes: [.foregroundColor: placeHolderTextColor,.font:  placeHolderTextFont])
//        return self
//    }
//
//    @discardableResult
//    public func set(placeHolderTextFont: UIFont) -> Self {
//        self.placeHolderTextFont = placeHolderTextFont
//        self.textView.placeholder = NSAttributedString(string:  placeholderText, attributes: [.foregroundColor: placeHolderTextColor,.font:  placeHolderTextFont])
//        return self
//    }
//
//    @discardableResult
//    public func set(dividerColor: UIColor) -> Self {
//        self.divider.backgroundColor = dividerColor
//        return self
//    }
//
//    @discardableResult
//    public func set(inputBackgroundColor: UIColor) -> Self {
//        self.bottomView.backgroundColor = inputBackgroundColor
//        self.topView.backgroundColor = inputBackgroundColor
//        return self
//    }
//    
//    @discardableResult
//    public func set(shouldChangeTextInRange: ((_ growingTextView: GrowingTextView, _ range: NSRange, _ text: String) -> Bool)?) -> Self {
//        self.shouldChangeTextInRange = shouldChangeTextInRange
//        return self
//    }
//    
//    @discardableResult
//    public func set(didChangeSelection: ((_ growingTextView: GrowingTextView) -> ())?) -> Self {
//        self.didChangeSelection = didChangeSelection
//        return self
//    }
//
//    public func build() {
//        self.textView.font = textFont
//        self.textView.textColor = textColor
//        self.divider.backgroundColor = messageInputStyle.dividerColor
//        self.bottomView.backgroundColor = messageInputStyle.inputBackground
//        self.topView.backgroundColor = messageInputStyle.inputBackground
//        self.textView.placeholder = NSAttributedString(string:  placeholderText, attributes: [.foregroundColor: placeHolderTextColor,.font:  placeHolderTextFont])
//        self.textView.maxNumberOfLines = self.maxLine
//    }
//    
//}
//
//
