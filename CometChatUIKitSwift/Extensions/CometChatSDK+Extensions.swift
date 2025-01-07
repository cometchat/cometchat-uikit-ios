//
//  CometChatSDK+Extension.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 17/10/24.
//

import CometChatSDK

extension CometChat.MessageType {
    public func toString() -> String {
        switch self {
        case .text:
            return "text"
        case .image:
            return "image"
        case .video:
            return "video"
        case .audio:
            return "audio"
        case .file:
            return "file"
        case .custom:
            return "custom"
        case .groupMember:
            return "groupMember"
        @unknown default:
            return ""
        }
    }
}

extension CometChat.MessageCategory {
    public func toString() -> String {
        switch self {
        case .message:
            return "message"
        case .action:
            return "action"
        case .call:
            return "call"
        case .custom:
            return "custom"
        case .interactive:
            return "interactive"
        @unknown default:
            return ""
        }
    }
}
