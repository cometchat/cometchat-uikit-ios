//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 26/12/22.
//

import Foundation
import CometChatSDK
import UIKit

open class MessageUtils {
    
    static public func getSpecificMessageTypeStyle(
        message: BaseMessage,
        from messageStyle: (incoming: MessageBubbleStyle, outgoing: MessageBubbleStyle)
    ) -> BaseMessageBubbleStyle? {
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        let style = isLoggedInUser ? messageStyle.outgoing : messageStyle.incoming

        if message.deletedAt > 0.0{
            return style.deleteBubbleStyle
        }
        switch message.messageCategory {
        case .message:
            switch message.messageType {
            case .text:
                guard let map = ExtensionModerator.extensionCheck(baseMessage: message),
                      let rawPreview = map[ExtensionConstants.linkPreview] else {
                    return style.textBubbleStyle
                }

                guard let links = rawPreview["links"] as? [Any], !links.isEmpty else {
                    return style.textBubbleStyle
                }

                return style.linkPreviewBubbleStyle

            case .image:
                return style.imageBubbleStyle
            case .video:
                return style.videoBubbleStyle
            case .audio:
                return style.audioBubbleStyle
            case .file:
                return style.fileBubbleStyle
            case .custom:
                break
            case .groupMember:
                break
            case .assistant:
                break
            case .toolResult:
                break
            case .toolArguments:
                break
            @unknown default:
                break
            }
        case .action:
            break
        case .call:
            break
        case .custom:
            if let customMessage = message as? CustomMessage {
                switch customMessage.type {
                case "extension_sticker":
                    let baseStyle = style.stickersBubbleStyle
                    var modifiedStyle = baseStyle
                    if let _ = message.quotedMessage {
                        modifiedStyle.backgroundColor = isLoggedInUser ? CometChatTheme.primaryColor : CometChatTheme.neutralColor600
                        var dateStyle = DateStyle()
                        dateStyle.textColor = isLoggedInUser ? CometChatTheme.white : CometChatTheme.neutralColor600
                        dateStyle.textFont = CometChatTypography.Caption2.regular
                        dateStyle.backgroundColor = .clear
                        dateStyle.borderWidth = 0
                        modifiedStyle.dateStyle = dateStyle
                        return modifiedStyle
                    } else {
                        var dateStyle = DateStyle()
                        dateStyle.textColor = CometChatTheme.white
                        dateStyle.textFont = CometChatTypography.Caption2.regular
                        dateStyle.borderWidth = 0
                        dateStyle.backgroundColor = CometChatTheme.black.withAlphaComponent(0.6)
                        dateStyle.cornerRadius = .init(cornerRadius: CometChatSpacing.Radius.r2)
                        dateStyle.textColor = CometChatTheme.white
                        modifiedStyle.dateStyle = dateStyle
                        modifiedStyle.backgroundColor = .clear
                        return modifiedStyle
                    }
                case "extension_poll":
                    return style.pollBubbleStyle
                case "extension_whiteboard":
                    return style.collaborativeWhiteboardBubbleStyle
                case "extension_document":
                    return style.collaborativeDocumentBubbleStyle
                case "meeting":
                    return style.callBubbleStyle
                case .none:
                    break
                case .some(_):
                    break
                }
            }
        case .interactive:
            break
        case .agentic:
            break
        case .card:
            break
        @unknown default:
            break
        }
        
        return nil
    }
    
    static func buildStatusInfo(
        from bubble: CometChatMessageBubble,
        messageTypeStyle: BaseMessageBubbleStyle?,
        bubbleStyle: MessageBubbleStyle,
        message: BaseMessage,
        hideReceipt: Bool = false,
        messageAlignment: MessageListAlignment = .standard,
        timePattern: ((_ timestamp: Int?) -> String)? = nil,
        dateTimeFormatter: CometChatDateTimeFormatter?,
        isModerated: Bool = false
    ) {
        
        if let message = message as? CustomMessage, message.type == "meeting", message.deletedAt == 0{
            return
        }
        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        
        let messageTypeStyle: BaseMessageBubbleStyle? = messageTypeStyle
        var bubbleStyle: MessageBubbleStyle = bubbleStyle
        
        let statusInfoContainerView = UIStackView(frame: .zero).withoutAutoresizingMaskConstraints()
        statusInfoContainerView.alignment = .center
        statusInfoContainerView.addArrangedSubview(UIView())
        statusInfoContainerView.backgroundColor = .clear
        statusInfoContainerView.spacing = CometChatSpacing.Padding.p1
        statusInfoContainerView.isLayoutMarginsRelativeArrangement = true
        statusInfoContainerView.layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Padding.p1,
            left: 20,
            bottom: CometChatSpacing.Padding.p1,
            right: CometChatSpacing.Padding.p2
        )
        
        let statusInfoView = UIView().withoutAutoresizingMaskConstraints()
        statusInfoView.backgroundColor = messageTypeStyle?.dateStyle?.backgroundColor ?? bubbleStyle.dateStyle.backgroundColor
        statusInfoView.roundViewCorners(corner: messageTypeStyle?.dateStyle?.cornerRadius ?? bubbleStyle.dateStyle.cornerRadius ?? .init(cornerRadius: 0))
        statusInfoView.borderWith(width: messageTypeStyle?.dateStyle?.borderWidth ?? bubbleStyle.dateStyle.borderWidth)
        statusInfoView.borderColor(color: messageTypeStyle?.dateStyle?.borderColor ?? bubbleStyle.dateStyle.borderColor)
        statusInfoView.heightAnchor.pin(greaterThanOrEqualToConstant: 16).isActive = true
        
        let isReceiptVisible = ((messageAlignment == .standard && isLoggedInUser) && !hideReceipt && (message.deletedAt == 0))
        let isDateVisible = true //Will Use this when date alignment property get added
        var constraintToActive = [NSLayoutConstraint]()
        let date = CometChatDate().withoutAutoresizingMaskConstraints()
        date.dateTimeFormatter = dateTimeFormatter
        let receipt = CometChatReceipt().withoutAutoresizingMaskConstraints()
        
        
        if isDateVisible {
            
            var dateStyle = messageTypeStyle?.dateStyle ?? bubbleStyle.dateStyle
            dateStyle.backgroundColor = .clear
            dateStyle.borderWidth = 0
            dateStyle.cornerRadius = nil
            
            date.set(pattern: .time)
            if let timePattern = timePattern?(message.sentAt){
                date.text = timePattern
            }else{
                date.set(timestamp: message.sentAt)
            }
            date.style = dateStyle
            
            // adding edited tag for any edited message (text, media caption, etc.)
            if message.editedAt != 0 {
                date.text = "Edited  " + (date.text ?? "")
            }
            
            statusInfoView.addSubview(date)
            constraintToActive += [
                date.topAnchor.pin(equalTo: statusInfoView.topAnchor),
                date.bottomAnchor.pin(equalTo: statusInfoView.bottomAnchor),
                date.leadingAnchor.pin(equalTo: statusInfoView.leadingAnchor, constant: CometChatSpacing.Padding.p1),
            ]
            
            if isReceiptVisible {
                constraintToActive += [ date.trailingAnchor.pin(equalTo: receipt.leadingAnchor, constant: -CometChatSpacing.Padding.p1) ]
            } else {
                constraintToActive += [ date.trailingAnchor.pin(equalTo: statusInfoView.trailingAnchor, constant: -CometChatSpacing.Padding.p1) ]
            }
        }
        
        if isReceiptVisible  {
            receipt.style = messageTypeStyle?.receiptStyle ?? bubbleStyle.receiptStyle
            if isModerated{
                receipt.set(receipt: .failed)
            }else{
                receipt.set(receipt: MessageReceiptUtils.get(receiptStatus: message))
            }
            
            statusInfoView.addSubview(receipt)
            NSLayoutConstraint.activate([
                receipt.topAnchor.pin(equalTo: statusInfoView.topAnchor),
                receipt.bottomAnchor.pin(equalTo: statusInfoView.bottomAnchor),
                receipt.trailingAnchor.pin(equalTo: statusInfoView.trailingAnchor, constant: -CometChatSpacing.Padding.p1)
            ])
            if !isDateVisible {
                constraintToActive += [ receipt.leadingAnchor.pin(equalTo: statusInfoView.leadingAnchor, constant: CometChatSpacing.Padding.p1) ]
            }
        }
        
        
        NSLayoutConstraint.activate(constraintToActive)
        statusInfoContainerView.addArrangedSubview(statusInfoView)
        
        bubble.set(statusInfoView: statusInfoContainerView)
        
    }
    
    public static func getDefaultMessageTypes(message: BaseMessage) -> String {
        switch message.messageCategory {
        case .message:
            switch message.messageType {
            case .text: return "text"
            case .image: return "image"
            case .audio: return "audio"
            case .groupMember: return "groupMember"
            case .file: return "file"
            case .video: return "video"
            case .assistant: return "assistant"
            case .custom: return (message as? CustomMessage)?.type ?? ""
            default: return (message as? CustomMessage)?.type ?? ""
            }
        case .custom: return (message as? CustomMessage)?.type ?? ""
        case .interactive: return (message as? InteractiveMessage)?.type ?? ""
        case .call:
            if let call = message as? Call {
                switch call.callType {
                case .audio: return "audio"
                case .video: return "video"
                @unknown default: return "call"
                }
            }
            return "call"
        case .action: 
            return "groupMember"
        case .agentic: return "assistant"
        case .card: return "developer_card"
        default: return (message as? CustomMessage)?.type ?? ""
        }
    }
    
    public static func getModerationView(from bubble: CometChatMessageBubble, message: BaseMessage, bubbleStyle: MessageBubbleStyle){
        
        let view = ModerationDisapprovedView().withoutAutoresizingMaskConstraints()
        view.backgroundContainerColor = bubbleStyle.moderationStyle.moderationBackgroundColor
        view.messageTextColor = bubbleStyle.moderationStyle.moderationTextColor
        view.messageFont = bubbleStyle.moderationStyle.moderationTextFont
        view.iconViewTintColor = bubbleStyle.moderationStyle.moderationImageTint
        
        // Check if this is an RBAC permission denied error and set appropriate message
        if let metaData = message.metaData, metaData["rbac_permission_denied"] as? Bool == true, message.messageCategory == .message {
            view.messageLabel.text = "FILE_TYPE_NOT_ALLOWED".localize()
            view.messageLabel.numberOfLines = 1
            view.messageLabel.adjustsFontSizeToFitWidth = true
            view.messageLabel.minimumScaleFactor = 0.7
        }
        
        bubble.set(bottomView: view)
    }
    
    public static func getAIActionView(message: BaseMessage,from bubble: CometChatMessageBubble, onCopyTapped: @escaping(BaseMessage) -> ()){
        let view = AIActionBarView().withoutAutoresizingMaskConstraints()
        view.message = message
        view.onCopyTapped = { message in
            onCopyTapped(message)
        }
        bubble.set(bottomView: view)
    }
    
    public static func isMessageModerationDisapproved(message: BaseMessage) -> Bool {
        // Check for traditional moderation disapproval
        if (message as? TextMessage)?.getModerationStatus() == "disapproved" || (message as? MediaMessage)?.getModerationStatus() == "disapproved" {
            return true
        }
        // Check for RBAC permission denied (e.g., MIME type not allowed)
        // Only apply to actual messages, not action messages (like "user added to group")
        if let metaData = message.metaData, metaData["rbac_permission_denied"] as? Bool == true, message.messageCategory == .message {
            return true
        }
        return false
    }
    
    public static func isMessageModerationPending(message: BaseMessage) -> Bool {
        if (message as? TextMessage)?.getModerationStatus() == "pending" || (message as? MediaMessage)?.getModerationStatus() == "pending" {
             return true
         }
         return false
     }
    
//    public static func isUserAgentic(user: User?) -> Bool {
//        guard let user = user else { return false }
//        return user.role == "@agentic"
//    }
    
    public static func getDefaultMessageCategories(message: BaseMessage) -> String {
        switch message.messageCategory {
        case .message: return "message"
        case .custom:  return "custom"
        case .call: return "call"
        case .action: return "action"
        case .interactive: return "interactive"
        case .agentic: return "agentic"
        case .card: return "card"
        default: return "message"
        }
    }
    
    public static func getDefaultAttachmentOptions(addtionalConfiguration: AdditionalConfiguration) -> [CometChatMessageComposerAction] {
        
        var composerAction: [CometChatMessageComposerAction] = []
        
        if !addtionalConfiguration.hideImageAttachmentOption{
            composerAction.append(CometChatMessageComposerAction(id: MessageTypeConstants.image, text: "TAKE_A_PHOTO".localize(), startIcon: UIImage(systemName: "camera.fill") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil))
            composerAction.append(CometChatMessageComposerAction(id: MessageTypeConstants.image, text: "PHOTO_LIBRARY".localize(), startIcon:  UIImage(systemName: "photo.fill") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil))
        }
        
        if !addtionalConfiguration.hideVideoAttachmentOption{
            composerAction.append(CometChatMessageComposerAction(id: MessageTypeConstants.video, text: "VIDEO_LIBRARY".localize(), startIcon:  UIImage(systemName: "video.fill") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil))
        }
        
        if !addtionalConfiguration.hideAudioAttachmentOption{
            composerAction.append(CometChatMessageComposerAction(id: MessageTypeConstants.audio, text: "AUDIO_LIBRARY".localize(), startIcon:  UIImage(systemName: "music.note") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil))
        }
        
        if !addtionalConfiguration.hideFileAttachmentOption{
            composerAction.append(CometChatMessageComposerAction(id: MessageTypeConstants.file, text: "CUSTOM_MESSAGE_DOCUMENT".localize(), startIcon: UIImage(named: "document.on.document", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil))
        }
        
        return composerAction
    }
    
    public static func bubbleBackgroundAppearance(bubbleView: UIView, senderUid: String, message: BaseMessage, controller: UIViewController ) {
        if (senderUid == CometChat.getLoggedInUser()?.uid)  && (message.messageType == .text) {
            bubbleView.backgroundColor =  CometChatTheme_v4.palatte.primary
        } else {
            bubbleView.backgroundColor = (controller.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme_v4.palatte.accent100 :  CometChatTheme_v4.palatte.secondary
        }
        
    }
    
    static func processTextFormatter(for textMessage: TextMessage?, customText: String? = nil, in hyperlinkLabel: HyperlinkLabel, textFormatter: [CometChatTextFormatter], controller: UIViewController?, alignment: MessageBubbleAlignment) -> NSAttributedString? {
        
        var mutableMessageText = NSMutableAttributedString(string: customText ?? textMessage?.text ?? "")
        if let message = textMessage {
            for textFormatter in textFormatter {
                if textFormatter.getRegex() == "" { return nil }
                let processedData = MessageUtils.processString(mutableMessageText, regex: textFormatter.getRegex(), hyperlinkType: .custom(pattern: "\(textFormatter.getTrackingCharacter())")) { stringWithRegex in
                    return textFormatter.prepareMessageString(baseMessage: message, regexString: (stringWithRegex as String), alignment: alignment, formattingType: .MESSAGE_BUBBLE)
                }
                mutableMessageText = NSMutableAttributedString(attributedString: processedData.string)
                if !processedData.tappableTuple.isEmpty {
                    let customType = HyperlinkType.custom(pattern: "\(textFormatter.getTrackingCharacter())")
                    hyperlinkLabel.enabledTypes.append(customType)
                    hyperlinkLabel.defaultHyperLinkElements.append(with: [customType : processedData.tappableTuple])
                    hyperlinkLabel.handleCustomTap(for: customType) { [weak controller] tappedString in
                        textFormatter.onTextTapped(baseMessage: message, tappedText: tappedString, controller: controller)
                    }
                    hyperlinkLabel.customAttributes.append(with: processedData.attributes)
                }
            }
        }
        
        return mutableMessageText
        
    }
    
    static public func processTextFormatter(message: TextMessage, textFormatter: [CometChatTextFormatter], formattingType: FormattingType, alignment: MessageBubbleAlignment = .left) -> NSAttributedString {
        var mutableString = NSMutableAttributedString(string: message.text)
        textFormatter.forEach { formatter in
            let processedData = MessageUtils.processString(mutableString, regex: formatter.getRegex()) { string in
                formatter.prepareMessageString(baseMessage: message, regexString: string, formattingType: formattingType)
            }
            mutableString = NSMutableAttributedString(attributedString: processedData.string) 
        }
        return mutableString
    }
    
    static func wrapRegexMatches(in text: String, regexPattern: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else { return text }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        let modifiedString = NSMutableString(string: text)
        var offset = 0
        
        regex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            guard let matchRange = match?.range else { return }
            
            let adjustedRange = NSRange(location: matchRange.location + offset, length: matchRange.length)
            let wrappedMatch = "<span translate='no'>\(modifiedString.substring(with: adjustedRange))</span>"
            
            modifiedString.replaceCharacters(in: adjustedRange, with: wrappedMatch)
            offset += wrappedMatch.count - matchRange.length
        }
        
        return modifiedString as String
    }
    
    static func removeSpanWrapping(in text: String) -> String {
        let regexPattern = "<span translate='no'>(.*?)</span>"
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else { return text }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        let modifiedString = regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "$1")
        return modifiedString
    }
    
    static func processString(_ input: NSMutableAttributedString, regex: String, hyperlinkType: HyperlinkType? = nil, replaceRegex: ((String) -> NSAttributedString)) -> (string: NSAttributedString, attributes:  [NSRange: [NSAttributedString.Key: Any]], tappableTuple: [ElementTuple]) {
        
        let attributedString = input
        let input = attributedString.string
        var tappableTuple = [ElementTuple]()
        var attributesWithRange = [NSRange: [NSAttributedString.Key: Any]]()
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            
            var offset = 0
            for match in matches {
                let range = Range(match.range(at: 1), in: input)!
                let uidReplacement = String(input[range])
                
                let modifiedReplacement = replaceRegex(uidReplacement)
                let attributes = modifiedReplacement.attributes(at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: modifiedReplacement.length))
                let adjustedRange = NSRange(location: match.range.location - offset, length: match.range.length)
                attributedString.replaceCharacters(in: adjustedRange, with: modifiedReplacement)
                
                if let hyperlinkType = hyperlinkType {
                    let modifiedRange = NSRange(location: match.range.location - offset, length: modifiedReplacement.string.utf16.count)
                    attributesWithRange[modifiedRange] = attributes
                    let elementTuple = (range: modifiedRange, element: HyperlinkElement.create(with: hyperlinkType, text: uidReplacement), type: hyperlinkType)
                    tappableTuple.append(elementTuple)
                }
                
                offset += match.range.length - modifiedReplacement.string.utf16.count
            }
        } catch {
            print("Error creating regular expression: \(error.localizedDescription)")
        }
        
        return (attributedString, attributesWithRange, tappableTuple)
    }
    
    static public func processMessageForTextFormatter(_ input: NSMutableAttributedString, regex: String, replaceRegex: ((String) -> NSAttributedString)) -> (NSAttributedString, [(item: SuggestionItem, range: NSRange)]) {
        
        let attributedString = input
        let input = attributedString.string
        var itemData = [(item: SuggestionItem, range: NSRange)]()
        
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            
            var underlyingText = [NSRange: String]()
            for match in matches {
                underlyingText[match.range] = (input as NSString).substring(with: match.range)
            }
            
            var offset = 0
            for match in matches {
                let range = Range(match.range(at: 1), in: input)!
                let uidReplacement = String(input[range])
                
                let modifiedReplacement = replaceRegex(uidReplacement)
                let adjustedRange = NSRange(location: match.range.location - offset, length: match.range.length)
                attributedString.replaceCharacters(in: adjustedRange, with: modifiedReplacement)
                
                let modifiedRange = NSRange(location: match.range.location - offset, length: modifiedReplacement.string.utf16.count)
                let suggestionItem = SuggestionItem(id: uidReplacement, name: String(modifiedReplacement.string.dropFirst()), visibleText: modifiedReplacement.string, underlyingText: underlyingText[match.range])
                itemData.append((item: suggestionItem, range: NSRange(location: adjustedRange.location, length: (modifiedReplacement.string as NSString).length)))
                
                offset += match.range.length - modifiedReplacement.string.utf16.count
            }
        } catch {
            print("Error creating regular expression: \(error.localizedDescription)")
        }
        
        return (attributedString, itemData)

        
    }
    
    public static func quotedMessageText(for message: BaseMessage) -> String {
        if let textMsg = message as? TextMessage {
            return textMsg.text
        }
        
        if let mediaMsg = message as? MediaMessage {
            // Multi-attachment: summarize ("N photos" / "N files" / "N attachments").
            if let attachments = mediaMsg.attachments, attachments.count > 1 {
                return MessagesDataSource.multiAttachmentPreviewText(for: attachments)
            }
            if let fileName = mediaMsg.attachment?.fileName, !fileName.isEmpty {
                return fileName
            }
            switch mediaMsg.messageType {
            case .image: return "Image"
            case .video: return "Video"
            case .audio: return "Audio"
            case .file:  return "File"
            default:     return "Media"
            }
        }
        
        if let customMessage = message as? CustomMessage {
            switch customMessage.type {
            case "extension_sticker":
                return "Sticker"
            case "extension_poll":
                return "Poll"
            case "extension_whiteboard":
                return "Collaborative Whiteboard"
            case "extension_document":
                return "Collaborative Document"
            case "meeting":
                return "Meeting"
            case .none:
                break
            case .some(_):
                break
            }
        }
        
        // Developer card messages (category "card")
        if let cardMessage = message as? CometChatSDK.CardMessage {
            return cardMessage.getText() ?? "Card Message"
        }
        
        return "Message"
    }
    
}

extension User {
    public var isAgentic: Bool {
        return role == "@agentic"
    }
    
    /// Returns true if this user is an AI agent in a group context.
    /// Uses the `ai-agent` role assigned by the backend for group AI agents.
    /// Returns false on nil/missing role — never throws.
    public var isAgent: Bool {
        return role == "ai-agent"
    }
    
    /// Returns true if this user is any type of AI agent (1:1 agentic OR group agent).
    public var isAnyAgent: Bool {
        return isAgentic || isAgent
    }
}
