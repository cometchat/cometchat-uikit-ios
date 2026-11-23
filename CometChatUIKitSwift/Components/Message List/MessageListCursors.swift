//
//  MessageListCursors.swift
//  CometChatUIKitSwift
//
//  Request cursors for the message list anchor on rows that have a server id. An own message that
//  has not been acked yet has `id == 0`; using it as a cursor makes the request start from the
//  beginning of the conversation instead of continuing from the newest or oldest sent message.
//

import Foundation
import CometChatSDK

enum MessageListCursors {

    /// Id of the newest row that has a server id, or `0` when the list has none.
    /// Sections are newest day first and rows are newest first inside a section.
    static func newestServerId(_ sections: [(date: Date, messages: [BaseMessage])]) -> Int {
        for section in sections {
            for row in section.messages where row.id > 0 { return row.id }
        }
        return 0
    }

    /// Id of the oldest row that has a server id, or `0` when the list has none.
    static func oldestServerId(_ sections: [(date: Date, messages: [BaseMessage])]) -> Int {
        for section in sections.reversed() {
            for row in section.messages.reversed() where row.id > 0 { return row.id }
        }
        return 0
    }
}
