//
//  CometChatDocumentBubble.swift
 
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatSDK

// TODO: - Why whiteboard and document delegate's method are mixed up in one protocol?
protocol CollaborativeDelegate: NSObject {
    func didOpenWhiteboard(forMessage: CustomMessage, cell: UITableViewCell)
    func didOpenDocument(forMessage: CustomMessage, cell: UITableViewCell)
    func didLongPressedOnCollaborativeWhiteboard(message: CustomMessage,cell: UITableViewCell)
    func didLongPressedOnCollaborativeDocument(message: CustomMessage,cell: UITableViewCell)
}

public class CometChatDocumentBubble: UIView {
    
    // MARK: - Properties
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var documentButton: UIButton!
    @IBOutlet weak var line: UIView!

    private var controller: UIViewController?
    private var customMessage: CustomMessage?
    private var collaborativeDocumentBubbleConfiguration: CollaborativeDocumentBubbleConfiguration?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    convenience init(frame: CGRect, message: CustomMessage, collaborativeDocumentBubbleConfiguration: CollaborativeDocumentBubbleConfiguration?) {
        self.init(frame: frame)
        self.customMessage = customMessage
        self.collaborativeDocumentBubbleConfiguration = collaborativeDocumentBubbleConfiguration
        if let collaborativeDocumentBubbleConfiguration = collaborativeDocumentBubbleConfiguration, let collaborativeDocumentBubbleStyle = collaborativeDocumentBubbleConfiguration.style{
            
            set(style: collaborativeDocumentBubbleStyle)
        }
        else {
            set(style: CollaborativeDocumentStyle())
        }
        set(documentButtonTitle: "OPEN_DOCUMENT".localize())
        set(title: "COLLABORATIVE_DOCUMENT".localize())
        set(subTitle: "OPEN_DOCUMENT_TO_EDIT_CONTENT_TOGETHER".localize())

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // MARK: - Helper Methods
    
    @discardableResult
    public func set(style: CollaborativeDocumentStyle) -> Self {
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
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatDocumentBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        set(width: 250, height: 145)
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
    @objc public func set(customMessage: CustomMessage?) -> Self {
        self.customMessage = customMessage
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
        self.icon.image = UIImage(named: "collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        self.icon.tintColor = thumbnailTintColor
        return self
    }
    
    @discardableResult
    @objc public func set(documentButtonTitle: String) -> Self {
        self.documentButton.setTitle(documentButtonTitle, for: .normal)
        return self
    }
    
    @discardableResult
    @objc public func set(buttonTitle: String) -> Self {
        self.documentButton.setTitle(buttonTitle, for: .normal)
        return self
    }
    
    @discardableResult
    @objc public func set(buttonFont: UIFont) -> Self {
        self.documentButton.titleLabel!.font = buttonFont
        return self
    }
    
    @discardableResult
    @objc public func set(buttonColor: UIColor) -> Self {
        self.documentButton.setTitleColor(buttonColor, for: .normal)
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
    
    @IBAction func onOpenDocumentClick() {
        
        if let controller = controller , let customMessage = customMessage {
            controller.navigationController?.navigationBar.isHidden = false
            
            if let metaData = customMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let collaborativeDictionary = cometChatExtension[ExtensionConstants.document] as? [String : Any], let collaborativeURL =  collaborativeDictionary["document_url"] as? String {
                
                let cometChatWebView = CometChatWebView()
                cometChatWebView.set(webViewType: .document)
                    .set(url: collaborativeURL)
                controller.navigationController?.pushViewController(cometChatWebView, animated: true)
            }
        }
    }
    
}
