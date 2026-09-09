//
//  CometChatPinnedMessages + Properties.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

extension CometChatPinnedMessages {

    @discardableResult
    /// The builder must keep `set(pinned: true)`; drop it and the panel lists every message.
    public func set(requestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        viewModel.setRequestBuilder(requestBuilder: requestBuilder)
        return self
    }

    /// Fills the bubble's content slot, replacing the rendered message body.
    @discardableResult
    public func set(subtitle: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }

    /// Replaces the whole bubble.
    @discardableResult
    public func set(listItemView: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }

    /// Fills the bubble's header slot, which carries the sender name by default.
    @discardableResult
    public func set(titleView: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }

    /// Fills the bubble's status-info slot, which carries the timestamp and receipt.
    @discardableResult
    public func set(trailingView: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.trailingView = trailingView
        return self
    }

    /// Replaces every default template. Use `add(template:)` to override a single type.
    @discardableResult
    public func set(templates: [CometChatMessageTemplate]) -> Self {
        self.customTemplates = templates
        viewModel.templates.removeAll()
        templates.forEach { viewModel.templates["\($0.category)_\($0.type)"] = $0 }
        return self
    }

    /// Overrides the template for one category/type, leaving the rest at their defaults.
    @discardableResult
    public func add(template: CometChatMessageTemplate) -> Self {
        customTemplates.removeAll { $0.category == template.category && $0.type == template.type }
        customTemplates.append(template)
        viewModel.templates["\(template.category)_\(template.type)"] = template
        return self
    }

    @discardableResult
    public func set(messageBubbleStyle: (incoming: MessageBubbleStyle, outgoing: MessageBubbleStyle)) -> Self {
        self.messageBubbleStyle = messageBubbleStyle
        return self
    }

    @discardableResult
    public func set(actionBubbleStyle: GroupActionBubbleStyle) -> Self {
        self.actionBubbleStyle = actionBubbleStyle
        return self
    }

    @discardableResult
    public func set(callActionBubbleStyle: CallActionBubbleStyle) -> Self {
        self.callActionBubbleStyle = callActionBubbleStyle
        return self
    }

    @discardableResult
    public func set(dateSeparatorStyle: DateStyle) -> Self {
        self.dateSeparatorStyle = dateSeparatorStyle
        return self
    }

    @discardableResult
    public func set(dateSeparatorPattern: @escaping ((_ timestamp: Int?) -> String)) -> Self {
        self.dateSeparatorPattern = dateSeparatorPattern
        return self
    }

    @discardableResult
    public func set(timePattern: @escaping ((_ timestamp: Int?) -> String)) -> Self {
        self.timePattern = timePattern
        return self
    }

    @discardableResult
    public func set(hideDateSeparator: Bool) -> Self {
        self.hideDateSeparator = hideDateSeparator
        return self
    }

    @discardableResult
    public func set(hideBubbleHeader: Bool) -> Self {
        self.hideBubbleHeader = hideBubbleHeader
        return self
    }

    @discardableResult
    public func set(hideReceipts: Bool) -> Self {
        self.hideReceipts = hideReceipts
        return self
    }

    @discardableResult
    public func set(hideAvatar: Bool) -> Self {
        self.hideAvatar = hideAvatar
        return self
    }

    @discardableResult
    public func set(messageAlignment: MessageListAlignment) -> Self {
        self.messageAlignment = messageAlignment
        return self
    }

    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }

    @discardableResult
    public func set(onMessageClicked: @escaping ((_ message: BaseMessage) -> Void)) -> Self {
        self.onMessageClicked = onMessageClicked
        return self
    }

    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }

    @discardableResult
    public func set(onLoad: @escaping (([BaseMessage]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }

    @discardableResult
    public func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }

    @discardableResult
    public func set(hideUnpinOption: Bool) -> Self {
        self.hideUnpinOption = hideUnpinOption
        return self
    }

    @discardableResult
    public func set(style: PinnedMessagesStyle) -> Self {
        self.style = style
        return self
    }

    @discardableResult
    public func set(textFormatters: [CometChatTextFormatter]) -> Self {
        self.textFormatters = textFormatters
        return self
    }
}
