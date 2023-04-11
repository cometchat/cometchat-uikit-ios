//
//  File.swift
//  
//
//  Created by Ajay Verma on 20/03/23.
//

import Foundation
public class DefaultExtensions {
    
    public static var listOfExtensions = {
        return [
            CometChatLinkPreviewExtension(),
            CollaborativeDocumentExtension(),
            CollaborativeWhiteboardExtension(),
            CometChatImageModerationExtension(),
            MessageTranslationExtension(),
            CometChatPollsExtension(),
            ProfanityDataMaskingExtension(),
            ReactionExtension(),
            CometChatSmartReplyExtension(),
            ThumbnailGenerationExtension(),
            CometChatStickerExtension()
        ]
    }
}
