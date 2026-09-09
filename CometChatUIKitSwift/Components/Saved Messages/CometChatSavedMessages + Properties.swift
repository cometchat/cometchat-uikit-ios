//
//  CometChatSavedMessages + Properties.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

extension CometChatSavedMessages {

    @discardableResult
    /// The builder must keep `set(saved: true)`; drop it and the screen lists every message.
    public func set(requestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        viewModel.setRequestBuilder(requestBuilder: requestBuilder)
        return self
    }

    @discardableResult
    public func set(subtitle: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }

    @discardableResult
    public func set(listItemView: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }

    @discardableResult
    public func set(titleView: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }

    @discardableResult
    public func set(leadingView: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.leadingView = leadingView
        return self
    }

    @discardableResult
    public func set(trailingView: ((_ message: BaseMessage?) -> UIView)?) -> Self {
        self.trailingView = trailingView
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
    public func set(hideUnsaveOption: Bool) -> Self {
        self.hideUnsaveOption = hideUnsaveOption
        return self
    }

    @discardableResult
    public func set(style: SavedMessagesStyle) -> Self {
        self.style = style
        return self
    }

    @discardableResult
    public func set(textFormatters: [CometChatTextFormatter]) -> Self {
        self.textFormatters = textFormatters
        return self
    }
}
