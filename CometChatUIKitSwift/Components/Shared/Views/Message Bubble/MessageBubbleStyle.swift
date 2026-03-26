//
//  MessageBubbleStyle.swift
//  
//
//  Created by Abdullah Ansari on 24/08/22.
//

import UIKit

public struct MessageBubbleStyle {
    
    //normal public variable for component wise styling
    private var _backgroundColor: UIColor?
    public var backgroundColor: UIColor {
        get { return _backgroundColor ?? CometChatTheme.primaryColor }
        set { _backgroundColor = newValue }
    }
    
    public var backgroundDrawable: UIImage?
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle = CometChatCornerStyle(cornerRadius: CometChatSpacing.Radius.r3)
    
    private var _headerTextColor: UIColor?
    public var headerTextColor: UIColor {
        get { return _headerTextColor ?? CometChatTheme.primaryColor }
        set { _headerTextColor = newValue }
    }
    
    public var headerTextFont: UIFont = CometChatTypography.Caption1.medium
    public var threadedIndicatorTextFont: UIFont = CometChatTypography.Caption1.regular
    public var threadedIndicatorTextColor: UIColor = CometChatTheme.textColorPrimary
    public var threadedIndicatorImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    public var avatarStyle: AvatarStyle
    public var dateStyle: DateStyle
    public var receiptStyle: ReceiptStyle
    
    public var textBubbleStyle: TextBubbleStyle
    public var aiAssistantBubbleStyle: AIAssistantBubbleStyle
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
    public var moderationStyle: ModerationStyle
    public var messagePreviewStyle: MessagePreviewStyle
    
    public var reactionsStyle: ReactionsStyle
    
    public init() {
        // Initialize avatar style
        var avatarStyleInit = CometChatAvatar.style
        avatarStyleInit.textFont = CometChatTypography.Heading4.bold
        avatarStyle = avatarStyleInit
        
        // Initialize other styles
        dateStyle = CometChatDate.style
        receiptStyle = CometChatReceipt.style
        reactionsStyle = CometChatReactions.style
        
        callBubbleStyle = CallBubbleStyle()
        linkPreviewBubbleStyle = LinkPreviewBubbleStyle()
        textBubbleStyle = TextBubbleStyle()
        aiAssistantBubbleStyle = AIAssistantBubbleStyle()
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
        moderationStyle = ModerationStyle()
        messagePreviewStyle = MessagePreviewStyle()
    }
    
    //for default values according to the bubble type
    public init(styleType: BubbleStyleType) {
        // Initialize avatar style
        var avatarStyleInit = CometChatAvatar.style
        avatarStyleInit.textFont = CometChatTypography.Heading4.bold
        avatarStyle = avatarStyleInit
        
        // Initialize other styles
        dateStyle = CometChatDate.style
        receiptStyle = CometChatReceipt.style
        reactionsStyle = CometChatReactions.style
        
        textBubbleStyle = TextBubbleStyle(styleType: styleType)
        aiAssistantBubbleStyle = AIAssistantBubbleStyle()
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
        moderationStyle = ModerationStyle()
        messagePreviewStyle = MessagePreviewStyle()

        switch styleType {
        case .incoming:
            dateStyle.textColor = CometChatTheme.neutralColor600
            dateStyle.textFont = CometChatTypography.Caption2.regular
            _backgroundColor = CometChatTheme.neutralColor300
            
            messagePreviewStyle.backgroundColor = CometChatTheme.neutralColor400
            // Don't set backing variables for incoming - let them use computed properties dynamically
            messagePreviewStyle._indicatorViewBackgroundColor = nil
            messagePreviewStyle._titleTextColor = nil
            messagePreviewStyle.subtitleTextColor = CometChatTheme.textColorSecondary
            messagePreviewStyle.subtitleImageTintColor = CometChatTheme.iconColorSecondary
        case .outgoing:
            // Don't set _backgroundColor for outgoing - let it use the computed property
            // which will fetch CometChatTheme.primaryColor dynamically
            dateStyle.textColor = CometChatTheme.white
            dateStyle.textFont = CometChatTypography.Caption2.regular
            
            messagePreviewStyle.backgroundColor = CometChatTheme.white.withAlphaComponent(0.2)
            messagePreviewStyle.indicatorViewBackgroundColor = CometChatTheme.white
            messagePreviewStyle.titleTextColor = CometChatTheme.white
            messagePreviewStyle.subtitleTextColor = CometChatTheme.white
            messagePreviewStyle.subtitleImageTintColor = CometChatTheme.white
        }
        messagePreviewStyle.cornerRadius = CometChatCornerStyle(cornerRadius: CometChatSpacing.Radius.r3)
        dateStyle.borderWidth = 0
        dateStyle.backgroundColor = .clear
        
        // Apply messagePreviewStyle to all child bubble styles
        stickersBubbleStyle.messagePreviewStyle = messagePreviewStyle
        textBubbleStyle.messagePreviewStyle = messagePreviewStyle
        imageBubbleStyle.messagePreviewStyle = messagePreviewStyle
        videoBubbleStyle.messagePreviewStyle = messagePreviewStyle
        fileBubbleStyle.messagePreviewStyle = messagePreviewStyle
        audioBubbleStyle.messagePreviewStyle = messagePreviewStyle
        pollBubbleStyle.messagePreviewStyle = messagePreviewStyle
        callBubbleStyle.messagePreviewStyle = messagePreviewStyle
        collaborativeWhiteboardBubbleStyle.messagePreviewStyle = messagePreviewStyle
        collaborativeDocumentBubbleStyle.messagePreviewStyle = messagePreviewStyle
        linkPreviewBubbleStyle.messagePreviewStyle = messagePreviewStyle
        messageTranslationBubbleStyle.messagePreviewStyle = messagePreviewStyle
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
    var messagePreviewStyle: MessagePreviewStyle? { get set }
}

public enum BubbleStyleType {
    case incoming
    case outgoing
}
