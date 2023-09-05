//
//  CometChatLinkPreviewBubble.swift
 
//
//  Created by Abdullah Ansari on 12/05/22.
//

import UIKit
import SafariServices
import MessageUI
import CometChatSDK


public class CometChatLinkPreviewBubble: UIView {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var message: HyperlinkLabel!
    
    var linkPreviewMessage: TextMessage?
    var url: String?
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    var controller: UIViewController?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    convenience init(frame: CGRect, message: TextMessage) {
        self.init(frame: frame)
        self.linkPreviewMessage = message
        self.generateHyperlinks()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onLinkPreviewClick))
        imageThumbnail.addGestureRecognizer(tap)
        imageThumbnail.isUserInteractionEnabled = true
        self.message.text = message.text
        
        self.title.font = CometChatTheme.typography.text2
        self.subtitle.font = CometChatTheme.typography.subtitle2
        self.message.font = CometChatTheme.typography.subtitle2
        
        if message.sender?.uid == CometChat.getLoggedInUser()?.uid {
            self.title.textColor = .white
            self.subtitle.textColor = .white
            self.message.textColor = .white
        } else {
            self.title.textColor = CometChatTheme.palatte.accent
            self.subtitle.textColor = CometChatTheme.palatte.accent700
            self.message.textColor = CometChatTheme.palatte.accent700
        }
        
        if let linkPreviewMessage = linkPreviewMessage {
            parseLinkPreviewForMessage(message: linkPreviewMessage)
        }
    }
    
    
    private func generateHyperlinks() {
                
        let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
        let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
        let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
        
        message.enabledTypes.append(phoneParser1)
        message.enabledTypes.append(phoneParser2)
        message.enabledTypes.append(emailParser)
        
        message.customize { message in
            message.URLColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
            message.URLSelectedColor = #colorLiteral(red: 0.01568627451, green: 0, blue: 0.6165823063, alpha: 1)
            message.customColor[phoneParser1] = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            message.customSelectedColor[phoneParser1] = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            message.customColor[phoneParser2] = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            message.customSelectedColor[phoneParser2] = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            message.customColor[emailParser] = #colorLiteral(red: 0.9529411793, green: 0.5480152855, blue: 0, alpha: 1)
            message.customSelectedColor[emailParser] = #colorLiteral(red: 0.9529411765, green: 0.4078431373, blue: 0, alpha: 1)
        }
        
        self.message.handleURLTap { link in
            guard let url = URL(string: "\(link)") else { return }
            UIApplication.shared.openURL(url)
        }
        
        self.message.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
            if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined() as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let url = URL(string: "tel://\(number)")!
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
        
        self.message.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
            if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined() as? String {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    let url = URL(string: "tel://\(number)")!
                    UIApplication.shared.open(url, options: [:])
                }
            }
        }
        
        self.message.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { (emailID) in
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([emailID])
                if let topViewController = self.window?.topViewController() {
                    topViewController.present(mail, animated: true, completion: nil)
                }
               
            } else {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.set(title: "WARNING".localize())
                confirmDialog.set(messageText: "MAIL_APP_NOT_FOUND_MESSAGE".localize())
                confirmDialog.open(onConfirm: { [weak self] in
                    guard let strongSelf = self else { return }
                })
            }
        }

    }
    
    private func parseLinkPreviewForMessage(message: TextMessage){
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]] {
            
            guard let linkPreview = linkArray[safe: 0] else {
                return
            }
            
            if let linkTitle = linkPreview["title"] as? String {
                title.text = linkTitle
            }
            
            if let description = linkPreview["description"] as? String {
                subtitle.text = description
            }
            
            self.imageThumbnail.image = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)
            
            if let thumbnail = linkPreview["image"] as? String , let url = URL(string: thumbnail) {
              
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    if let image = image {
                        strongSelf.imageThumbnail.image = image
                    }
                }
            }else if let favIcon = linkPreview["favicon"] as? String , let url = URL(string: favIcon) {
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    if let image = image {
                        strongSelf.imageThumbnail.image = image
                    }
                }
            }
            if let linkURL = linkPreview["url"] as? String {
                self.url = linkURL
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helper Methods
    
    private func commonInit() {
        Bundle.module.loadNibNamed("CometChatLinkPreviewBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @objc  func onLinkPreviewClick() {
        if let url = url {
            guard let url = URL(string: url) else { return }
            UIApplication.shared.open(url)
        }
    }

    deinit {
        imageRequest?.cancel()
    }
    
}

extension CometChatLinkPreviewBubble: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


