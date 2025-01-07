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
        if message.deletedAt > 0.0{
            return getMessageBubbleStyle(from: message).deleteBubbleStyle
        }
        switch message.messageCategory {
        case .message:
            switch message.messageType {
            case .text:
                if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty,
                   let linkPreview = map[ExtensionConstants.linkPreview], let links = linkPreview["links"] as? [Any], !links.isEmpty {
                    return getMessageBubbleStyle(from: message).linkPreviewBubbleStyle
                } else {
                    return getMessageBubbleStyle(from: message).textBubbleStyle
                }
            case .image:
                return getMessageBubbleStyle(from: message).imageBubbleStyle
            case .video:
                return getMessageBubbleStyle(from: message).videoBubbleStyle
            case .audio:
                return getMessageBubbleStyle(from: message).audioBubbleStyle
            case .file:
                return getMessageBubbleStyle(from: message).fileBubbleStyle
            case .custom:
                break
            case .groupMember:
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
                    return getMessageBubbleStyle(from: message).stickersBubbleStyle
                case "extension_poll":
                    return getMessageBubbleStyle(from: message).pollBubbleStyle
                case "extension_whiteboard":
                    return getMessageBubbleStyle(from: message).collaborativeWhiteboardBubbleStyle
                case "extension_document":
                    return getMessageBubbleStyle(from: message).collaborativeDocumentBubbleStyle
                case "meeting":
                    return getMessageBubbleStyle(from: message).callBubbleStyle
                case .none:
                    break
                case .some(_):
                    break
                }
            }
        case .interactive:
            break
        @unknown default:
            break
        }
        
        func getMessageBubbleStyle(from message: BaseMessage) -> MessageBubbleStyle {
            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
            return isLoggedInUser ? messageStyle.outgoing : messageStyle.incoming
        }
        
        return nil
    }
    
    static func buildStatusInfo(
        from bubble: CometChatMessageBubble,
        messageTypeStyle: BaseMessageBubbleStyle?,
        bubbleStyle: MessageBubbleStyle,
        message: BaseMessage,
        hideReceipt: Bool = false,
        messageAlignment: MessageListAlignment = .standard
    ) {
        
        if let message = message as? CustomMessage, message.type == "meeting"{
            return
        }
        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        
        var messageTypeStyle: BaseMessageBubbleStyle? = messageTypeStyle
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
        let receipt = CometChatReceipt().withoutAutoresizingMaskConstraints()
        
        
        if isDateVisible {
            
            var dateStyle = messageTypeStyle?.dateStyle ?? bubbleStyle.dateStyle
            dateStyle.backgroundColor = .clear
            dateStyle.borderWidth = 0
            dateStyle.cornerRadius = nil
            
            date.set(pattern: .time)
            date.set(timestamp: message.sentAt)
            date.style = dateStyle
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
            receipt.set(receipt: MessageReceiptUtils.get(receiptStatus: message))
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
        default: return (message as? CustomMessage)?.type ?? ""
        }
    }
    
    public static func getDefaultMessageCategories(message: BaseMessage) -> String {
        switch message.messageCategory {
        case .message: return "message"
        case .custom:  return "custom"
        case .call: return "call"
        case .action: return "action"
        case .interactive: return "interactive"
        default: return "message"
        }
    }
    
    public static func getDefaultAttachmentOptions() -> [CometChatMessageComposerAction] {
        let composerActions = [
            CometChatMessageComposerAction(id: MessageTypeConstants.image, text: "TAKE_A_PHOTO".localize(), startIcon: UIImage(systemName: "camera.fill") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil),
            
            CometChatMessageComposerAction(id: MessageTypeConstants.image, text: "PHOTO_VIDEO_LIBRARY".localize(), startIcon:  UIImage(systemName: "photo") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil),
            
            CometChatMessageComposerAction(id: MessageTypeConstants.file, text: "DOCUMENT".localize(), startIcon: UIImage(named: "document.on.document", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
        ]
        return composerActions
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
    
}
