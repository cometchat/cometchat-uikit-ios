//
//  CometChatMessageSendState.swift
//  CometChatUIKitSwift
//
//  The send state reported by `ccMessageSendStateChanged` when offline messaging is enabled.
//

import Foundation

/// Where an own message stands in the send flow when offline messaging is enabled.
///
/// A message that is queued behind a missing network is `.sending`, not `.failed`. It becomes
/// `.failed` only when the Chat SDK gives up on it. `.discarded` means the message was removed
/// from the device queue and will never be sent.
public enum CometChatMessageSendState: Int {
    /// Accepted and queued or in flight. Shown with the clock.
    case sending
    /// The server acknowledged the message.
    case sent
    /// The message could not be sent. It can be retried.
    case failed
    /// The message was removed from the queue and will not be sent.
    case discarded
}
