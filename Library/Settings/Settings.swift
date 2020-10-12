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

 enum GroupDisplayMode {
    case publicGroups
    case passwordProtectedGroups
    case publicAndPasswordProtectedGroups
    case none
}


struct UIKitSettings {
    
    // Sound
    static var enableSoundForCalls: SwitchMode = .enabled
    static var enableSoundForMessages: SwitchMode = .enabled
    
    
    // Yet to be added  ~~
    
//    // style
//    static var primaryColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//    static var foregroundColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//    static var backgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//    static var overrideSystemBackgroundColor: SwitchMode = .disabled
//
//    // sidebar
//    //--> 1. Listing
//    static var tabbar: SwitchMode = .enabled
//    static var userInMode: UserDisplayMode = .all
//    static var groupInMode: GroupDisplayMode = .publicAndPasswordProtectedGroups  //not added (filter needed from SDK)
//    static var conversations: SwitchMode = .enabled
//    static var calls: SwitchMode = .enabled
//    static var groups: SwitchMode = .enabled
//    static var users: SwitchMode = .enabled
//    static var userSettings: SwitchMode = .enabled
//
//
//    //Main
//    static var joinLeaveNotifications: SwitchMode = .enabled //not added (filter needed from SDK)
//    static var callNotifications: SwitchMode = .enabled //not added (filter needed from SDK)
//    static var kickBanChangeScopeNotifications: SwitchMode = .enabled //not added (filter needed from SDK)
//    static var sendMessage: SwitchMode = .enabled
//    static var sendPhotoVideos: SwitchMode = .enabled
//    static var sendFiles: SwitchMode = .enabled
//    static var sendVoiceNotes: SwitchMode = .disabled
//    static var sendEmojies: SwitchMode = .enabled
//    static var sendEmojiesInLargerSize: SwitchMode = .enabled
//    static var sendGifs: SwitchMode = .enabled //not added (feature not available)
//    static var sendTypingIndicator: SwitchMode = .enabled
//    static var editMessage: SwitchMode = .enabled
//    static var deleteMessage: SwitchMode = .enabled
//    static var shareCopyForwardMessage: SwitchMode = .disabled
//    static var replyingToMessage: SwitchMode = .disabled
//    static var threadedChats: SwitchMode = .disabled
//    static var userVideoCall: SwitchMode = .enabled
//    static var userAudioCall: SwitchMode = .enabled
//    static var groupAudioCall: SwitchMode = .enabled
//    static var groupVideoCall: SwitchMode = .enabled
//    static var groupCreation: SwitchMode = .enabled
//    static var joinOrLeaveGroup: SwitchMode = .enabled
//    static var viewGroupMembers: SwitchMode = .enabled
//    static var allowDeleteGroup: SwitchMode = .enabled
//    static var allowAddMembers: SwitchMode = .enabled
//    static var allowModeratorToDeleteMemberMessages: SwitchMode = .disabled
//    static var allowKickBanMembers: SwitchMode = .disabled
//    static var allowPromoteDemoteMembers: SwitchMode = .disabled
//    static var allowMentionMembers: SwitchMode = .enabled //not added (feature not available)
//    static var setGroupInQnaModeByModerators: SwitchMode = .enabled //not added (feature not available)
//    static var hideDeletedMessages: SwitchMode = .enabled //not added (filter needed from SDK)
//    static var highlightMessageFromModerators: SwitchMode = .enabled //not added (feature not available)
//    static var shareLiveReaction: SwitchMode = .disabled
//    static var shareLocation: SwitchMode = .enabled
//    static var viewShareMedia: SwitchMode = .enabled
//    static var showReadDeliveryReceipts: SwitchMode = .enabled
//    static var showUserPresence: SwitchMode = .enabled
//    static var blockUser: SwitchMode = .disabled
//    static var createPoll: SwitchMode = .disabled
   
}
