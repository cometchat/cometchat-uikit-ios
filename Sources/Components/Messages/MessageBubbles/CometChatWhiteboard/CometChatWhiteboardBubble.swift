//
//  CometChatWhiteboardBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatPro

class CometChatWhiteboardBubble: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var whiteboardButton: UIButton!
    @IBOutlet weak var line: UIView!
    
    // MARK: - Initializers
    var controller: UIViewController?
    var customMessage: CustomMessage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    convenience init(frame: CGRect, message: CustomMessage, isStandard: Bool) {
        self.init(frame: frame)
        setup(message: message, isStandard: isStandard)
        set(title: "COLLABORATIVE_WHITEBOARD".localize())
        set(subTitle: "OPEN_WHITEBOARD_TO_DRAW_TOGETHER".localize())
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helper Methods
    
    private func setup(message: CustomMessage, isStandard: Bool) {
        set(buttonTitle: "OPEN_WHITEBOARD".localize())
        self.customMessage = message
        let whiteboardBubbleStyle = WhiteboardBubbleStyle(
            titleColor: (CometChatTheme.palatte?.accent900)!,
            titleFont: CometChatTheme.typography?.Subtitle1,
            subTitleColor: (CometChatTheme.palatte?.accent600)!,
            subTitleFont: CometChatTheme.typography?.Subtitle2,
            iconColor:  CometChatTheme.palatte?.accent700,
            whiteboardButtonTitleColor: CometChatTheme.palatte?.primary,
            whiteboardButtonTitleFont: CometChatTheme.typography?.Name2,
            lineColor: CometChatTheme.palatte?.accent100, buttonColor: CometChatTheme.palatte?.primary ,buttonFont: CometChatTheme.typography?.Name2
        )
        set(style: whiteboardBubbleStyle)

    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatWhiteboardBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
    }
    
    @discardableResult
    public func set(style: WhiteboardBubbleStyle) -> Self {
        self.set(titleColor: style.titleColor!)
        self.set(titleFont: style.titleFont!)
        self.set(subTitleColor: style.subTitleColor!)
        self.set(subTitleFont:  style.subTitleFont!)
        self.set(thumbnailTintColor: style.iconColor!)
        self.set(buttonColor: style.whiteboardButtonTitleColor!)
        self.set(buttonFont: style.whiteboardButtonTitleFont!)
        self.set(lineColor: style.lineColor!)
        return self
    }
    
    @discardableResult
    @objc public func set(iconColor: UIColor) -> Self {
        self.icon.image?.withTintColor(iconColor)
        return self
    }
    
    @discardableResult
    @objc public func set(title: String) -> Self {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> Self {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> Self {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(subTitle: String) -> Self {
        self.subTitle.text = subTitle
        return self
    }
    
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> Self {
        self.subTitle.font = subTitleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> Self {
        self.subTitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    @objc public func set(thumbnailTintColor: UIColor) -> Self {
        self.icon.image = UIImage(named: "messages-collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        self.icon.tintColor = thumbnailTintColor
        return self
    }
    
    @discardableResult
    @objc public func set(buttonTitle: String) -> Self {
        self.whiteboardButton.setTitle(buttonTitle, for: .normal)
        return self
    }
    
    @discardableResult
    @objc public func set(buttonFont: UIFont) -> Self {
        self.whiteboardButton.titleLabel!.font = buttonFont
        return self
    }
    
    @discardableResult
    @objc public func set(buttonColor: UIColor) -> Self {
        self.whiteboardButton.setTitleColor(buttonColor, for: .normal)
        return self
    }
    
    
    @discardableResult
    @objc public func set(lineColor: UIColor) -> Self {
        self.line.backgroundColor = lineColor
        return self
    }
    
    
    @discardableResult
    @objc public func set(controller: UIViewController) -> Self {
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
