//
//  CometChatLinkPreviewBubble.swift
 
//
//  Created by Abdullah Ansari on 12/05/22.
//

import UIKit
import SafariServices
import MessageUI
import CometChatSDK


open class CometChatLinkPreviewBubble: UIView {
    
    // MARK: - Properties
    
    /// Container stack view that holds the thumbnail and text container stack views.
    public lazy var previewContainerStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.addArrangedSubview(thumbnailImageView)
        stackView.addArrangedSubview(previewTextContainerStackView)
        return stackView
    }()
    
    /// Stack view that holds the title, subtitle, and link label.
    public lazy var previewTextContainerStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = CometChatSpacing.Padding.p1
        stackView.layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Padding.p2,
            left: CometChatSpacing.Padding.p2,
            bottom: CometChatSpacing.Padding.p2,
            right: CometChatSpacing.Padding.p2
        )
        stackView.addArrangedSubview(titleContainerStackView)
        stackView.addArrangedSubview(subtitle)
        stackView.addArrangedSubview(linkLabel)
        return stackView
    }()
    
    /// Title label for the link preview.
    public lazy var title: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.isHidden = true
        label.numberOfLines = 3
        return label
    }()
    
    /// Stack view containing the title label and link icon.
    public lazy var titleContainerStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = CometChatSpacing.Padding.p1
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(linkIconImageView)
        return stackView
    }()
    
    /// Subtitle label for the link preview.
    public lazy var subtitle: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.isHidden = true
        label.numberOfLines = 4
        return label
    }()
    
    /// Label that displays the URL of the link.
    public lazy var linkLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()
    
    /// Label for displaying the message text with hyperlinks.
    public lazy var messageLabel: HyperlinkLabel = {
        let label = HyperlinkLabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()
    
    /// Image view for displaying the link's thumbnail.
    public lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)
        imageView.pin(anchors: [.width], to: 232)
        imageView.pin(anchors: [.height], to: 160)
        return imageView
    }()
    
    /// Image view for displaying the favicon of the link.
    public lazy var linkIconImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        return imageView
    }()
    
    /// Styling object for the link preview bubble.
    public var style = LinkPreviewBubbleStyle()
    
    /// The URL of the link being previewed.
    var url: String?
    
    /// Request object for loading images.
    private var imageRequest: Cancellable?
    
    /// Service for loading images.
    private lazy var imageService = ImageService()
    
    /// Regular expression for phone pattern 1.
    let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
    
    /// Regular expression for phone pattern 2.
    let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
    
    /// Regular expression for email pattern.
    let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
    
    /// Reference to the controller where this view is presented.
    weak var controller: UIViewController?
    
    // MARK: - Initializers
    
    /// Initializes a new instance of CometChatLinkPreviewBubble.
    ///
    /// - Parameter frame: The frame rectangle for the view.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    /// Convenience initializer to set the frame and parse a text message for link preview.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the view.
    ///   - message: The text message containing the link preview metadata.
    public convenience init(frame: CGRect, message: TextMessage) {
        self.init(frame: frame)
        parseLinkPreviewForMessage(message: message)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            setupStyle()
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets the link preview bubble with a text message.
    ///
    /// - Parameter message: The text message containing the link preview metadata.
    /// - Returns: The current instance of `CometChatLinkPreviewBubble`.
    @discardableResult
    public func set(message: TextMessage) -> Self {
        parseLinkPreviewForMessage(message: message)
        return self
    }
    
    /// Sets the view controller for handling taps on hyperlinks.
    ///
    /// - Parameter controller: The view controller to handle interactions.
    /// - Returns: The current instance of `CometChatLinkPreviewBubble`.
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
    /// Sets the attributed text for the message label.
    ///
    /// - Parameter attributedText: The attributed string to display.
    /// - Returns: The current instance of `CometChatLinkPreviewBubble`.
    @discardableResult
    public func set(attributedText: NSAttributedString) -> Self {
        for (range, values) in messageLabel.customAttributes {
            messageLabel.customAttributes[range]?.removeValue(forKey: .font)
        }
        self.messageLabel.attributedText = attributedText
        return self
    }
    
    /// Builds the UI components of the link preview bubble.
    open func buildUI() {
        self.generateHyperlinks()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onLinkPreviewClick))
        previewContainerStackView.addGestureRecognizer(tap)
        previewContainerStackView.isUserInteractionEnabled = true
            
        addSubview(previewContainerStackView)
        addSubview(messageLabel)
        
        previewContainerStackView.pin(
            anchors: [.leading, .top],
            to: self,
            with: CometChatSpacing.Padding.p1
        )
        
        previewContainerStackView.pin(
            anchors: [.trailing],
            to: self,
            with: -CometChatSpacing.Padding.p1
        )
        
        messageLabel.pin(
            anchors: [.leading],
            to: self,
            with: CometChatSpacing.Padding.p3
        )
        
        messageLabel.pin(
            anchors: [.trailing],
            to: self,
            with: -CometChatSpacing.Padding.p3
        )
        
        messageLabel.topAnchor.pin(
            equalTo: previewContainerStackView.bottomAnchor,
            constant: CometChatSpacing.Padding.p3
        ).isActive = true
        
        messageLabel.bottomAnchor.pin(
            equalTo: bottomAnchor,
            constant: 0
        ).isActive = true
    }
    
    /// Applies the style settings to the UI components.
    open func setupStyle() {
        title.textColor = style.titleTextColor
        title.font = style.titleTextFont
        subtitle.textColor = style.subtitleTextColor
        subtitle.font = style.subtitleTextFont
        linkLabel.textColor = style.linkTextColor
        linkLabel.font = style.linkTextFont
        messageLabel.textColor = style.messageTextColor
        messageLabel.font = style.messageTextFont
        previewContainerStackView.roundViewCorners(corner: style.previewCornerRadius)
        previewContainerStackView.backgroundColor = style.previewBackgroundColor
        linkIconImageView.roundViewCorners(corner: style.linkIconImageCornerRadios)
        
        messageLabel.customize { label in
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
    
    /// Generates hyperlinks in the message label for phone numbers and emails.
    private func generateHyperlinks() {
        messageLabel.enabledTypes.append(phoneParser1)
        messageLabel.enabledTypes.append(phoneParser2)
        messageLabel.enabledTypes.append(emailParser)
        
        self.messageLabel.handleURLTap { link in
            guard let url = URL(string: "\(link)") else { return }
            UIApplication.shared.open(url)
        }
        
        self.messageLabel.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let url = URL(string: "tel://\(number)")!
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        self.messageLabel.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let url = URL(string: "tel://\(number)")!
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        self.messageLabel.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { [weak self] (emailID) in
            
            guard let this = self else { return }
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = this
                mail.setToRecipients([emailID])
                if let topViewController = this.window?.topViewController() {
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
                title.isHidden = false
                title.text = linkTitle
            } else {
                previewContainerStackView.subviews.forEach({ $0.removeFromSuperview() })
            }
            
            if let description = linkPreview["description"] as? String {
                subtitle.isHidden = false
                subtitle.text = description
            }
            
            self.thumbnailImageView.image = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)
            
            if let thumbnail = linkPreview["image"] as? String , let url = URL(string: thumbnail) {
                
                linkIconImageView.isHidden = true
                imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
                    guard let strongSelf = self else { return }
                    if let image = image {
                        if #available(iOS 15.0, *) {
                            image.prepareForDisplay { preparedImage in
                                DispatchQueue.main.async {
                                    strongSelf.thumbnailImageView.image = preparedImage
                                }
                            }
                        } else {
                            strongSelf.thumbnailImageView.image = image
                        }
                    }
                }
                
            }else if let favIcon = linkPreview["favicon"] as? String , let url = URL(string: favIcon) {
                
                thumbnailImageView.isHidden = true
                linkIconImageView.pin(anchors: [.height, .width], to: 40)
                imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
                    guard let strongSelf = self else { return }
                    if let image = image {
                        if #available(iOS 15.0, *) {
                            image.prepareForDisplay { preparedImage in
                                DispatchQueue.main.async {
                                    strongSelf.linkIconImageView.image = preparedImage
                                }
                            }
                        } else {
                            strongSelf.linkIconImageView.image = image
                        }
                    }
                }
            }
            if let linkURL = linkPreview["url"] as? String {
                self.linkLabel.text = linkURL
                self.url = linkURL
            }
        }
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


