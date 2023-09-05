import Foundation

public struct UIConstants {
    static var channel = "ios_chat_ui_kit"
    static var packageName = "ios_chat_ui_kit"
}

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
    static var message = "message"
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
    static var messagePrivately = "messagePrivately"
    static var forwardMessage = "forwardMessage"
}

@objc public enum MessageBubbleAlignment: Int {
    case left
    case right
    case center
}


public enum  MessageBubbleTimeAlignment {
    case top
    case bottom
}

public enum MessageStatus: Int {
    case inProgress
    case success
}

public enum MessageListAlignment {
    
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
    static var viewMembers = "viewMembers"
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
    static var blockUnblock = "blockUnblock"
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
    static var privateGroup = "private"
    static var passwordProtectedGroup = "password"
    static var publicGroup = "public"
}


public struct  GroupMemberScope {
    static var users = "admin"
    static var groups = "moderator"
    static var both = "participant"
}

public enum CometChatDatePattern {
    case time
    case dayDate
    case dayDateTime
    case custom(String)
}

public struct DetailTemplateConstants {
    static var primaryActions = "primaryActions"
    static var secondaryActions = "secondaryActions"
}

public enum SelectionMode {
    case single
    case multiple
    case none
}

public enum UsersListenerConstants {
    static let userListener = "users-user-listener"
    
}

public enum GroupsListenerConstants {
    static let groupListener = "groups-group-listener"
    static let messagesListener = "groups-message-listener"
}

public enum ConversationsListenerConstants {
    static let userListener = "conversations-user-listener"
    static let groupListener = "conversations-group-listener"
    static let messagesListener = "conversations-message-listener"
}

public enum MessagesListenerConstants {
    static let userListener = "messages-user-listener"
    static let groupListener = "messages-group-listener"
    static let messagesListener = "messages-message-listener"
}

public enum GroupMembersListenerConstants {
    static let groupListener = "group-members-group-listener"
}

