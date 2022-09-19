//
//  Settings.swift
//  WidgetDemo
//
//  Created by Pushpsen Airekar on 10/08/20.
//  Copyright © 2020 Pushpsen Airekar. All rights reserved.
//

import Foundation
import UIKit

enum SwitchMode {
    case enabled
    case disabled

    var isEnabled: Bool {
        switch self {
        case .enabled:
            return true
        case .disabled:
            return false
        }
    }
}

 enum UserDisplayMode {
    case friends
    case all
    case none
}

enum ChatDisplayMode {
   case user
   case group
   case both
}

 enum GroupDisplayMode {
    case publicGroups
    case passwordProtectedGroups
    case publicAndPasswordProtectedGroups
    case none
}



public struct UIKitSettings {
    
    static var bundle = Bundle.main
    
    // Keys
    static var googleApiKey = "ENTER YOUR GOOGLE API KEY HERE"
    
    // style
    static var primaryColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    static var secondaryColor: UIColor = #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
    static var URLColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
    static var URLSelectedColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0, blue: 0.6165823063, alpha: 1)
    static var PhoneNumberColor: UIColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
    static var PhoneNumberSelectedColor: UIColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
    static var EmailIDColor: UIColor = #colorLiteral(red: 0.9529411793, green: 0.5480152855, blue: 0, alpha: 1)
    static var EmailIDSelectedColor: UIColor = #colorLiteral(red: 0.9529411765, green: 0.4078431373, blue: 0, alpha: 1)
    static var foregroundColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)  //not added
    static var backgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)  //not added
    static var overrideSystemBackgroundColor: SwitchMode = .disabled  //not added
    
    // sidebar
    //--> 1. Listing
    static var tabbar: SwitchMode = .enabled
    static var chatListMode: ChatDisplayMode = .both
    static var userInMode: UserDisplayMode = .all
    static var groupInMode: GroupDisplayMode = .publicAndPasswordProtectedGroups
    static var conversations: SwitchMode = .enabled
    static var calls: SwitchMode = .enabled
    static var groups: SwitchMode = .enabled
    static var users: SwitchMode = .enabled
    static var userSettings: SwitchMode = .enabled
    
     
    //Main
    static var publicGroup: SwitchMode = .enabled
    static var privateGroup: SwitchMode = .enabled
    static var passwordGroup: SwitchMode = .enabled
    static var sendTextMessage: SwitchMode = .enabled
    static var sendMessageInOneOnOne: SwitchMode = .enabled
    static var sendMessageInGroup: SwitchMode = .enabled
    static var sendPhotoVideos: SwitchMode = .enabled
    static var sendFiles: SwitchMode = .enabled
    static var sendVoiceNotes: SwitchMode = .enabled
    static var sendEmojis: SwitchMode = .enabled
    static var sendEmojisInLargerSize: SwitchMode = .enabled
    static var sendStickers: SwitchMode = .enabled
    static var sendGifs: SwitchMode = .enabled //not added (feature not available)
    static var sendTypingIndicator: SwitchMode = .enabled
    static var sendMessageReaction: SwitchMode = .enabled
    static var sendLiveReaction: SwitchMode = .enabled
    static var editMessage: SwitchMode = .enabled
    static var deleteMessage: SwitchMode = .enabled
    static var shareCopyForwardMessage: SwitchMode = .enabled
    static var replyToMessage: SwitchMode = .enabled
    static var threadedChats: SwitchMode = .enabled
    static var userVideoCall: SwitchMode = .enabled
    static var userAudioCall: SwitchMode = .enabled
    static var groupAudioCall: SwitchMode = .enabled
    static var groupVideoCall: SwitchMode = .enabled
    static var groupCreation: SwitchMode = .enabled
    static var joinOrLeaveGroup: SwitchMode = .enabled
    static var viewGroupMembers: SwitchMode = .enabled
    static var allowDeleteGroup: SwitchMode = .enabled
    static var allowAddMembers: SwitchMode = .enabled
    static var allowModeratorToDeleteMemberMessages: SwitchMode = .enabled
    static var kickMember: SwitchMode = .enabled
    static var banMember: SwitchMode = .enabled
    static var allowPromoteDemoteMembers: SwitchMode = .enabled
    static var setGroupInQnaModeByModerators: SwitchMode = .enabled //not added (feature not available)
    static var hideDeletedMessages: SwitchMode = .disabled
    static var highlightMessageFromModerators: SwitchMode = .enabled //not added (feature not available)
    static var shareLocation: SwitchMode = .enabled 
    static var viewShareMedia: SwitchMode = .enabled
    static var showReadDeliveryReceipts: SwitchMode = .enabled
    static var showUserPresence: SwitchMode = .enabled
    static var blockUser: SwitchMode = .enabled
    static var polls: SwitchMode = .enabled
    static var enableSoundForCalls: SwitchMode = .enabled
    static var enableSoundForMessages: SwitchMode = .enabled
    static var enableActionsForCalls: SwitchMode = .enabled
    static var enableActionsForGroupNotifications: SwitchMode = .enabled
    static var collaborativeDocument: SwitchMode = .enabled
    static var collaborativeWhiteboard: SwitchMode = .enabled
    static var messageTranslation: SwitchMode = .enabled
    static var messageHistory: SwitchMode =  .enabled
    static var unreadCount: SwitchMode =  .enabled
    static var searchChats: SwitchMode =  .enabled
    static var searchUsers: SwitchMode =  .enabled
    static var searchGroups: SwitchMode =  .enabled
    static var searchMessages: SwitchMode =  .enabled
    static var callRecording: SwitchMode =  .enabled
    static var callLiveStreaming: SwitchMode =  .enabled
    static var callTranscription: SwitchMode =  .enabled
    static var dataMasking : SwitchMode =  .enabled
    static var profanityFilter : SwitchMode =  .enabled
    static var thumbnailGeneration : SwitchMode =  .enabled
    static var linkPreview : SwitchMode =  .enabled
    static var richMediaPreview : SwitchMode =  .enabled
    static var smartReplies: SwitchMode =  .enabled
    static var saveMessages: SwitchMode =  .enabled
    static var pinMessages: SwitchMode =  .enabled
    static var voiceTranscription: SwitchMode =  .enabled
    static var mentions: SwitchMode =  .enabled
    static var emailReplies: SwitchMode =  .enabled
    static var xssFilter: SwitchMode =  .enabled
    static var imageModeration: SwitchMode =  .enabled
    static var sentimentAnalysis: SwitchMode =  .enabled
    static var connectionIndicator: SwitchMode =  .disabled
    static var messageInPrivate: SwitchMode =  .enabled
    static var clearConversation: SwitchMode =  .enabled
    static var replyInPrivate: SwitchMode =  .enabled
    static var messageInformation: SwitchMode =  .enabled
    static var viewProfile: SwitchMode =  .enabled
    static var startConversation: SwitchMode =  .enabled
    public static var tabs: [Controller] = [.chats, .calls, .users , .groups, .settings]
}
