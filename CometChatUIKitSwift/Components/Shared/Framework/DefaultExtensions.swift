//
//  File.swift
//  
//
//  Created by Ajay Verma on 20/03/23.
//

import Foundation
public class DefaultExtensions {
    
    public static var listOfAIExtensions = {
        return [
            AISmartRepliesExtension(),
            AIConversationStarterExtension(),
            AIConversationSummaryExtension()
        ]
    }
    
    public static var listOfExtensions = {
        return [
            CometChatLinkPreviewExtension(),
            CollaborativeDocumentExtension(),
            CollaborativeWhiteboardExtension(),
            MessageTranslationExtension(),
            CometChatPollsExtension(),
            ProfanityDataMaskingExtension(),
            CometChatSmartReplyExtension(),
            ThumbnailGenerationExtension(),
            CometChatStickerExtension()
        ]
    }
}
