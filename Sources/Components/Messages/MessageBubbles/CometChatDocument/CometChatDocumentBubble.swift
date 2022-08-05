//
//  CometChatDocumentBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatPro

// TODO: - Why whiteboard and document delegate's method are mixed up in one protocol?
protocol CollaborativeDelegate: NSObject {
    func didOpenWhiteboard(forMessage: CustomMessage, cell: UITableViewCell)
    func didOpenDocument(forMessage: CustomMessage, cell: UITableViewCell)
    func didLongPressedOnCollaborativeWhiteboard(message: CustomMessage,cell: UITableViewCell)
    func didLongPressedOnCollaborativeDocument(message: CustomMessage,cell: UITableViewCell)
}

class CometChatDocumentBubble: UIView {
    
    // MARK: - Properties
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var documentButton: UIButton!
    @IBOutlet weak var line: UIView!

    var controller: UIViewController?
    var customMessage: CustomMessage?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    convenience init(frame: CGRect, message: CustomMessage, isStandard: Bool) {
        self.init(frame: frame)
        set(documentButtonTitle: "OPEN_DOCUMENT".localize())
        setup(message: message, isStandard: isStandard)
        set(title: "COLLABORATIVE_DOCUMENT".localize())
        set(subTitle: "OPEN_DOCUMENT_TO_EDIT_CONTENT_TOGETHER".localize())

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    // MARK: - Helper Methods
    
    private func setup(message: CustomMessage, isStandard: Bool) {
        self.customMessage = message
        let documentBubbleStyle = DocumentBubbleStyle(
            titleColor: (CometChatTheme.palatte?.accent900)!,
            titleFont: CometChatTheme.typography?.Subtitle1,
            subTitleColor: (CometChatTheme.palatte?.accent600)!,
            subTitleFont: CometChatTheme.typography?.Subtitle2,
            iconColor: CometChatTheme.palatte?.accent700,
            documentButtonTitleColor: CometChatTheme.palatte?.primary,
            documentButtonTitleFont: CometChatTheme.typography?.Name2,
            lineColor: CometChatTheme.palatte?.accent100
        )
        set(style: documentBubbleStyle)
    }
    
    @discardableResult
    public func set(style: DocumentBubbleStyle) -> Self {
        self.set(titleColor: style.titleColor!)
        self.set(titleFont: style.titleFont!)
        self.set(subTitleColor: style.subTitleColor!)
        self.set(subTitleFont:  style.subTitleFont!)
        self.set(thumbnailTintColor: style.iconColor!)
        self.set(buttonColor: style.documentButtonTitleColor!)
        self.set(buttonFont: style.documentButtonTitleFont!)
        self.set(lineColor: style.lineColor!)
        
        return self
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatDocumentBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        self.icon.image = UIImage(named: "messages-collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
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
