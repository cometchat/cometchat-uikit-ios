//
//  MessageComposerStyle.swift
//  
//
//  Created by Abdullah Ansari on 07/09/22.
//

import UIKit

public struct MessageComposerStyle {
    
    public var placeHolderTextFont: UIFont = CometChatTypography.Body.regular
    public var placeHolderTextColor: UIColor = CometChatTheme.textColorTertiary
    public var textFiledColor: UIColor = CometChatTheme.textColorPrimary
    public var textFiledFont: UIFont = CometChatTypography.Body.regular
    
    public var backgroundColor: UIColor = UIColor.dynamicColor(
        lightModeColor: CometChatTheme.backgroundColor03.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
        darkModeColor: CometChatTheme.backgroundColor02.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
    )
    public var cornerRadius: CometChatCornerStyle?
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var sendButtonImage: UIImage = UIImage(named: "custom-send", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var sendButtonImageTint: UIColor = CometChatTheme.white
    public var activeSendButtonImageBackgroundColor: UIColor = CometChatTheme.primaryColor
    public var inactiveSendButtonImageBackgroundColor: UIColor = CometChatTheme.neutralColor300
    
    public var composeBoxBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var composeBoxBorderColor: UIColor = CometChatTheme.borderColorDefault
    public var composeBoxBorderWidth: CGFloat = 1
    public var composerBoxCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    public var composerSeparatorColor: UIColor = CometChatTheme.borderColorLight
    
    public var attachmentImage: UIImage = UIImage(systemName: "plus.circle")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var attachmentImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    public var voiceRecordingImage: UIImage = UIImage(systemName: "mic")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var voiceRecordingImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    public var aiImage: UIImage = UIImage(named: "ai-image", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var aiImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    public var stickerImage: UIImage = UIImage(named: "sticker-image", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var stickerTint: UIColor = CometChatTheme.iconColorSecondary
    
    public var editPreviewTitleTextFont: UIFont = CometChatTypography.Body.regular
    public var editPreviewMessageTextFont: UIFont = CometChatTypography.Caption1.regular
    public var editPreviewTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    public var editPreviewMessageTextColor: UIColor = CometChatTheme.textColorSecondary
    public var editPreviewBackgroundColor: UIColor = CometChatTheme.backgroundColor03
    public var editPreviewCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r1)
    public var editPreviewBorderColor: UIColor = .clear
    public var editPreviewBorderWidth: CGFloat = 0
    public var editPreviewCloseIcon: UIImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var editPreviewCloseIconTint: UIColor = CometChatTheme.iconColorPrimary
    
    public var infoIcon: UIImage = UIImage(systemName: "info.circle")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var infoIconTint: UIColor = CometChatTheme.errorColor
    public var infoTextColor: UIColor = CometChatTheme.errorColor
    public var infoTextFont: UIFont = CometChatTypography.Caption1.regular
    public var infoSeparatorColor: UIColor = CometChatTheme.borderColorLight
    public var infoBackgroundColor: UIColor = CometChatTheme.backgroundColor02
    public var infoCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r1)
    public var infoBorderColor: UIColor = .clear
    public var infoBorderWidth: CGFloat = 0

    
}
