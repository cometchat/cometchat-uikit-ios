//
//  CompactMessageComposerStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import UIKit

/// Style configuration for the single line composer
public struct CompactMessageComposerStyle {
    
    // MARK: - Container Styling
    public var backgroundColor: UIColor = UIColor.dynamicColor(
        lightModeColor: CometChatTheme.backgroundColor03.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
        darkModeColor: CometChatTheme.backgroundColor02.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
    )
    public var cornerRadius: CometChatCornerStyle?
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    
    // MARK: - Compose Box Styling
    public var composeBoxBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var composeBoxBorderColor: UIColor = CometChatTheme.borderColorDefault
    public var composeBoxBorderWidth: CGFloat = 1
    public var composeBoxCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    public var composerSeparatorColor: UIColor = CometChatTheme.borderColorLight
    
    // MARK: - Text Field Styling
    public var textFieldFont: UIFont = CometChatTypography.Body.regular
    public var textFieldColor: UIColor = CometChatTheme.textColorPrimary
    public var placeholderFont: UIFont = CometChatTypography.Body.regular
    public var placeholderColor: UIColor = CometChatTheme.textColorTertiary
    
    // MARK: - Code Block Styling
    public var codeBlockBackgroundColor: UIColor = {
        // Use dynamic color that adapts to light/dark mode
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(hex: "#2C2C2E")  // Dark gray for dark mode
                default:
                    return UIColor(hex: "#F5F5F5")  // Light gray for light mode
                }
            }
        } else {
            return UIColor(hex: "#F5F5F5")
        }
    }()
    public var codeBlockBorderColor: UIColor = {
        // Use dynamic color that adapts to light/dark mode
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(hex: "#3A3A3C")  // Darker border for dark mode
                default:
                    return UIColor(hex: "#E8E8E8")  // Light border for light mode
                }
            }
        } else {
            return UIColor(hex: "#E8E8E8")
        }
    }()
    public var codeBlockBorderWidth: CGFloat = 1
    public var codeBlockLeftBorderColor: UIColor = .clear  // No left border
    public var codeBlockPlaceholder: String = ""  // No placeholder
    public var codeBlockPlaceholderColor: UIColor = CometChatTheme.textColorTertiary
    
    // MARK: - Send Button Styling
    public var sendButtonImage: UIImage = UIImage(named: "custom-send", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var sendButtonImageTint: UIColor = CometChatTheme.white
    
    private var _activeSendButtonBackgroundColor: UIColor?
    public var activeSendButtonBackgroundColor: UIColor {
        get { return _activeSendButtonBackgroundColor ?? CometChatTheme.primaryColor }
        set { _activeSendButtonBackgroundColor = newValue }
    }
    public var inactiveSendButtonBackgroundColor: UIColor = CometChatTheme.neutralColor300
    
    // MARK: - Action Button Styling
    public var attachmentImage: UIImage = UIImage(systemName: "plus.circle")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var attachmentImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    public var voiceRecordingImage: UIImage = UIImage(systemName: "mic")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var voiceRecordingImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    // MARK: - Stickers Button Styling
    public var stickersImage: UIImage = UIImage(named: "sticker-image", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var stickersImageTint: UIColor = CometChatTheme.iconColorSecondary
    public var stickersActiveImageTint: UIColor = CometChatTheme.primaryColor
    
    // MARK: - Preview Styling
    public var previewTitleFont: UIFont = CometChatTypography.Body.regular
    public var previewMessageFont: UIFont = CometChatTypography.Caption1.regular
    public var previewTitleColor: UIColor = CometChatTheme.textColorPrimary
    public var previewMessageColor: UIColor = CometChatTheme.textColorSecondary
    public var previewBackgroundColor: UIColor = CometChatTheme.backgroundColor03
    public var previewCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r1)
    
    private var _previewBorderColor: UIColor?
    public var previewBorderColor: UIColor {
        get { return _previewBorderColor ?? CometChatTheme.borderColorHighlight }
        set { _previewBorderColor = newValue }
    }
    public var previewBorderWidth: CGFloat = 0
    public var previewCloseIcon: UIImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    private var _previewCloseIconTint: UIColor?
    public var previewCloseIconTint: UIColor {
        get { return _previewCloseIconTint ?? CometChatTheme.iconColorHighlight }
        set { _previewCloseIconTint = newValue }
    }
    
    // MARK: - Mention Limit Banner Styling
    public var infoIcon: UIImage = UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var infoIconTint: UIColor = CometChatTheme.errorColor
    public var infoTextColor: UIColor = CometChatTheme.errorColor
    public var infoTextFont: UIFont = CometChatTypography.Caption1.regular
    public var infoBackgroundColor: UIColor = CometChatTheme.backgroundColor02
    
    // MARK: - Rich Text Toolbar Style
    public var richTextToolbarStyle: RichTextToolbarStyle = RichTextToolbarStyle()
    
    // MARK: - Agentic Mode Send Button Styling
    public var agenticSendButtonImage: UIImage = UIImage(systemName: "arrow.up")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var agenticSendButtonImageTint: UIColor = CometChatTheme.neutralColor50
    public var agenticActiveSendButtonBackgroundColor: UIColor = CometChatTheme.neutralColor900
    public var agenticInactiveSendButtonBackgroundColor: UIColor = CometChatTheme.neutralColor300
    
    public init() { }
}
