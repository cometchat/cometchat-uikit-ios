//
//  CollaborativeDocumentStyle.swift
 
//
//  Created by Abdullah Ansari on 19/05/22.
//

import Foundation
import UIKit

public struct CallBubbleStyle: BaseMessageBubbleStyle {
    
    public var avatarStyle: AvatarStyle?
    public var dateStyle: DateStyle?
    public var receiptStyle: ReceiptStyle?
    public var backgroundColor: UIColor?
    public var backgroundDrawable: UIImage?
    public var cornerRadius: CometChatCornerStyle? = nil
    public var borderWidth: CGFloat?
    public var borderColor: UIColor?
    public var headerTextColor: UIColor?
    public var headerTextFont: UIFont?
    public var threadedIndicatorTextFont: UIFont?
    public var threadedIndicatorTextColor: UIColor?
    public var threadedIndicatorImageTint: UIColor?
    
    public var titleTextFont: UIFont = CometChatTypography.Body.medium
    public var titleTextColor: UIColor = CometChatTheme.white
    public var subtitleTextFont: UIFont = CometChatTypography.Caption1.regular
    public var subtitleTextColor: UIColor = CometChatTheme.white
    public var joinButtonTextColor: UIColor = CometChatTheme.white
    public var joinButtonTextFont: UIFont = CometChatTypography.Button.medium
    public var callImageTintColor: UIColor = CometChatTheme.iconColorHighlight
    public var audioCallImage: UIImage = UIImage(systemName: "phone.arrow.down.left.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var videoCallImage: UIImage = UIImage(systemName: "arrow.down.left.video.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var callImageBackgroundColor : UIColor = CometChatTheme.white
    public var callImageBorderWidth : CGFloat = 0
    public var callImageBorderColor : UIColor = .clear
    public var callImageCornerRadius : CometChatCornerStyle? = nil
    public var separatorBackgroundColor : UIColor = CometChatTheme.white.withAlphaComponent(0.3)
    
    public var reactionsStyle: ReactionsStyle?
    
    public init() {
        
    }
    
    //for default values according to the bubble type
    internal init(styleType: BubbleStyleType) {
        switch styleType {
        case .incoming:
            titleTextColor = CometChatTheme.neutralColor900
            subtitleTextColor = CometChatTheme.neutralColor600
            joinButtonTextColor = CometChatTheme.textColorHighlight
            videoCallImage = UIImage(systemName: "arrow.down.left.video.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            audioCallImage = UIImage(systemName: "phone.arrow.down.left.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            separatorBackgroundColor = CometChatTheme.borderColorDark
        case .outgoing:
            titleTextColor = CometChatTheme.white
            subtitleTextColor = CometChatTheme.white
            joinButtonTextColor = CometChatTheme.white
            videoCallImage = UIImage(systemName: "arrow.up.right.video.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            audioCallImage = UIImage(systemName: "phone.arrow.up.right.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            separatorBackgroundColor = CometChatTheme.white.withAlphaComponent(0.3)
        }
    }
}


