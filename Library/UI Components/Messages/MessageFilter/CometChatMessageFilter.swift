//
//  MessageFilter.swift
//  CometChatProWidget
//
//  Created by Pushpsen Airekar on 19/10/20.
//  Copyright © 2020 Pushpsen Airekar. All rights reserved.
//

import Foundation

struct MessageCategory {
    static var message : String = "message"
    static var call : String = "call"
    static var action : String = "action"
    static var custom : String = "custom"
    
}

struct MessageType {
    static var text : String = "text"
    static var image : String = "image"
    static var audio : String = "audio"
    static var video : String = "video"
    static var file : String = "file"
    static var custom : String = "custom"
    static var location : String = "location"
    static var poll : String = "extension_poll"
    static var sticker : String = "extension_sticker"
    static var collaborativeWhiteboard : String = "extension_whiteboard"
    static var collaborativeDocument : String = "extension_document"
    static var meeting : String = "meeting"
}

struct ActionType {
    static var groupMember : String = "groupMember"
    static var banned : String = "banned"
    static var unbanned : String = "unbanned"
    static var joined : String = "joined"
    static var kicked : String = "kicked"
    static var left : String = "left"
    static var added : String = "added"
    static var scopeChanged : String = "scopeChanged"
}

struct CallType {
    static var rejected = "rejected"
    static var busy = "busy"
    static var cancelled = "cancelled"
    static var ended =  "ended"
    static var initiated =  "initiated"
    static var ongoing =  "ongoing"
    static var unanswered =  "unanswered"
}


class MessageFilter {
    
    static var messageCategoriesForUser = [String]()
    static var messageCategoriesForGroup = [String]()
    static var messageTypesForUser = [String]()
    static var messageTypesForGroup = [String]()
    
    static func fetchMessageCategoriesForUser() -> [String] {
        messageCategoriesForUser = [MessageCategory.message,
                                    MessageCategory.custom]
        
        FeatureRestriction.isCallActionMessagesEnabled { (success) in
            if success == .enabled {
                messageCategoriesForUser.append(MessageCategory.call)
            }
        }
        
        return messageCategoriesForUser
    }
    
    static func fetchMessageCategoriesForGroups() -> [String] {
        messageCategoriesForGroup = [MessageCategory.message,
                                     MessageCategory.custom,
                                     MessageCategory.action]
        
        FeatureRestriction.isCallActionMessagesEnabled { (success) in
            if success == .enabled {
                messageCategoriesForGroup.append(MessageCategory.call)
            }
        }
        
        return messageCategoriesForGroup
    }
    
    static func fetchMessageTypesForUser() -> [String]  {
        messageTypesForUser = [MessageType.custom,
                               MessageType.audio,
                               MessageType.text,
                               MessageType.image,
                               MessageType.video,
                               MessageType.file,
                               MessageType.location,
                               MessageType.poll,
                               MessageType.sticker,
                               MessageType.collaborativeWhiteboard,
                               MessageType.collaborativeDocument]

        return messageTypesForUser
    }
    
    static func fetchMessageTypesForGroup() -> [String]  {
        messageTypesForGroup = [MessageType.custom,
                                MessageType.audio,
                                MessageType.text,
                                MessageType.image,
                                MessageType.video,
                                MessageType.file,
                                MessageType.location,
                                MessageType.poll,
                                MessageType.sticker,
                                MessageType.collaborativeWhiteboard,
                                MessageType.collaborativeDocument]
       
        FeatureRestriction.isGroupActionMessagesEnabled { (success) in
            if success == .enabled {
                messageTypesForGroup.append(ActionType.groupMember)
            }
        }
        
        FeatureRestriction.isGroupAudioCallEnabled { (audioCallSuccess) in
            FeatureRestriction.isGroupVideoCallEnabled { (videoCallSuccess) in
                if audioCallSuccess == .enabled || videoCallSuccess == .enabled {
                    messageTypesForGroup.append(MessageType.meeting)
                }
            }
        }
        return messageTypesForGroup
    }
    
}
