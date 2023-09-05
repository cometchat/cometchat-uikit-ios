//
//  CometChatWhiteboardBubble.swift
 
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatSDK

public class CometChatWhiteboardBubble: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var whiteboardButton: UIButton!
    @IBOutlet weak var line: UIView!
    
    // MARK: - Initializers
    private var controller: UIViewController?
    private var customMessage: CustomMessage?
    private var whiteboardBubbleConfiguration: CollaborativeWhiteboardBubbleConfiguration?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    convenience init(frame: CGRect, message: CustomMessage, whiteboardBubbleConfiguration: CollaborativeWhiteboardBubbleConfiguration?) {
        self.init(frame: frame)
        self.customMessage = message
        self.whiteboardBubbleConfiguration = whiteboardBubbleConfiguration
        if let whiteboardBubbleConfiguration = whiteboardBubbleConfiguration, let whiteboardBubbleStyle = whiteboardBubbleConfiguration.style {
            set(style: whiteboardBubbleStyle)
        } else {
            set(style: CollaborativeWhiteBoardStyle())
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helper Methods
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatWhiteboardBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
         set(width: 250, height: 145)
       set(title: "COLLABORATIVE_WHITEBOARD".localize())
        set(titleFont: CometChatTheme.typography.text2)
        set(titleColor: CometChatTheme.palatte.accent900)
       set(subTitle: "OPEN_WHITEBOARD_TO_DRAW_TOGETHER".localize())
        set(subTitleColor:  CometChatTheme.palatte.accent600)
        set(subTitleFont: CometChatTheme.typography.subtitle2)
        set(thumbnailTintColor: CometChatTheme.palatte.accent700)
        set(buttonColor: CometChatTheme.palatte.primary)
        set(buttonFont: CometChatTheme.typography.title2)
        set(buttonTitle: "OPEN_WHITEBOARD".localize())
    }
    
    @discardableResult
    public func set(width: CGFloat, height: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        ])
        return self
    }
    
    @discardableResult
    public func set(style: CollaborativeWhiteBoardStyle) -> Self {
        self.set(titleColor: style.titleColor)
        self.set(titleFont: style.titleFont)
        self.set(subTitleColor: style.subTitleColor)
        self.set(subTitleFont:  style.subTitleFont)
        self.set(thumbnailTintColor: style.iconTint)
        self.set(buttonColor: style.buttonTextColor)
        self.set(buttonFont: style.buttonTextFont)
        self.set(corner: style.cornerRadius)
        self.set(borderWidth: style.borderWidth)
        self.set(borderColor: style.borderColor)
        self.set(lineColor: style.dividerTint)
        return self
    }
    
    @discardableResult
    public func set(iconColor: UIColor) -> Self {
        self.icon.image?.withTintColor(iconColor)
        return self
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title.text = title
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(subTitle: String) -> Self {
        self.subTitle.text = subTitle
        return self
    }
    
    @discardableResult
    public func set(subTitleFont: UIFont) -> Self {
        self.subTitle.font = subTitleFont
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        self.roundViewCorners(corner: corner)
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.borderWith(width: borderWidth)
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        self.borderColor(color: borderColor)
        return self
    }
    
    @discardableResult
    public func set(subTitleColor: UIColor) -> Self {
        self.subTitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    public func set(thumbnailTintColor: UIColor) -> Self {
        self.icon.image = UIImage(named: "collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        self.icon.tintColor = thumbnailTintColor
        return self
    }
    
    @discardableResult
    public func set(buttonTitle: String) -> Self {
        self.whiteboardButton.setTitle(buttonTitle, for: .normal)
        return self
    }
    
    @discardableResult
    public func set(buttonFont: UIFont) -> Self {
        self.whiteboardButton.titleLabel!.font = buttonFont
        return self
    }
    
    @discardableResult
    public func set(buttonColor: UIColor) -> Self {
        self.whiteboardButton.setTitleColor(buttonColor, for: .normal)
        return self
    }
    
    @discardableResult
    public func set(lineColor: UIColor) -> Self {
        self.line.backgroundColor = lineColor
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @IBAction func onOpenWhiteboardClick() {
        
        if let controller = controller , let customMessage = customMessage {
           
            controller.navigationController?.navigationBar.isHidden = false
            
            if let metaData = customMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let collaborativeDictionary = cometChatExtension[ExtensionConstants.whiteboard] as? [String : Any], let collaborativeURL =  collaborativeDictionary["board_url"] as? String {
                
                let cometChatWebView = CometChatWebView()
                cometChatWebView.set(webViewType: .whiteboard)
                    .set(url: collaborativeURL)
                controller.navigationController?.pushViewController(cometChatWebView, animated: true)
            }
        }
        
    }
}
