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
                date.text = "MESSAGE_EDITED".localize() + "  " + (date.text ?? "")
            }
            
            statusInfoView.addSubview(date)
            constraintToActive += [
                date.topAnchor.pin(equalTo: statusInfoView.topAnchor),
                date.bottomAnchor.pin(equalTo: statusInfoView.bottomAnchor),
            ]

            // Pinned/saved indicators take the slot before the timestamp, so a message
            // with neither lays out exactly as before. Both use a 0 sentinel, so
            // presence is the test — never a `> 0` comparison.
            let indicators = pinSaveIndicators(for: message, dateStyle: dateStyle)
            var leadingAnchorForNext = statusInfoView.leadingAnchor
            for indicator in indicators {
                statusInfoView.addSubview(indicator)
                let glyphSize = max(12, dateStyle.textFont.pointSize * 0.9)
                constraintToActive += [
                    indicator.widthAnchor.pin(equalToConstant: glyphSize),
                    indicator.heightAnchor.pin(equalToConstant: glyphSize),
                    indicator.centerYAnchor.pin(equalTo: date.centerYAnchor),
                    indicator.leadingAnchor.pin(equalTo: leadingAnchorForNext,
                                                constant: CometChatSpacing.Padding.p1),
                ]
                leadingAnchorForNext = indicator.trailingAnchor
            }
            constraintToActive += [
                date.leadingAnchor.pin(equalTo: leadingAnchorForNext, constant: CometChatSpacing.Padding.p1),
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
    
    /// The SDK collapses "never pinned" and an explicit `pinnedAt: 0` onto the same
    /// sentinel, so a non-zero timestamp is the only safe read. Every call site goes
    /// through here rather than comparing the field itself.
    public static func isPinned(message: BaseMessage) -> Bool {
        return message.pinnedAt != 0
    }

    public static func isSaved(message: BaseMessage) -> Bool {
        return message.savedAt != 0
    }

    /// Meta-row glyphs for a pinned and/or saved message, in that order.
    ///
    /// Deleted messages are skipped: the actions are unreachable on them, and a
    /// stale indicator on a "message deleted" placeholder reads as a live pin.
    /// Filled variants are used rather than the option-menu outlines — an
    /// indicator states a fact, where the menu icon offers an action.
    static func pinSaveIndicators(for message: BaseMessage, dateStyle: DateStyle) -> [UIImageView] {
        guard message.deletedAt == 0 else { return [] }

        var glyphs = [(name: String, label: String)]()
        if isPinned(message: message) {
            glyphs.append((name: "pin.fill", label: "PINNED_INDICATOR".localize()))
        }
        if isSaved(message: message) {
            glyphs.append((name: "bookmark.fill", label: "SAVED_INDICATOR".localize()))
        }

        return glyphs.map { glyph in
            let icon = UIImageView().withoutAutoresizingMaskConstraints()
            icon.image = UIImage(systemName: glyph.name)?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = dateStyle.textColor
            icon.contentMode = .scaleAspectFit
            icon.isAccessibilityElement = true
            icon.accessibilityLabel = glyph.label
            return icon
        }
    }

    /// Reconstructs a quoted `BaseMessage` from a raw `quotedMessage` payload for cases where
    /// the SDK doesn't populate `message.quotedMessage` (e.g. agentic AI replies, developer
    /// cards). Dispatches to the appropriate public `fromJSON` parser by category/type, falling
    /// back to a text parse so a preview still renders. Returns nil if it can't be parsed.
    static func resolveQuotedMessage(from raw: [String: Any]) -> BaseMessage? {
        let category = raw["category"] as? String
        let type = raw["type"] as? String

        switch category {
        case MessageCategoryConstants.message:
            switch type {
            case MessageTypeConstants.image, MessageTypeConstants.video,
                 MessageTypeConstants.audio, MessageTypeConstants.file:
                return MediaMessage.mediaMessage(fromJSON: raw).0
            default:
                return TextMessage.textMessage(fromJSON: raw).0
            }
        case MessageCategoryConstants.custom:
            return CustomMessage.customMessage(fromJSON: raw).0
        case MessageCategoryConstants.action:
            return ActionMessage.actionMessage(fromJSON: raw).0
        default:
            // interactive / agentic / card / unknown → best-effort text preview
            return TextMessage.textMessage(fromJSON: raw).0
        }
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
    
    /// Runs the formatters for a reply or edit preview panel.
    ///
    /// Identical to `processTextFormatter` with `.COMPOSER`, except each match is
    /// rendered through `preparePreviewString(baseMessage:regexString:)`. A
    /// formatter that keeps a raw token in the live input can strip it there, so
    /// the panel shows styled text instead of marker characters. A formatter that
    /// does not override sees no difference — the default forwards to
    /// `prepareMessageString` with `.COMPOSER`.
    static func processPreviewFormatter(message: TextMessage, textFormatter: [CometChatTextFormatter]) -> NSAttributedString {
        var mutableString = NSMutableAttributedString(string: message.text)
        textFormatter.forEach { formatter in
            let processedData = MessageUtils.processString(mutableString, regex: formatter.getRegex()) { string in
                formatter.preparePreviewString(baseMessage: message, regexString: string)
            }
            mutableString = NSMutableAttributedString(attributedString: processedData.string)
        }
        return mutableString
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

    /// Carries the styling a text formatter produced onto text that has since
    /// been re-rendered, so a formatter's styling reaches every surface rather
    /// than only the message bubble.
    ///
    /// Surfaces that show markdown run the formatters and the markdown parser
    /// over the same text. The parser takes a `String`, so the formatter's
    /// attributes are dropped the moment its output is handed over. This copies
    /// them back afterwards.
    ///
    /// The two strings are not the same length: rendering strips markdown
    /// markers, so every offset after the first `**` has shifted. Ranges are
    /// therefore re-found by their text rather than trusted, and a run whose text
    /// is absent from `rendered` — the marker characters themselves — is dropped.
    ///
    /// - Parameters:
    ///   - formatted: the formatter output, carrying the attributes to preserve.
    ///   - rendered: the re-rendered text to carry them onto.
    ///   - skipping: attribute keys the re-render owns and must keep — the
    ///     baseline font and colour it applied.
    ///   - carryingEverythingFor: runs this returns true for ignore `skipping`
    ///     and carry every attribute. Mentions use it: the shipped subtitle
    ///     copies a mention run wholesale, font included, and that must not
    ///     change. Defaults to carrying nothing extra.
    static func mergeFormatterAttributes(
        from formatted: NSAttributedString,
        onto rendered: NSMutableAttributedString,
        skipping: Set<NSAttributedString.Key> = [],
        carryingEverythingFor isExempt: (([NSAttributedString.Key: Any]) -> Bool)? = nil
    ) {
        guard formatted.length > 0, rendered.length > 0 else { return }

        let renderedText = rendered.string as NSString
        let formattedText = formatted.string as NSString
        // Runs are walked in order and each search starts after the previous
        // match, so a word that repeats styles its own occurrence rather than
        // the first one every time.
        var searchStart = 0

        formatted.enumerateAttributes(in: NSRange(location: 0, length: formatted.length)) { attributes, range, _ in
            let runText = formattedText.substring(with: range)
            guard !runText.isEmpty, searchStart <= renderedText.length else { return }

            let searchRange = NSRange(location: searchStart, length: renderedText.length - searchStart)
            let found = renderedText.range(of: runText, options: [], range: searchRange)
            guard found.location != NSNotFound else { return }

            // The cursor advances over every run that survives into the render,
            // carried or not. Advancing only on carried runs would leave the
            // search at 0 through any unstyled prefix, so the next styled run
            // would match that word's FIRST occurrence instead of its own.
            searchStart = found.location + found.length

            let exempt = isExempt?(attributes) ?? false
            let carried = exempt ? attributes : attributes.filter { !skipping.contains($0.key) }
            guard !carried.isEmpty else { return }

            for (key, value) in carried {
                rendered.addAttribute(key, value: value, range: found)
            }
        }
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
                // Formatter regexes normally capture the tag body in group 1; one
                // without a capture group falls back to the whole match. An optional
                // group that didn't take part in the match (NSNotFound) is skipped.
                let captureRange = match.numberOfRanges > 1 ? match.range(at: 1) : match.range
                guard captureRange.location != NSNotFound, let range = Range(captureRange, in: input) else { continue }
                let uidReplacement = String(input[range])
                
                let modifiedReplacement = replaceRegex(uidReplacement)
                // `attributes(at: 0)` raises on an empty string.
                let attributes = modifiedReplacement.length > 0
                    ? modifiedReplacement.attributes(at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: modifiedReplacement.length))
                    : [:]
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
            CometChatLogger.error("Error creating regular expression: \(error.localizedDescription)")
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
                // Same capture-group fallback as processString: never force-unwrap group 1.
                let captureRange = match.numberOfRanges > 1 ? match.range(at: 1) : match.range
                guard captureRange.location != NSNotFound, let range = Range(captureRange, in: input) else { continue }
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
            CometChatLogger.error("Error creating regular expression: \(error.localizedDescription)")
        }
        
        return (attributedString, itemData)

        
    }
    
    public static func quotedMessageText(for message: BaseMessage) -> String {
        // A deleted message keeps its original payload; quote it as deleted instead.
        if message.deletedAt > 0 {
            return "MESSAGE_WAS_DELETED".localize()
        }

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
            case .image: return "MESSAGE_IMAGE".localize()
            case .video: return "MESSAGE_VIDEO".localize()
            case .audio: return "MESSAGE_AUDIO".localize()
            case .file:  return "MESSAGE_FILE".localize()
            default:     return "MESSAGE_MEDIA".localize()
            }
        }
        
        if let customMessage = message as? CustomMessage {
            switch customMessage.type {
            case "extension_sticker":
                return "CUSTOM_MESSAGE_STICKER".localize()
            case "extension_poll":
                return "CUSTOM_MESSAGE_POLL".localize()
            case "extension_whiteboard":
                return "COLLABORATIVE_WHITEBOARD".localize()
            case "extension_document":
                return "COLLABORATIVE_DOCUMENT".localize()
            case "meeting":
                return "MESSAGE_MEETING".localize()
            case .none:
                break
            case .some(_):
                break
            }
        }
        
        // Developer card messages (category "card")
        if let cardMessage = message as? CometChatSDK.CardMessage {
            return cardMessage.getText() ?? "card_message_fallback".localize()
        }
        
        return "MESSAGE_GENERIC".localize()
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
