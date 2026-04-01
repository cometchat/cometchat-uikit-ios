//
//  ComposerState.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import Foundation

/// Represents the current state of the message composer
public enum ComposerState {
    /// Normal message composition
    case draft
    /// Editing an existing message
    case edit
    /// Replying to a message
    case reply
}
