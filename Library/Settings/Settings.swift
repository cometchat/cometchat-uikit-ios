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
    
    static var bundle = Bundle.main
    
    // style
    static var primaryColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    static var URLColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
    static var URLSelectedColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0, blue: 0.6165823063, alpha: 1)
    static var PhoneNumberColor: UIColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
    static var PhoneNumberSelectedColor: UIColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
    static var EmailIDColor: UIColor = #colorLiteral(red: 0.9529411793, green: 0.5480152855, blue: 0, alpha: 1)
    static var EmailIDSelectedColor: UIColor = #colorLiteral(red: 0.9529411765, green: 0.4078431373, blue: 0, alpha: 1)
    static var foregroundColor: UIColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
    static var backgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static var overrideSystemBackgroundColor: SwitchMode = .disabled
    
    // sidebar
    //--> 1. Listing
    static var tabbar: SwitchMode = .enabled
    static var userInMode: UserDisplayMode = .all
    static var groupInMode: GroupDisplayMode = .publicAndPasswordProtectedGroups  //not added (filter needed from SDK)
    static var conversations: SwitchMode = .enabled
    static var calls: SwitchMode = .enabled
    static var groups: SwitchMode = .enabled
    static var users: SwitchMode = .enabled
    static var userSettings: SwitchMode = .enabled
    
    
    //Main
    static var joinLeaveNotifications: SwitchMode = .enabled //not added (filter needed from SDK)
    static var callNotifications: SwitchMode = .enabled //not added (filter needed from SDK)
    static var kickBanChangeScopeNotifications: SwitchMode = .enabled //not added (filter needed from SDK)
    static var sendMessage: SwitchMode = .enabled
    static var sendPhotoVideos: SwitchMode = .enabled
    static var sendFiles: SwitchMode = .enabled
    static var sendVoiceNotes: SwitchMode = .enabled
    static var sendEmojies: SwitchMode = .enabled
    static var sendStickers: SwitchMode = .enabled
    static var sendEmojiesInLargerSize: SwitchMode = .enabled
    static var sendGifs: SwitchMode = .enabled //not added (feature not available)
    static var sendTypingIndicator: SwitchMode = .enabled
    static var editMessage: SwitchMode = .enabled
    static var deleteMessage: SwitchMode = .enabled
    static var shareCopyForwardMessage: SwitchMode = .enabled
    static var replyingToMessage: SwitchMode = .enabled
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
    static var allowKickBanMembers: SwitchMode = .enabled
    static var allowPromoteDemoteMembers: SwitchMode = .enabled
    static var allowMentionMembers: SwitchMode = .enabled //not added (feature not available)
    static var setGroupInQnaModeByModerators: SwitchMode = .enabled //not added (feature not available)
    static var hideDeletedMessages: SwitchMode = .enabled //not added (filter needed from SDK)
    static var highlightMessageFromModerators: SwitchMode = .enabled //not added (feature not available)
    static var shareLiveReaction: SwitchMode = .enabled
    static var shareLocation: SwitchMode = .enabled 
    static var viewShareMedia: SwitchMode = .enabled
    static var showReadDeliveryReceipts: SwitchMode = .enabled
    static var showUserPresence: SwitchMode = .enabled
    static var blockUser: SwitchMode = .enabled
    static var createPoll: SwitchMode = .enabled
    static var enableSoundForCalls: SwitchMode = .enabled
    static var enableSoundForMessages: SwitchMode = .enabled
    static var enableActionsForCalls: SwitchMode = .enabled
    static var enableActionsForGroupNotifications: SwitchMode = .enabled
    static var messageReaction: SwitchMode = .enabled
    static var collaborativeWriteboard: SwitchMode = .enabled
    static var collaborativeWhiteboard: SwitchMode = .enabled
}
