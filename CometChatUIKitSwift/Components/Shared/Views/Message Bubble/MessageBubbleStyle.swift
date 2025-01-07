//
//  MessageBubbleStyle.swift
//  
//
//  Created by Abdullah Ansari on 24/08/22.
//

import UIKit

public struct MessageBubbleStyle {
    
    //normal public variable for component wise styling
    public var backgroundColor: UIColor = CometChatTheme.primaryColor
    public var backgroundDrawable: UIImage?
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle = CometChatCornerStyle(cornerRadius: CometChatSpacing.Radius.r3)
    public var headerTextColor: UIColor = CometChatTheme.primaryColor
    public var headerTextFont: UIFont = CometChatTypography.Caption1.medium
    public var threadedIndicatorTextFont: UIFont = CometChatTypography.Caption1.regular
    public var threadedIndicatorTextColor: UIColor = CometChatTheme.textColorPrimary
    public var threadedIndicatorImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    public lazy var avatarStyle: AvatarStyle = {
        var avatarStyle = CometChatAvatar.style
        avatarStyle.textFont = CometChatTypography.Heading4.bold
        return avatarStyle
    }()
    public lazy var dateStyle: DateStyle = CometChatDate.style
    public lazy var receiptStyle: ReceiptStyle = CometChatReceipt.style
    
    public var textBubbleStyle: TextBubbleStyle
    public var imageBubbleStyle: ImageBubbleStyle
    public var videoBubbleStyle: VideoBubbleStyle
    public var stickersBubbleStyle: StickerBubbleStyle
    public var audioBubbleStyle: AudioBubbleStyle
    public var fileBubbleStyle: FileBubbleStyle
    public var collaborativeWhiteboardBubbleStyle: CollaborativeBubbleStyle
    public var collaborativeDocumentBubbleStyle: CollaborativeBubbleStyle
    public var messageTranslationBubbleStyle: MessageTranslationBubbleStyle
    public var deleteBubbleStyle: DeleteBubbleStyle
    public var pollBubbleStyle: PollBubbleStyle
    public var linkPreviewBubbleStyle: LinkPreviewBubbleStyle
    public var callBubbleStyle: CallBubbleStyle
    
    public lazy var reactionsStyle: ReactionsStyle = {
        var reactionsStyle = CometChatReactions.style
        return reactionsStyle
    }()
    
    public init() {
        callBubbleStyle = CallBubbleStyle()
        linkPreviewBubbleStyle = LinkPreviewBubbleStyle()
        textBubbleStyle = TextBubbleStyle()
        imageBubbleStyle = ImageBubbleStyle()
        videoBubbleStyle = VideoBubbleStyle()
        fileBubbleStyle = FileBubbleStyle()
        collaborativeWhiteboardBubbleStyle = CollaborativeBubbleStyle()
        collaborativeDocumentBubbleStyle = CollaborativeBubbleStyle()
        stickersBubbleStyle = StickerBubbleStyle()
        audioBubbleStyle = AudioBubbleStyle()
        messageTranslationBubbleStyle = MessageTranslationBubbleStyle()
        deleteBubbleStyle = DeleteBubbleStyle()
        pollBubbleStyle = PollBubbleStyle()
    }
    
    //for default values according to the bubble type
    internal init(styleType: BubbleStyleType) {
        textBubbleStyle = TextBubbleStyle(styleType: styleType)
        imageBubbleStyle = ImageBubbleStyle(styleType: styleType)
        videoBubbleStyle = VideoBubbleStyle(styleType: styleType)
        fileBubbleStyle = FileBubbleStyle(styleType: styleType)
        linkPreviewBubbleStyle = LinkPreviewBubbleStyle(styleType: styleType)
        collaborativeWhiteboardBubbleStyle = CollaborativeBubbleStyle(styleType: styleType)
        collaborativeDocumentBubbleStyle = CollaborativeBubbleStyle(styleType: styleType)
        stickersBubbleStyle = StickerBubbleStyle(styleType: styleType)
        audioBubbleStyle = AudioBubbleStyle(styleType: styleType)
        messageTranslationBubbleStyle = MessageTranslationBubbleStyle(styleType: styleType)
        deleteBubbleStyle = DeleteBubbleStyle(styleType: styleType)
        pollBubbleStyle = PollBubbleStyle(styleType: styleType)
        callBubbleStyle = CallBubbleStyle(styleType: styleType)

        switch styleType {
        case .incoming:
            dateStyle.textColor = CometChatTheme.neutralColor600
            dateStyle.textFont = CometChatTypography.Caption2.regular
            backgroundColor = CometChatTheme.neutralColor300
        case .outgoing:
            backgroundColor = CometChatTheme.primaryColor
            dateStyle.textColor = CometChatTheme.white
            dateStyle.textFont = CometChatTypography.Caption2.regular
        }
        dateStyle.borderWidth = 0
        dateStyle.backgroundColor = .clear
        
    }
}

public protocol BaseMessageBubbleStyle {
    var backgroundColor: UIColor? { get set }
    var backgroundDrawable: UIImage? { get set }
    var borderWidth: CGFloat? { get set }
    var borderColor: UIColor? { get set }
    var cornerRadius: CometChatCornerStyle? { get set }
    var avatarStyle: AvatarStyle? { get set }
    var dateStyle: DateStyle? { get set }
    var receiptStyle: ReceiptStyle? { get set }
    var headerTextColor: UIColor? { get set }
    var headerTextFont: UIFont? { get set }
    var threadedIndicatorTextFont: UIFont? { get set }
    var threadedIndicatorTextColor: UIColor? { get set }
    var threadedIndicatorImageTint: UIColor? { get set }
    var reactionsStyle: ReactionsStyle? { get set }
}

enum BubbleStyleType {
    case incoming
    case outgoing
}
