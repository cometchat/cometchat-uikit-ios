//
//  ExtensionModerator.swift
//  
//
//  Created by Pushpsen Airekar on 16/02/23.
//

import Foundation
import CometChatSDK

class ExtensionModerator {
    
    static func extensionCheck(baseMessage: BaseMessage) -> [String: [String:Any]]? {
        guard let metaData = baseMessage.metaData, !metaData.isEmpty else { return nil }
        var extensionMap = [String: [String:Any]]()
        if let injectedObject = metaData["@injected"] as? [String:Any], !injectedObject.isEmpty, let extensionsObject = injectedObject[ExtensionConstants.extensions] as? [String:Any] {
            
            if extensionsObject.containsKey(ExtensionConstants.smartReply) {
                extensionMap[ExtensionConstants.smartReply] = extensionsObject[ExtensionConstants.smartReply] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.messageTranslation) {
                extensionMap[ExtensionConstants.messageTranslation] = extensionsObject[ExtensionConstants.messageTranslation] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.profanityFilter) {
                extensionMap[ExtensionConstants.profanityFilter] = extensionsObject[ExtensionConstants.profanityFilter] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.imageModeration) {
                extensionMap[ExtensionConstants.imageModeration] = extensionsObject[ExtensionConstants.imageModeration] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.thumbnailGeneration) {
                extensionMap[ExtensionConstants.thumbnailGeneration] = extensionsObject[ExtensionConstants.thumbnailGeneration] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.sentimentalAnalysis) {
                extensionMap[ExtensionConstants.sentimentalAnalysis] = extensionsObject[ExtensionConstants.sentimentalAnalysis] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.polls) {
                extensionMap[ExtensionConstants.polls] = extensionsObject[ExtensionConstants.polls] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.reactions) {
                extensionMap[ExtensionConstants.reactions] = extensionsObject[ExtensionConstants.reactions] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.whiteboard) {
                extensionMap[ExtensionConstants.whiteboard] = extensionsObject[ExtensionConstants.whiteboard] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.document) {
                extensionMap[ExtensionConstants.document] = extensionsObject[ExtensionConstants.document] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.dataMasking) {
                extensionMap[ExtensionConstants.dataMasking] = extensionsObject[ExtensionConstants.dataMasking] as? [String : Any]
            }
            if extensionsObject.containsKey(ExtensionConstants.linkPreview) {
                extensionMap[ExtensionConstants.linkPreview] = extensionsObject[ExtensionConstants.linkPreview] as? [String : Any]
            }
        }
        return extensionMap
    }
}


extension Dictionary {
    func containsKey(_ key: Key) -> Bool {
        index(forKey: key) != nil
    }
    
}
