//
//  CometChatThreadEventListener.swift
//  CometChatUIKitSwift
//
//  Copyright © 2026 CometChat. All rights reserved.
//

import Foundation
import CometChatSDK

@objc public protocol CometChatThreadEventListener {

    /// The logged-in user followed or unfollowed a thread from one of the kit's entry points.
    /// `parentMessageId` identifies the thread, not the message the tap came from.
    @objc optional func ccThreadSubscriptionChanged(parentMessageId: Int, isSubscribed: Bool)
}
