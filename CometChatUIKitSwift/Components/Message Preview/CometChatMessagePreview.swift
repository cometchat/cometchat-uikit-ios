//
//  CometChatMessagePreview.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 13/11/25.
//

import Foundation
import UIKit
import CometChatSDK


open class CometChatMessagePreview: UIView {
    
    var title: String
    var subTitle: NSAttributedString
    var message: BaseMessage
    var onCrossIconClicked: (() -> ())?
    var onPreviewClicked: (() -> ())?
    
    //MARK: Styling
    public static var style = MessagePreviewStyle() //global styling
    public lazy var style = CometChatMessagePreview.style //component level styling
    
    public let titleLabel = UILabel().withoutAutoresizingMaskConstraints()
    public let closeButton = UIButton().withoutAutoresizingMaskConstraints()
    public let subtitleLabel = UILabel().withoutAutoresizingMaskConstraints()
    public let subtitleStack = UIStackView().withoutAutoresizingMaskConstraints()
    var previewButton = UIButton().withoutAutoresizingMaskConstraints()
    
    public lazy var accentView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = CometChatTheme.borderColorHighlight
        view.widthAnchor.pin(equalToConstant: 4).isActive = true
        view.clipsToBounds = true
        return view
    }()
    
    // New image view (to appear before subtitle text)
    public lazy var leadingIconView: UIImageView = {
        let iv = UIImageView().withoutAutoresizingMaskConstraints()
        iv.contentMode = .scaleAspectFit
        iv.pin(anchors: [.width, .height], to: 12)
        iv.isHidden = true
        return iv
    }()
    
    init(title: String, subTitle: NSAttributedString, message: BaseMessage) {
        self.title = title
        self.subTitle = subTitle
        self.message = message
        super.init(frame: .null)
        buildUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
        }
    }
    
    func buildUI() {
                
        var constrainsToActivate = [NSLayoutConstraint]()
        
        addSubview(accentView)
        constrainsToActivate += [
            accentView.topAnchor.pin(equalTo: topAnchor),
            accentView.leadingAnchor.pin(equalTo: leadingAnchor),
            accentView.bottomAnchor.pin(equalTo: bottomAnchor)
        ]
        
        titleLabel.text = title
        
        addSubview(titleLabel)
        constrainsToActivate += [
            titleLabel.topAnchor.pin(equalTo: topAnchor, constant: CometChatSpacing.Padding.p2),
            titleLabel.leadingAnchor.pin(equalTo: accentView.trailingAnchor, constant: CometChatSpacing.Padding.p2),
            titleLabel.trailingAnchor.pin(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p2)
        ]
        
        
        closeButton.tintColor = CometChatTheme.iconColorSecondary
        
        closeButton.pin(anchors: [.height, .width], to: 15)
        closeButton.addTarget(self, action: #selector(onCrossIconTapped), for: .primaryActionTriggered)
        addSubview(closeButton)
        constrainsToActivate += [
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p2),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: CometChatSpacing.Padding.p2)
        ]
        
        // Subtitle label
        
        subtitleLabel.attributedText = subTitle
        subtitleLabel.numberOfLines = 1
        
        // NEW: Create a horizontal stack containing the image + subtitle
        
        subtitleStack.axis = .horizontal
        subtitleStack.alignment = .center
        subtitleStack.spacing = CometChatSpacing.Spacing.s1
        addSubview(subtitleStack)
        subtitleStack.addArrangedSubview(leadingIconView)
        subtitleStack.addArrangedSubview(subtitleLabel)
        
        
        constrainsToActivate += [
            subtitleStack.topAnchor.pin(equalTo: titleLabel.bottomAnchor, constant: CometChatSpacing.Padding.p1),
            subtitleStack.leadingAnchor.pin(equalTo: titleLabel.leadingAnchor),
            subtitleStack.trailingAnchor.pin(equalTo: closeButton.leadingAnchor),
            subtitleStack.bottomAnchor.pin(equalTo: bottomAnchor, constant: -CometChatSpacing.Padding.p2)
        ]
        
        addSubview(previewButton)
        previewButton.addTarget(self, action: #selector(onPreviewButtonTapped), for: .primaryActionTriggered)
        constrainsToActivate += [
            previewButton.topAnchor.pin(equalTo: topAnchor),
            previewButton.leadingAnchor.pin(equalTo: leadingAnchor),
            previewButton.trailingAnchor.pin(equalTo: closeButton.leadingAnchor),
            previewButton.bottomAnchor.pin(equalTo: bottomAnchor)
        ]
        
        
        NSLayoutConstraint.activate(constrainsToActivate)
        
        
        if message.deletedAt > 0{
            setIcon(UIImage(named: "message-deleted", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
        } else{
            let type = message.messageType
            switch type {
            case .text:
                break
            case .image:
                setIcon(UIImage(systemName: "photo"))
            case .video:
                setIcon(UIImage(systemName: "video"))
            case .audio:
                setIcon(UIImage(systemName: "mic.fill"))
            case .file:
                setIcon(UIImage(systemName: "doc.fill"))
            case .custom:
                if let customMessage = message as? CustomMessage {
                    switch customMessage.type {
                    case "extension_sticker":
                        setIcon(UIImage(named: "sticker-image-filled", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    case "extension_poll":
                        setIcon(UIImage(named: "polls.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    case "extension_whiteboard":
                        setIcon(UIImage(named: "collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    case "extension_document":
                        setIcon(UIImage(named: "collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    case "meeting":
                        setIcon(UIImage(systemName: "doc.fill"))
                    case .none:
                        break
                    case .some(_):
                        break
                    }
                }
            default:
                break
            }
        }
    }
    
    func setupStyle(){
        backgroundColor = style.backgroundColor
        borderWith(width: style.borderWidth)
        roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r1))
        borderColor(color: style.borderColor)
        closeButton.setImage(style.previewCloseIcon, for: .normal)
        titleLabel.textColor = style.titleTextColor
        titleLabel.font = style.titleTextFont
        subtitleLabel.textColor = style.subtitleTextColor
        subtitleLabel.font = style.subtitleTextFont
        accentView.backgroundColor = style.indicatorViewBackgroundColor
        leadingIconView.tintColor = style.subtitleImageTintColor
    }
    
    /// Allows setting an image icon dynamically (optional)
    public func setIcon(_ image: UIImage?) {
        if let image = image {
            leadingIconView.isHidden = false
            leadingIconView.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            leadingIconView.isHidden = true
            leadingIconView.image = nil
        }
    }
    
    // Add this inside CometChatMessagePreview class (e.g. right after setupStyle())

    /// Factory that produces a configured CometChatMessagePreview with correct subtitle, icon, style and callbacks.
    /// - Parameters:
    ///   - message: message to show preview for
    ///   - isLoggedInUser: whether the sender is the logged in user
    ///   - textFormatters: optional text formatters array (keeps compatibility with different callers)
    ///   - formattingType: whether formatting is for composer or bubble
    ///   - style: optional explicit style (falls back to component/global style)
    ///   - onPreviewClicked: optional tap callback for preview
    ///   - onCrossClicked: optional cross/close callback
    ///   - hideCloseButton: if true, the close button will be hidden
    public static func makePreview(
        for message: BaseMessage,
        isLoggedInUser: Bool,
        textFormatters: Any? = nil,                       // keeps compatibility with callers that store formatter in different names
        formattingType: FormattingType = .MESSAGE_BUBBLE, // use your MessageUtils formatting enum
        style: MessagePreviewStyle? = nil,
        onPreviewClicked: (() -> Void)? = nil,
        onCrossClicked: (() -> Void)? = nil,
        hideCloseButton: Bool? = nil
    ) -> CometChatMessagePreview {
        
        // Title
        let senderName = isLoggedInUser ? "You" : (message.sender?.name ?? message.senderUid)
        
        // Default text
        var attributed = NSAttributedString(string: MessageUtils.quotedMessageText(for: message))
        
        // Attempt to process text formatters only if we can cast them to expected type
        if let textMsg = message as? TextMessage,
           textMsg.deletedAt <= 0 {
            
            if let tf = textFormatters as? [Any], !tf.isEmpty {
                // If library's TextFormatter type exists, MessageUtils.processTextFormatter expects it.
                // Try to cast to the real type, otherwise skip formatting.
                if let realTF = tf as? [CometChatTextFormatter] {
                    attributed = MessageUtils.processTextFormatter(message: textMsg,
                                                                   textFormatter: realTF,
                                                                   formattingType: formattingType)
                } else {
                    // If user passed a single formatter object or different collection type, try one-level cast
                    if let single = textFormatters as? CometChatTextFormatter {
                        attributed = MessageUtils.processTextFormatter(message: textMsg,
                                                                       textFormatter: [single],
                                                                       formattingType: formattingType)
                    }
                    // else leave attributed as default quoted text
                }
            } else if let tf = textFormatters as? CometChatTextFormatter {
                // single formatter object
                attributed = MessageUtils.processTextFormatter(message: textMsg,
                                                               textFormatter: [tf],
                                                               formattingType: formattingType)
            }
        }
        
        // Deleted message override
        if message.deletedAt > 0 {
            attributed = NSAttributedString(string: "This message was deleted")
        }
        
        // Build appropriate subtitle for CustomMessage
        var subtitleAttr: NSAttributedString = attributed
        if let cm = message as? CustomMessage {
            if let convText = cm.conversationText, !convText.isEmpty {
                subtitleAttr = NSAttributedString(string: cm.deletedAt > 0 ? "This message was deleted" : convText)
            } else if let push = cm.metaData?["pushNotification"] as? String {
                subtitleAttr = NSAttributedString(string: cm.deletedAt > 0 ? "This message was deleted" : push)
            } else {
                var fallback = cm.type ?? ""
                switch cm.type {
                case "extension_sticker": fallback = "Sticker"
                case "extension_poll": fallback = "Polls"
                case "extension_whiteboard": fallback = "Collaborative Whiteboard"
                case "extension_document": fallback = "Collaborative Document"
                case "meeting": fallback = "Meeting"
                default: break
                }
                subtitleAttr = NSAttributedString(string: cm.deletedAt > 0 ? "This message was deleted" : fallback)
            }
        }
        
        // Create preview instance
        let preview = CometChatMessagePreview(title: senderName, subTitle: subtitleAttr, message: message)
        
        // Apply style if provided, otherwise keep preview.style (component/global)
        if let s = style {
            preview.style = s
        }
        
        // wire callbacks
        preview.onPreviewClicked = onPreviewClicked
        preview.onCrossIconClicked = onCrossClicked
        
        // hide closeButton if caller wants it
        if let hide = hideCloseButton {
            preview.closeButton.isHidden = hide
        } else {
            // if no explicit value is provided, keep default (visible unless caller hides later)
            preview.closeButton.isHidden = (onCrossClicked == nil)
        }
        
        // Ensure style is applied now (so caller can add to hierarchy and layoutIfNeeded safely)
        preview.setupStyle()
        
        // Set icon based on message type (reuse existing setIcon implementation)
        if message.deletedAt > 0 {
            preview.setIcon(UIImage(named: "message-deleted", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate))
        } else {
            switch message.messageType {
            case .text:
                preview.setIcon(nil)
            case .image:
                preview.setIcon(UIImage(systemName: "photo"))
            case .video:
                preview.setIcon(UIImage(systemName: "video"))
            case .audio:
                preview.setIcon(UIImage(systemName: "mic.fill"))
            case .file:
                preview.setIcon(UIImage(systemName: "doc.fill"))
            case .custom:
                if let customMessage = message as? CustomMessage {
                    switch customMessage.type {
                    case "extension_sticker":
                        preview.setIcon(UIImage(named: "sticker-image-filled", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
                    case "extension_poll":
                        preview.setIcon(UIImage(named: "polls.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
                    case "extension_whiteboard":
                        preview.setIcon(UIImage(named: "collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
                    case "extension_document":
                        preview.setIcon(UIImage(named: "collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate))
                    case "meeting":
                        preview.setIcon(UIImage(systemName: "doc.fill"))
                    default:
                        preview.setIcon(nil)
                    }
                } else {
                    preview.setIcon(nil)
                }
            @unknown default:
                preview.setIcon(nil)
            }
        }
        
        return preview
    }

    
    @objc func onCrossIconTapped() {
        onCrossIconClicked?()
    }
    
    @objc func onPreviewButtonTapped() {
        onPreviewClicked?()
    }
}

