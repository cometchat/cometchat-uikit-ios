//
//  CometChatTextBubble.swift
//
//
//  Created by Abdullah Ansari on 19/12/22.
//

import UIKit
import SafariServices
import MessageUI
import CometChatSDK

public class CometChatTextBubble: UIView {
    
    public weak var controller: UIViewController?
    public var style = TextBubbleStyle()
    public lazy var label: HyperlinkLabel = {
        let label = HyperlinkLabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()
    private let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
    private let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
    private let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpHyperLinkLabel()
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            applyStyle()
            //updateLabelAlignment()
        }
    }
    
    public func buildUI() {
        
        self.withoutAutoresizingMaskConstraints()
        NSLayoutConstraint.activate([
            widthAnchor.pin(lessThanOrEqualToConstant: UIScreen.main.bounds.width/1.2),
        ])
        
        self.embed(
            label,
            insets: .init(
                top: CometChatSpacing.Padding.p3,
                leading: CometChatSpacing.Padding.p3,
                bottom: 0,
                trailing: CometChatSpacing.Padding.p3
            )
        )
        
        applyStyle()
    }
    
    open func applyStyle() {
        self.label.textColor = style.textColor
        self.label.font = style.textFont
        
        label.customize { label in
            label.URLColor = style.textHighlightColor
            label.URLSelectedColor = style.textHighlightColor
            label.customColor[phoneParser1] = style.textHighlightColor
            label.customSelectedColor[phoneParser1] = style.textHighlightColor
            label.customColor[phoneParser2] = style.textHighlightColor
            label.customSelectedColor[phoneParser2] = style.textHighlightColor
            label.customColor[emailParser] = style.textHighlightColor
            label.customSelectedColor[emailParser] = style.textHighlightColor
            
            label.addUnderline[phoneParser1] = true
            label.addUnderline[phoneParser2] = true
            label.addUnderline[emailParser] = true
        }
    }
    
    open func setUpHyperLinkLabel() {
        
        label.enabledTypes.append(phoneParser1)
        label.enabledTypes.append(phoneParser2)
        label.enabledTypes.append(emailParser)

        self.label.handleURLTap { link in
            UIApplication.shared.open(link)
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { [weak self] (emailID) in
            
            guard let this = self else { return }
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = this
                mail.setToRecipients([emailID])

                if let  topViewController = this.window?.topViewController() as? UIViewController{
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
    
    public func set(text: String) {
        label.text = text
     }
     
    public func set(attributedText: NSAttributedString) {
        label.attributedText = attributedText
    }
    
    public func updateLabelAlignment() {
        if (label.text ?? "").containsOnlyEmojis() || (label.attributedText?.string ?? "").containsOnlyEmojis() {
            label.textAlignment = .center
            label.font = applyLargeSizeEmoji()
        }
    }
    
    private func applyLargeSizeEmoji() -> UIFont {
        let normalFont = style.textFont
        if let text = self.label.text, text.containsOnlyEmojis() {
            let count = text.count
            if count == 1 {
                return UIFont.systemFont(ofSize: (normalFont.pointSize * 3.8), weight: .regular)
            } else if count == 2 {
                return  UIFont.systemFont(ofSize: (normalFont.pointSize * 2.4), weight: .regular)
            } else if count == 3 {
                return UIFont.systemFont(ofSize: (normalFont.pointSize * 1.7), weight: .regular)
            } else {
                return UIFont.systemFont(ofSize: normalFont.pointSize, weight: .regular)
            }
         } else {
            return UIFont.systemFont(ofSize: normalFont.pointSize, weight: .regular)
        }
    }
    
}

extension CometChatTextBubble: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}




