//
//  MediaRecorderStyle.swift
//
//
//  Created by Abhishek Saralaya on 10/08/23.
//

import UIKit

public struct MediaRecorderStyle {
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderWidth: CGFloat = 1
    public var borderColor: UIColor = CometChatTheme.borderColorLight
    public var cornerRadius: CometChatCornerStyle? = nil
    public var recordingButtonBackgroundColor: UIColor = CometChatTheme.iconColorHighlight
    public var recordingButtonCornerRadius: CometChatCornerStyle? = nil
    public var recordingButtonBorderWidth: CGFloat = 0
    public var recordingButtonBorderColor: UIColor = .clear
    public var recordingButtonImageTintColor: UIColor = CometChatTheme.white
    public var recordingButtonImage : UIImage = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var deleteButtonBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var deleteButtonImageTintColor: UIColor = CometChatTheme.iconColorSecondary
    public var deleteButtonImage: UIImage = UIImage(systemName: "trash.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var deleteButtonCornerRadius: CometChatCornerStyle? = nil
    public var deleteButtonBorderWidth : CGFloat = 1
    public var deleteButtonBorderColor: UIColor = CometChatTheme.borderColorLight
    
    public var stopButtonBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var stopButtonImageTintColor: UIColor = CometChatTheme.iconColorSecondary
    public var stopButtonImage: UIImage = UIImage(systemName: "stop.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var stopButtonCornerRadius: CometChatCornerStyle? = nil
    public var stopButtonBorderWidth: CGFloat = 1
    public var stopButtonBorderColor: UIColor = CometChatTheme.borderColorLight
    
    public var sendButtonBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var sendButtonImageTintColor: UIColor = CometChatTheme.iconColorHighlight
    public var sendButtonImage: UIImage = UIImage(named: "custom-send", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var sendButtonBorderWidth: CGFloat = 1
    public var sendButtonBorderColor: UIColor = CometChatTheme.borderColorLight
    public var sendButtonCornerRadius: CometChatCornerStyle? = nil
    
    public var playButtonImageTintColor: UIColor = CometChatTheme.errorColor
    public var playButtonBackgroundColor: UIColor = CometChatTheme.white
    
    public var pauseButtonBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var pauseButtonImageTintColor: UIColor = CometChatTheme.errorColor
    public var pausebuttonImage: UIImage = UIImage(systemName: "pause.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var pauseButtonCornerRadius: CometChatCornerStyle? = nil
    public var pauseButtonBorderWidth: CGFloat = 1
    public var pauseButtonBorderColor: UIColor = CometChatTheme.borderColorLight
    
    public var startButtonImage: UIImage = UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var startButtonImageTintColor: UIColor = CometChatTheme.errorColor
    public var startButtonBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var startButtonCornerRadius: CometChatCornerStyle? = nil
    public var startButtonBorderWidth: CGFloat = 1
    public var startButtonBorderColor: UIColor = CometChatTheme.borderColorLight
    
    public var reRecordImage: UIImage = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var reRecordButtonImageTintColor : UIColor = CometChatTheme.iconColorSecondary
    public var reRecordButtonBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var reRecordButtonCornerRadius: CometChatCornerStyle? = nil
    public var reRecordButtonBorderWidth: CGFloat = 1
    public var reRecordButtonBorderColor: UIColor = CometChatTheme.borderColorLight
    
    public var recorderIndicatorTintColor: UIColor = CometChatTheme.white
    public var textFont: UIFont = CometChatTypography.Heading4.regular
    public var textColor: UIColor = CometChatTheme.textColorPrimary
    public var messageBubbleStyle = MessageBubbleStyle(styleType: .outgoing)
    
    public init() { }
}
