//
//  CometChatTextBubble.swift
//
//
//  Created by Abdullah Ansari on 19/12/22.
//

import UIKit
import SafariServices
import MessageUI

public class CometChatTextBubble: UIStackView {
    @IBOutlet weak var label: HyperlinkLabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatTextBubble", owner: self, options:  nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        translatesAutoresizingMaskIntoConstraints = false
        contentStackView.layoutMargins = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: 25),
            widthAnchor.constraint(lessThanOrEqualToConstant: 228),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        set(style: TextBubbleStyle())
        
        let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
        let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
        let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
        
        label.enabledTypes.append(phoneParser1)
        label.enabledTypes.append(phoneParser2)
        label.enabledTypes.append(emailParser)
        
        label.customize { label in
            label.URLColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
            label.URLSelectedColor = #colorLiteral(red: 0.01568627451, green: 0, blue: 0.6165823063, alpha: 1)
            label.customColor[phoneParser1] = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.customSelectedColor[phoneParser1] = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            label.customColor[phoneParser2] = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            label.customSelectedColor[phoneParser2] = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            label.customColor[emailParser] = #colorLiteral(red: 0.9529411793, green: 0.5480152855, blue: 0, alpha: 1)
            label.customSelectedColor[emailParser] = #colorLiteral(red: 0.9529411765, green: 0.4078431373, blue: 0, alpha: 1)
        }

        self.label.handleURLTap { link in
            UIApplication.shared.open(link)
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
            if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined() as? String {
                if let url = URL(string: "tel://\(number)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
            if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined() as? String {
                if let url = URL(string: "tel://\(number)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { (emailID) in
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([emailID])

                if let  topViewController = self.window?.topViewController() as? UIViewController{
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
    
   public func set(textColor: UIColor) {
        label.textColor = textColor
    }
    
   public func set(textFont: UIFont) {
        label.font = textFont
    }
    
   public func set(backgroundColor: UIColor) {
        contentView.backgroundColor = backgroundColor
    }
    
   public func set(cornerRadius: CometChatCornerStyle) {
        contentView.roundViewCorners(corner: cornerRadius)
    }
    
   public func set(borderWidth: CGFloat) {
        contentView.borderWith(width: borderWidth)
    }
    
  public func set(borderColor: UIColor) {
        contentView.borderColor(color: borderColor)
    }
    
   public func set(style: TextBubbleStyle = TextBubbleStyle()) {
        set(textColor: style.titleColor)
        set(textFont: style.titleFont)
        set(borderColor: style.borderColor)
        set(borderWidth: style.borderWidth)
        set(backgroundColor: style.background)
        set(cornerRadius: style.cornerRadius)
    }
}

extension String {
    
    func applyLargeSizeEmoji() -> UIFont {
        if  containsOnlyEmojis() {
            if count == 1 {
                return UIFont.systemFont(ofSize: 51, weight: .regular)
            } else if count == 2 {
                return  UIFont.systemFont(ofSize: 34, weight: .regular)
            } else if count == 3 {
                return UIFont.systemFont(ofSize: 25, weight: .regular)
             } else {
                return UIFont.systemFont(ofSize: 17, weight: .regular)
            }
         } else {
            return UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
}

extension CometChatTextBubble: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}






