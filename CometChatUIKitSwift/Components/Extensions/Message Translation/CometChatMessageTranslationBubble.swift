//
//  CometChatMessageTranslationBubble.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 19/09/24.
//

import Foundation
import UIKit
import MessageUI

/// A view representing a message bubble that displays both the original and translated versions of a message.
/// The class handles the layout of the original and translated messages and provides functionality for tapping on URLs, phone numbers, and email addresses.
public class CometChatMessageTranslationBubble: UIView, MFMailComposeViewControllerDelegate {

    // MARK: - Properties
    
    /// The parent view controller, if any, used for presenting additional interfaces such as a mail composer.
    public weak var controller: UIViewController?

    // MARK: Styling
    
    /// The style configuration for the message translation bubble, allowing customization of fonts, colors, and separators.
    public var style = MessageTranslationBubbleStyle()

    // MARK: - UI Elements
    
    /// A label displaying the original message. Supports hyperlinks.
    public let originalMessageLabel: HyperlinkLabel = {
        let label = HyperlinkLabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()

    /// A label displaying the translated message. Supports hyperlinks.
    public let translatedMessageLabel: HyperlinkLabel = {
        let label = HyperlinkLabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()
    
    /// A label indicating that the message is translated.
    lazy var textTranslatedLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 1
        label.text = "TRANSLATED_TEXT".localize()
        return label
    }()
    
    /// A separator line between the original and translated messages.
    private let separatorLine: UIView = {
        let line = UIView().withoutAutoresizingMaskConstraints()
        return line
    }()

    /// A container view for holding the message labels and separator.
    private let containerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()

    // MARK: - Initializers

    /// Initializes a new instance of `CometChatMessageTranslationBubble`.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpHyperlinkLabels()
        buildUI()
    }

    /// Initializes the view from an NSCoder object (not implemented).
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil{
            setupStyle()
        }
    }

    // MARK: - Setup Methods

    /// Builds the user interface by embedding the message labels, separator, and translated text label within the container view.
    private func buildUI() {
        self.embed(containerView, insets: .init(top: CometChatSpacing.Spacing.s2, leading: CometChatSpacing.Spacing.s2, bottom: CometChatSpacing.Spacing.s1, trailing: CometChatSpacing.Spacing.s2))

        containerView.addSubview(originalMessageLabel)
        containerView.addSubview(separatorLine)
        containerView.addSubview(translatedMessageLabel)
        containerView.addSubview(textTranslatedLabel)

        originalMessageLabel.pin(anchors: [.top, .leading, .trailing], to: containerView)
        separatorLine.pin(anchors: [.leading, .trailing], to: containerView)
        translatedMessageLabel.pin(anchors: [.leading, .trailing], to: containerView)
        textTranslatedLabel.pin(anchors: [.leading, .trailing, .bottom], to: containerView)

        NSLayoutConstraint.activate([
            translatedMessageLabel.topAnchor.pin(equalTo: separatorLine.bottomAnchor, constant: CometChatSpacing.Padding.p2),
            separatorLine.topAnchor.pin(equalTo: originalMessageLabel.bottomAnchor, constant: CometChatSpacing.Padding.p2),
            separatorLine.heightAnchor.pin(equalToConstant: 1),
            translatedMessageLabel.bottomAnchor.pin(equalTo: textTranslatedLabel.topAnchor, constant: -(CometChatSpacing.Padding.p2))
        ])

        self.withoutAutoresizingMaskConstraints()
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width / 1.2)
        ])
    }

    /// Applies the style configurations for the message bubble elements such as fonts and colors.
    private func setupStyle() {
        self.backgroundColor = .clear
        originalMessageLabel.font = style.textFont
        translatedMessageLabel.font = style.textFont
        originalMessageLabel.textColor = style.textColor
        translatedMessageLabel.textColor = style.textColor
        separatorLine.backgroundColor = style.separatorBackgroundColor
        textTranslatedLabel.font = style.subtitleTextFont
        textTranslatedLabel.textColor = style.subtitleTextColor
    }

    /// Sets the original and translated messages to display in the bubble.
    /// - Parameters:
    ///   - originalMessage: The original message in `NSAttributedString` format.
    ///   - translatedMessage: The translated message in `NSAttributedString` format.
    public func set(originalMessage: NSAttributedString, translatedMessage: NSAttributedString?) {
        originalMessageLabel.attributedText = originalMessage
        translatedMessageLabel.attributedText = translatedMessage
    }

    // MARK: - Hyperlink Configuration
    
    /// Configures hyperlink support for phone numbers, URLs, and email addresses.
    private func setUpHyperlinkLabels() {
        configureHyperlinkLabel(originalMessageLabel)
        configureHyperlinkLabel(translatedMessageLabel)
    }

    /// Configures a `HyperlinkLabel` to support taps on phone numbers, URLs, and email addresses, applying appropriate styles and handling taps.
    private func configureHyperlinkLabel(_ label: HyperlinkLabel) {
        let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
        let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
        let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)

        label.enabledTypes.append(phoneParser1)
        label.enabledTypes.append(phoneParser2)
        label.enabledTypes.append(emailParser)

        label.customize { label in
            label.URLColor = style.urlColor
            label.URLSelectedColor = style.urlColor
            label.customColor[phoneParser1] = style.phoneTextColor
            label.customSelectedColor[phoneParser1] = style.phoneTextColor
            label.customColor[phoneParser2] = style.phoneTextColor
            label.customSelectedColor[phoneParser2] = style.phoneTextColor
            label.customColor[emailParser] = style.emailTextColor
            label.customSelectedColor[emailParser] = style.emailTextColor
        }

        label.handleURLTap { link in
            UIApplication.shared.open(link)
        }

        label.handleCustomTap(for: phoneParser1) { number in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        label.handleCustomTap(for: phoneParser2) { number in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        label.handleCustomTap(for: emailParser) { [weak self] emailID in
            guard let this = self else { return }

            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = this
                mail.setToRecipients([emailID])

                if let topViewController = this.window?.topViewController() as? UIViewController {
                    topViewController.present(mail, animated: true, completion: nil)
                }
            } else {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.set(title: "WARNING".localize())
                confirmDialog.set(messageText: "MAIL_APP_NOT_FOUND_MESSAGE".localize())
                confirmDialog.open(onConfirm: {})
            }
        }
    }
}
