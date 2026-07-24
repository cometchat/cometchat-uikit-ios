//
//  Exports.swift
//  CometChatUIKitSwift
//
//  This target exists only to attach the CometChatCardsSwift package dependency
//  to the CometChatUIKitSwift library product — SPM binary targets cannot declare
//  dependencies. Importing it re-exports nothing; consumers `import
//  CometChatCardsSwift` directly where they use Cards types.
//

import CometChatCardsSwift
