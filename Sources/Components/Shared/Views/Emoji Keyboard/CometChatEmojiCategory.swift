//
//  CometChatEmojiCategory.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 08/06/22.
//

import Foundation

struct CometChatEmojiCategories: Decodable {
    let emojiCategory: [CometChatEmojiCategory]
}

struct CometChatEmojiCategory: Decodable {
    let id: String
    let symbol: String
    let name: String
    let emojis: [CometChatEmoji]
}

