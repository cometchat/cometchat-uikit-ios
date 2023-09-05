//
//  CometChatNewMessageIndicator.swift
//  
//
//  Created by admin on 15/09/22.
//

import UIKit
import CometChatSDK



@objc @IBDesignable public class CometChatNewMessageIndicator: UIView {
    
    //MARK: - Declaration of Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var container: UIView!
    
    private var singleNewMessageText: String = "NEW_MESSAGE".localize()
    private var multipleNewMessageText: String = "NEW_MESSAGES".localize()
    private var titleText: String?
    private var background = CometChatTheme.palatte.primary
    private var titleFont = CometChatTheme.typography.text1
    private var titleColor = CometChatTheme.palatte.background
    private var iconImage = UIImage(named: "messageIndicator-down-arrow.png", in: CometChatUIKit.bundle, compatibleWith: nil)
    private var iconTint = CometChatTheme.palatte.background
    private var cornerRadius = 15.0
    private var newMessageIndicatorStyle = NewMessageIndicatorStyle()
    private var newMessageIndicatorConfiguration: NewMessageIndicatorConfiguration?
    private var count: Int = 0
    @objc var onClick: (() -> Void)?
    var getCount: Int {
        get {
            return count
        }
    }
    
    //MARK: FUNCTIONS
    @discardableResult
    public func set(background: UIColor) -> Self {
        self.container.backgroundColor = background
        return self
    }
    
    @discardableResult
    public func set(corner: CGFloat) -> Self {
        self.container.layer.cornerRadius = corner
        return self
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title.text = title
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(icon: UIImage) -> Self {
       // self.icon.image = icon
        return self
    }

    @discardableResult
    public func set(iconTint: UIColor) -> Self {
//        self.icon.image = self.icon.image?.withRenderingMode(.alwaysTemplate)
//        self.icon.tintColor = iconTint
        return self
    }
    
    @discardableResult
    public func set(count : Int) -> Self {
        self.count = count
        if count == 1 {
            self.isHidden = false
            self.title.text = "↓  \(count) " + singleNewMessageText
        }else if count > 1 && count < 999 {
            self.isHidden = false
            self.title.text = "↓  \(count) " + multipleNewMessageText
        }else if count > 999 {
            self.isHidden = false
            self.title.text = "↓  999+ " + multipleNewMessageText
        } else {
            self.title.text = "0"
            self.isHidden = true
        }
        return self
    }
    
    @discardableResult
    public func incrementCount() -> Self {
        let currentCount = self.getCount
        self.set(count: currentCount + 1)
        self.isHidden = false
       return self
    }
    
    @discardableResult
    public func reset() -> Self {
        self.title.text = "0"
        self.count = 0
        self.isHidden = true
        return self
    }
    
    @discardableResult
    public func set(newMessageIndicatorConfiguration: NewMessageIndicatorConfiguration) -> Self {
        self.newMessageIndicatorConfiguration = newMessageIndicatorConfiguration
        return self
    }
    
    private func configurationNewMessageIndicator() {
        if let configuration = newMessageIndicatorConfiguration {
            set(icon: configuration.icon)
            // TODO:- onClick.
            if let style = configuration.style {
                set(style: style)
            }
        }
    }
    
    public func set(style: NewMessageIndicatorStyle) {
        set(corner: style.cornerRadius.cornerRadius)
        set(titleFont: style.textFont)
        set(titleColor: style.textColor)
        set(background: style.background)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
       // set(style: NewMessageIndicatorStyle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
       // set(style: NewMessageIndicatorStyle())
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
            setupAppearace()
            let tapGesture = UITapGestureRecognizer()
            tapGesture.addTarget(self, action: #selector(onTap))
            container.addGestureRecognizer(tapGesture)
            container.isUserInteractionEnabled = true
        }
    }
    @objc func onTap() {
        onClick?()
    }
    
    private func setupAppearace() {
        set(background: background )
        set(iconTint: iconTint )
        set(titleFont: titleFont )
        set(icon: iconImage ?? UIImage())
        set(corner: cornerRadius)
    }

}
