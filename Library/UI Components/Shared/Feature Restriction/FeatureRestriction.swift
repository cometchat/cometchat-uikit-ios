//
//  FeatureRestriction.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 13/04/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro






public final class FeatureRestriction {
    
    //------------------------------------------------------------------------------------------------//
    //-------------------------------------- F E A T U R E S -----------------------------------------//
    //------------------------------------------------------------------------------------------------//
    
    static func isOneOnOneChatEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        CometChat.isFeatureEnabled(feature: Feature().chat_one_on_one_enabled) { (bool) in
            if bool == true && UIKitSettings.sendMessageInOneOnOne == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    static func isGroupChatEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        CometChat.isFeatureEnabled(feature: Feature().chat_groups_enabled) { (bool) in
            if bool == true && UIKitSettings.sendMessageInGroup == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    static func isRecentChatListEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.conversations == .enabled {
            
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isUserListEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_users_list_enabled) { (bool) in
            if bool == true && UIKitSettings.users == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    static func isGroupListEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        CometChat.isFeatureEnabled(feature: Feature().chat_groups_enabled) { (bool) in
            if bool == true && UIKitSettings.groups == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    static func isCallListEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().calls_enabled) { (bool) in
            if bool == true && UIKitSettings.calls == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    static func isUserSettingsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.userSettings == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isUserPresenceEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        CometChat.isFeatureEnabled(feature: Feature().chat_users_presence_enabled) { (bool) in
            if bool == true && UIKitSettings.showUserPresence == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isTypingIndicatorsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_typing_indicator_enabled) { (bool) in
            if bool == true && UIKitSettings.sendTypingIndicator == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isDeliveryReceiptsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_messages_receipts_enabled) { (bool) in
            if bool == true && UIKitSettings.showReadDeliveryReceipts == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isMessageRepliesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_messages_replies_enabled) { (bool) in
            if bool == true && UIKitSettings.replyToMessage == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isThreadedMessagesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_messages_threads_enabled) { (bool) in
            if bool == true && UIKitSettings.threadedChats == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.enabled)
        }
        
    }
    
    static func isPhotosVideosEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_messages_media_enabled) { (bool) in
            if bool == true && UIKitSettings.sendPhotoVideos == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isFilesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_messages_media_enabled) { (bool) in
            if bool == true && UIKitSettings.sendFiles == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isVoiceNotesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_voice_notes_enabled) { (bool) in
            if bool == true && UIKitSettings.sendVoiceNotes == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isMessageHistoryEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_messages_history_enabled) { (bool) in
            if bool == true && UIKitSettings.messageHistory == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isUnreadCountEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_messages_unread_count_enabled) { (bool) in
            if bool == true && UIKitSettings.unreadCount == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isChatSearchEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if UIKitSettings.searchChats == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
        
    }
    
    static func isUserSearchEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_users_search_enabled) { (bool) in
            if bool == true && UIKitSettings.searchUsers == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isGroupSearchEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_groups_search_enabled) { (bool) in
            if bool == true && UIKitSettings.searchGroups == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isMessageSearchEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_messages_search_enabled) { (bool) in
            if bool == true && UIKitSettings.searchMessages == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    // Voice & Video Calling/Conferencing
    
    static func isOneOnOneAudioCallEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().call_one_on_one_audio_enabled) { (bool) in
            if bool == true && UIKitSettings.userAudioCall == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isOneOnOneVideoCallEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().call_one_on_one_video_enabled) { (bool) in
            if bool == true && UIKitSettings.userVideoCall == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isGroupAudioCallEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().call_groups_audio_enabled) { (bool) in
            if bool == true && UIKitSettings.groupAudioCall == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isGroupVideoCallEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().call_groups_video_enabled) { (bool) in
            if bool == true && UIKitSettings.groupVideoCall == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isCallRecordingEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().call_recording_enabled) { (bool) in
            if bool == true && UIKitSettings.callRecording == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isCallLiveStreamingEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().call_live_streaming_enabled) { (bool) in
            if bool == true && UIKitSettings.callLiveStreaming == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isCallTranscriptEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().call_transcript_enabled) { (bool) in
            if bool == true && UIKitSettings.callTranscription == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    
    
    
    //    // User Engagement
    
    
    
    static func isLiveReactionsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().live_reactions_enabled) { (bool) in
            if bool == true && UIKitSettings.sendLiveReaction == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    
    
    // Moderation
    
    static func isBlockUserEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_users_block_enabled) { (bool) in
            if bool == true && UIKitSettings.blockUser == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isDeleteMemberMessageEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_groups_moderators_enabled) { (bool) in
            if bool == true && UIKitSettings.allowModeratorToDeleteMemberMessages == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isQNAModeEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_groups_moderators_enabled) { (bool) in
            if bool == true && UIKitSettings.setGroupInQnaModeByModerators == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isHighlightMessagesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_groups_moderators_enabled) { (bool) in
            if bool == true && UIKitSettings.highlightMessageFromModerators == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isKickingGroupMembersEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_groups_kick_enabled) { (bool) in
            if bool == true && UIKitSettings.kickMember == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isBanningGroupMembersEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_groups_ban_enabled) { (bool) in
            if bool == true && UIKitSettings.banMember == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    
    static func isPublicGroupEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_groups_public_enabled) { (bool) in
            if bool == true && UIKitSettings.publicGroup == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isPrivateGroupEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_groups_private_enabled) { (bool) in
            if bool == true && UIKitSettings.privateGroup == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isPasswordGroupEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().chat_groups_password_enabled) { (bool) in
            if bool == true && UIKitSettings.passwordGroup == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isEditMessageEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.editMessage == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isJoinLeaveGroupsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.joinOrLeaveGroup == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isLargerSizeEmojisEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.sendEmojisInLargerSize == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isGifsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.sendGifs == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isSharedMediaEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.viewShareMedia == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isMessagesSoundEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.enableSoundForMessages == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isShareCopyForwardMessageEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.shareCopyForwardMessage == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isCallsSoundEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.enableSoundForCalls == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isCallActionMessagesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.enableActionsForCalls == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isGroupDeletionEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.allowDeleteGroup == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isChangingGroupMemberScopeEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.allowPromoteDemoteMembers == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isAddingGroupMembersEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.allowAddMembers == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isLocationSharingEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.shareLocation == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isGroupActionMessagesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.enableActionsForGroupNotifications == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isGroupCreationEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.groupCreation == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isDeleteMessageEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.deleteMessage == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isHideDeletedMessagesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.hideDeletedMessages == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isViewingGroupMembersEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.viewGroupMembers == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isMessageInPrivateEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.messageInPrivate == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isMessageInformationEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.messageInformation == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isViewProfileEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.viewProfile == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isclearConversationEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.clearConversation == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isReplyInPrivateEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.replyInPrivate == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    static func isStartConversationEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        if  UIKitSettings.startConversation == .enabled {
            completion(.enabled)
        }else{
            completion(.disabled)
        }
    }
    
    //------------------------------------------------------------------------------------------------//
    
    
    
    
    
    
    //------------------------------------------------------------------------------------------------//
    //---------------------------------- E X T E N T I O N S -----------------------------------------//
    //------------------------------------------------------------------------------------------------//
    
    // User Experience
    
    static func isThumbnailGenerationEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().thumbnail_generation_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().thumbnailGeneration) { (bool) in
                if success == true && bool == true && UIKitSettings.thumbnailGeneration == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isLinkPreviewEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().link_preview_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().linkPreview) { (bool) in
                if success == true && bool == true && UIKitSettings.linkPreview == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isSaveMessagesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().messages_saved_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().saveMessages) { (bool) in
                if success == true && bool == true && UIKitSettings.saveMessages == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isPinMessagesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().messages_pinned_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().pinMessages) { (bool) in
                if success == true && bool == true && UIKitSettings.pinMessages == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isRichMediaPreviewEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().rich_media_preview_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().richMediaPreview) { (bool) in
                if success == true && bool == true && UIKitSettings.richMediaPreview == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isVoiceTranscriptionEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().voice_transcription_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().voiceTranscription) { (bool) in
                if success == true && bool == true && UIKitSettings.voiceTranscription == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isMessageTranslationEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().message_translation_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().messageTranslation) { (bool) in
                if success == true && bool == true && UIKitSettings.messageTranslation == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    static func isEmailRepliesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().email_replies_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().emailReplies) { (bool) in
                if success == true && bool == true && UIKitSettings.emailReplies == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isSmartRepliesEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().smart_replies_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().smartReplies) { (bool) in
                if success == true && bool == true && UIKitSettings.smartReplies == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isPollsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().polls_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().polls) { (bool) in
                if success == true && bool == true && UIKitSettings.polls == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    //    // Collaboration
    
    static func isCollaborativeWhiteBoardEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().collaboration_whiteboard_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().collaborationWhiteboard) { (bool) in
                if success == true && bool == true && UIKitSettings.collaborativeWhiteboard == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isCollaborativeDocumentEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().collaboration_document_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().collaborationDocument) { (bool) in
                if success == true && bool == true && UIKitSettings.collaborativeDocument == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    static func isXssFilterEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_xss_filter_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().xssFilter) { (bool) in
                if success == true && bool == true && UIKitSettings.xssFilter == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    static func isProfanityFilterEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_profanity_filter_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().profanityFilter) { (bool) in
                if success == true && bool == true && UIKitSettings.profanityFilter == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    static func isImageModerationEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_image_moderation_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().imageModeration) { (bool) in
                if success == true && bool == true && UIKitSettings.imageModeration == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isDataMaskingEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_image_moderation_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().imageModeration) { (bool) in
                if success == true && bool == true && UIKitSettings.imageModeration == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isMalwareScannerEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_malware_scanner_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().malwareScanner) { (bool) in
                if success == true && bool == true && UIKitSettings.imageModeration == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    static func isSentimentAnalysisEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().moderation_sentiment_analysis_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().sentimentAnalysis) { (bool) in
                if success == true && bool == true && UIKitSettings.sentimentAnalysis == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
            
        } onError: { (error) in
            completion(.disabled)
        }
        
    }
    
    
    static func isEmojisEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        CometChat.isFeatureEnabled(feature: Feature().emojis_enabled) { (success) in
            if success == true &&  UIKitSettings.sendEmojis == .enabled {
                completion(.enabled)
            }else{
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    static func isMentionsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        
        CometChat.isFeatureEnabled(feature: Feature().mentions_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().mentions) { (bool) in
                if success == true && bool == true && UIKitSettings.mentions == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    static func isStickersEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        CometChat.isFeatureEnabled(feature: Feature().stickers_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().sticker) { (bool) in
                if success == true && bool == true && UIKitSettings.sendStickers == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    static func isReactionsEnabled(completion: @escaping (_ bool: SwitchMode) -> Void) {
        CometChat.isFeatureEnabled(feature: Feature().reactions_enabled) { (success) in
            CometChat.isExtensionEnabled(extensionId: Extension().reactions) { (bool) in
                if success == true && bool == true && UIKitSettings.sendMessageReaction == .enabled {
                    completion(.enabled)
                }else{
                    completion(.disabled)
                }
            } onError: { (error) in
                completion(.disabled)
            }
        } onError: { (error) in
            completion(.disabled)
        }
    }
    
    //------------------------------------------------------------------------------------------------//
}


