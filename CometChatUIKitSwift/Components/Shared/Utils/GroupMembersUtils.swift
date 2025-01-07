//
//  GroupMembersUtils.swift
 
//
//  Created by Pushpsen Airekar on 24/11/22.
//

import Foundation
import CometChatSDK

public class GroupMembersUtils {
    
    let kickMember = CometChatGroupMemberOption(id: GroupMemberOptionConstants.kick, title: "KICK_MEMBER".localize(), icon: UIImage(named: "groups-kick.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), backgroundColor: CometChatTheme_v4.palatte.error,  onClick: nil)
    
    let banMember =  CometChatGroupMemberOption(id: GroupMemberOptionConstants.ban, title: "BAN_MEMBER".localize(), icon: UIImage(named: "groups-ban.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), backgroundColor: #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1),  onClick: nil)
    
    let unbanMember = CometChatGroupMemberOption(id: GroupMemberOptionConstants.unban, title: "UNBAN_MEMBER".localize(), icon: UIImage(named: "groups-kick.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), backgroundColor: CometChatTheme_v4.palatte.error,  onClick: nil)
    
    public init() {}

    
    public func getViewMemberOptions(group: Group, groupMember: GroupMember) -> [CometChatGroupMemberOption]? {
        let isAllowed = GroupMembersUtils.allowKickBanUnbanMember(group: group, groupMember: groupMember)
        if  isAllowed {
            return [kickMember, banMember]
        } else {
            return nil
        }
    }
    
    public func getBannedMemberOptions(group: Group, groupMember: GroupMember) -> [CometChatGroupMemberOption]? {
        let isAllowed = GroupMembersUtils.allowKickBanUnbanMember(group: group, groupMember: groupMember)
        if isAllowed {
            return [unbanMember]
        } else {
            return nil
        }
    }
    
    public static func allowKickBanUnbanMember(group: Group, groupMember: GroupMember) -> Bool {
        let myScope = group.scope
        let groupMemberScope = groupMember.scope
        if groupMember.uid == CometChat.getLoggedInUser()?.uid {
            return false
        }
        if group.owner == CometChat.getLoggedInUser()?.uid {
            return true
        } else {
            if groupMember.uid == CometChat.getLoggedInUser()?.uid {
                return false
            } else {
                switch myScope {
                case .participant: return false
                case .moderator:
                    switch  groupMemberScope {
                    case .admin, .moderator: return false
                    case .participant: return true
                    @unknown default: return false
                    }
                case .admin:
                    switch  groupMemberScope {
                    case .admin: return false
                    case .moderator, .participant: return true
                    @unknown default: return false
                    }
                @unknown default: return false
                }
            }
        }
    }
    
    public static func allowScopeChange(group: Group, groupMember: GroupMember) -> Bool {
        let myScope = group.scope
        let groupMemberScope = groupMember.scope
        
        if groupMember.uid == CometChat.getLoggedInUser()?.uid {
            return false
        } else if group.owner == CometChat.getLoggedInUser()?.uid {
            return true
        } else {
                switch myScope {
                case .participant: return false
                case .moderator:
                    switch  groupMemberScope {
                    case .admin, .moderator: return false
                    case .participant : return true
                    @unknown default: return false
                    }
                case .admin:
                    switch  groupMemberScope {
                    case .admin: return false
                    case .participant, .moderator: return true
                    @unknown default: return false
                    }
                @unknown default: return false
                }
        }
    }
}
