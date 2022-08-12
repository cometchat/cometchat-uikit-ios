



import Foundation

public struct UIKitConstants {
    
    public struct  MessageCategoryConstants {
        static var message = "message"
        static var custom = "custom"
        static var action = "action"
        static var call = "call"
    }
    
    public struct  MessageTypeConstants {
        static var text = "text"
        static var file = "file"
        static var image = "image"
        static var audio = "audio"
        static var video = "video"
        static var poll = "extension_poll"
        static var sticker = "extension_sticker"
        static var document = "extension_document"
        static var whiteboard = "extension_whiteboard"
        static var meeting = "meeting"
        static var location = "location"
        static var groupMember = "groupMember"
    }
    
    public struct  ReceiverTypeConstants {
        static var user = "user"
        static var group = "group"
    }
    
    public struct  MessageOptionConstants {
        static var editMessage = "editMessage"
        static var deleteMessage = "deleteMessage"
        static var translateMessage = "translateMessage"
        static var reactToMessage = "reactToMessage"
        static var sendMessagePrivately = "sendMessagePrivately"
        static var replyMessagePrivately = "replyMessagePrivately"
        static var replyMessage = "replyMessage"
        static var replyInThread = "replyInThread"
        static var messageInformation = "messageInformation"
        static var copyMessage = "copyMessage"
        static var shareMessage = "shareMessage"
        static var forwardMessage = "forwardMessage"
    }
    
    @objc public enum MessageBubbleAlignmentConstants: Int {
        case left
        case right
        case center
    }


    public enum  MessageBubbleTimeAlignmentConstants {
        case top
        case bottom
    }

    public enum MessageStatusConstants: Int {
       case inProgress
       case success
   }
    
    public enum MessageListAlignmentConstants {
        
        case standard
        case leftAligned
        
    }
    
    public struct  MetadataConstants {

        static var replyMessage = "reply-message"
        static var sticker_url = "sticker_url"
        static var sticker_name = "sticker_name"
        static var liveReaction = "live_reaction"

    }
    
    public struct  GroupOptionConstants {
        static var leave = "leave"
        static var delete = "delete"
        static var viewMember = "viewMember"
        static var addMembers = "addMembers"
        static var bannedMembers = "bannedMembers"
        static var voiceCall = "voiceCall"
        static var videoCall = "videoCall"
        static var viewInformation = "viewInformation"
    }
    
    public struct  GroupMemberOptionConstants {
        static var kick = "kick"
        static var ban = "ban"
        static var unban = "unban"
        static var changeScope = "changeScope"
    }
    
    public struct  UserOptionConstants {
        static var unblock = "unblock"
        static var block = "block"
        static var viewProfile = "viewProfile"
        static var voiceCall = "voiceCall"
        static var videoCall = "videoCall"
        static var viewInformation = "viewInformation"
    }
    
    public struct  ConversationOptionConstants {
        static var delete = "delete"
    }
    
    public struct  ConversationTypeConstants {
        static var users = "users"
        static var groups = "groups"
        static var both = "both"
    }
    
    
    public struct  GroupTypeConstants {
        static var users = "private"
        static var groups = "password"
        static var both = "public"
    }
    
    
    public struct  GroupMemberScope {
        static var users = "admin"
        static var groups = "moderator"
        static var both = "participant"
    }
    
}
