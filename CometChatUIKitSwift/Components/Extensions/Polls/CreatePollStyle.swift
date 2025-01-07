//
//  CreatePollStyle.swift
//  
//
//  Created by Abdullah Ansari on 26/09/22.
//

import UIKit

public struct CreatePollStyle {

    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = CometChatTheme.borderColorLight
    public var cornerRadius: CometChatCornerStyle? = nil
    public var titleFont = CometChatTypography.Heading2.bold
    public var titleColor = CometChatTheme.textColorPrimary
    public var separatorColor: UIColor = CometChatTheme.borderColorLight
    public var questionPlaceholderColor = CometChatTheme.textColorTertiary
    public var questionPlaceholderFont = CometChatTypography.Body.medium
    public var questionTitleTextColor = CometChatTheme.textColorPrimary
    public var questionTitleTextFont = CometChatTypography.Heading4.regular
    public var optionsPlaceholderColor = CometChatTheme.textColorTertiary
    public var optionsPlaceholderFont = CometChatTypography.Body.medium
    public var optionsTitleTextColor = CometChatTheme.textColorPrimary
    public var optionsTitleTextFont = CometChatTypography.Heading4.regular
    public var optionsTextColor = CometChatTheme.textColorPrimary
    public var optionsTextFont = CometChatTypography.Body.medium
    public var questionTextColor = CometChatTheme.textColorPrimary
    public var questionTextFont = CometChatTypography.Body.medium
    public var questionInputBoxCornerRadius: CometChatCornerStyle? = nil
    public var questionInputBoxBackground = CometChatTheme.backgroundColor03
    public var questionInputBoxBorderColor: UIColor = CometChatTheme.borderColorDefault
    public var questionInputBoxBorderWidth: CGFloat = 0
    public var optionsInputBoxCornerRadius: CometChatCornerStyle? = nil
    public var optionsInputBoxBackground: UIColor = CometChatTheme.backgroundColor03
    public var optionsInputBoxBorderColor: UIColor = CometChatTheme.borderColorDefault
    public var optionsInputBoxBorderWidth: CGFloat = 0
    public var cancelButtonTextColor = CometChatTheme.textColorSecondary
    public var cancelButtonTextFont = CometChatTypography.Heading4.medium
    public var cancelButtonBackgroundColor: UIColor = .clear
    public var cancelButtonCornerRadius: CometChatCornerStyle? = nil
    public var cancelButtonBorderColor: UIColor = .clear
    public var cancelButtonBorderWidth: CGFloat = 0
    public var sendButtonTextColor = CometChatTheme.textColorHighlight
    public var sendButtonDisabledTextColor = CometChatTheme.neutralColor400
    public var sendButtonTextFont = CometChatTypography.Heading4.medium
    public var sendButtonBackgroundColor: UIColor = .clear
    public var sendButtonCornerRadius: CometChatCornerStyle? = nil
    public var sendButtonBorderColor: UIColor = .clear
    public var sendButtonBorderWidth: CGFloat = 0
    public var deleteButtonTintColor : UIColor = CometChatTheme.iconColorSecondary
    public var deleteButtonImage: UIImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var dragButtonTintColor : UIColor = CometChatTheme.iconColorSecondary
    public var dragButtonImage: UIImage = UIImage(named: "drag-options-icon", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var errorViewBackgroundColor: UIColor = CometChatTheme.errorColor.withAlphaComponent(0.1)
    public var errorViewBorderWidth: CGFloat = 0
    public var errorViewBorderColor: UIColor = .clear
    public var errorViewCornerRadius: CometChatCornerStyle? = nil
    public var errorTextColor: UIColor = CometChatTheme.errorColor
    public var errorTextFont: UIFont = CometChatTypography.Body.regular
    public var errorImage: UIImage = UIImage(systemName: "exclamationmark.circle")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var errorImageTintColor: UIColor = CometChatTheme.errorColor
    
    public init() { }
}


