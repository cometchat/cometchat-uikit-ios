//
//  StreamMessage.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 19/09/25.
//

import Foundation
import CometChatSDK

@objcMembers
public class StreamMessage: AIAssistantMessage {

    /// Indicates if the stream message delivery failed (default: false)
    public var deliveryFailed: Bool = false

    /// Designated initializer
    public init(receiverUid: String, receiverType: CometChat.ReceiverType, text: String, runId: Int, threadId: String) {
        super.init(receiverUid: receiverUid, text: text, runId: runId, threadId: threadId, receiverType: receiverType)
        self.receiverUid = receiverUid
        self.receiverType = receiverType
        self.text = text
        self.messageType = .assistant // Equivalent to UIKitConstants.MessageType.STREAM
        self.messageCategory = .agentic // Equivalent to UIKitConstants.MessageCategory.STREAM
        self.runId = runId
        self.threadId = threadId
    }

    /// Returns true if the stream message delivery failed
    public func isDeliveryFailed() -> Bool {
        return deliveryFailed
    }

    /// Marks this stream message as failed/succeeded
    @nonobjc
    public func setDeliveryFailed(_ deliveryFailed: Bool) {
        self.deliveryFailed = deliveryFailed
    }
}
