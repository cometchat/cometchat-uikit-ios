//
//  Features.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 14/04/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

struct Feature {
    
    // Core Chat
    let chat_one_on_one_enabled = "core.chat.one-on-one.enabled" 
    let chat_groups_enabled = "core.chat.groups.enabled"
    let chat_groups_public_enabled = "core.chat.groups.public.enabled"
    let chat_groups_private_enabled = "core.chat.groups.private.enabled"
    let chat_groups_password_enabled = "core.chat.groups.password.enabled"
    let chat_users_list_enabled = "core.chat.users.list.enabled"
    let chat_users_presence_enabled = "core.chat.users.presence.enabled"
    let chat_typing_indicator_enabled = "core.chat.typing-indicator.enabled"
    let chat_messages_receipts_enabled = "core.chat.messages.receipts.enabled"
    let chat_messages_custom_enabled = "core.chat.messages.custom.enabled"
    let chat_messages_replies_enabled = "core.chat.messages.replies.enabled"
    let chat_messages_threads_enabled = "core.chat.messages.threads.enabled"
    let chat_messages_media_enabled = "core.chat.messages.media.enabled"
    let chat_voice_notes_enabled = "core.chat.voice-notes.enabled"
    let chat_messages_history_enabled = "core.chat.messages.history.enabled"
    let chat_messages_unread_count_enabled = "core.chat.messages.unread-count.enabled"
    let chat_users_search_enabled = "core.chat.users.search.enabled"
    let chat_groups_search_enabled = "core.chat.groups.search.enabled"
    let chat_messages_search_enabled = "core.chat.messages.search.enabled"
    
    // Voice & Video Calling/Conferencing
    let calls_enabled = "core.call.enabled"
    let call_one_on_one_audio_enabled  = "core.call.one-on-one.audio.enabled"
    let call_one_on_one_video_enabled = "core.call.one-on-one.video.enabled"
    let call_groups_audio_enabled = "core.call.groups.audio.enabled"
    let call_groups_video_enabled = "core.call.groups.video.enabled"
    let call_recording_enabled = "core.call.recording.enabled"
    let call_live_streaming_enabled = "core.call.live-streaming.enabled"
    let call_transcript_enabled = "core.call.transcript.enabled"
    
    // User Experience
    let thumbnail_generation_enabled  = "features.ux.thumbnail-generation.enabled"
    let link_preview_enabled  = "features.ux.link-preview.enabled"
    let messages_saved_enabled  = "features.ux.messages.saved.enabled"
    let messages_pinned_enabled  = "features.ux.messages.pinned.enabled"
    let rich_media_preview_enabled  = "features.ux.rich-media-preview.enabled"
    let voice_transcription_enabled  = "features.ux.voice-transcription.enabled"
    
    // User Engagement
    let emojis_enabled  = "features.ue.emojis.enabled"
    let mentions_enabled  = "features.ue.mentions.enabled"
    let stickers_enabled  = "features.ue.stickers.enabled"
    let reactions_enabled  = "features.ue.reactions.enabled"
    let live_reactions_enabled  = "features.ue.live-reactions.enabled"
    let message_translation_enabled  = "features.ue.message-translation.enabled"
    let email_replies_enabled  = "features.ue.email-replies.enabled"
    let smart_replies_enabled  = "features.ue.smart-replies.enabled"
    let polls_enabled  = "features.ue.polls.enabled"
    
    // Collaboration
    let collaboration_whiteboard_enabled  = "features.collaboration.whiteboard.enabled"
    let collaboration_document_enabled  = "features.collaboration.document.enabled"
    
    // Moderation
    let moderation_users_block_enabled  = "features.moderation.users.block.enabled"
    let moderation_groups_moderators_enabled  = "features.moderation.groups.moderators.enabled"
    let moderation_groups_kick_enabled  = "features.moderation.groups.kick.enabled"
    let moderation_groups_ban_enabled  = "features.moderation.groups.ban.enabled"
    let moderation_xss_filter_enabled  = "features.moderation.xss-filter.enabled"
    let moderation_profanity_filter_enabled  = "features.moderation.profanity-filter.enabled"
    let moderation_image_moderation_enabled  = "features.moderation.image-moderation.enabled"
    let moderation_data_masking_enabled  = "features.moderation.data-masking.enabled"
    let moderation_malware_scanner_enabled  = "features.moderation.malware-scanner.enabled"
    let moderation_sentiment_analysis_enabled  = "features.moderation.sentiment-analysis.enabled"
    let moderation_inflight_message_moderation_enabled = "features.moderation.inflight-message-moderation.enabled"
    
}


struct Extension {

    let dataMasking = "data-masking"
    let profanityFilter = "profanity-filter"
    let thumbnailGeneration = "thumbnail-generator"
    let linkPreview = "link-preview"
    let richMediaPreview = "rich-media"
    let sticker = "stickers"
    let reactions = "reactions"
    let messageTranslation = "message-translation"
    let smartReplies = "smart-reply"
    let collaborationWhiteboard = "whiteboard"
    let collaborationDocument = "document"
    let pinMessages = "pin-message"
    let saveMessages = "save-message"
    let voiceTranscription = "voice-transcription"
    let polls = "polls"
    let xssFilter = "xss-filter"
    let imageModeration = "image-moderation"
    let malwareScanner = "virus-malware-scanner"
    let sentimentAnalysis = "sentiment-analysis"
    let emailReplies = "email-replies"
    let emojis = "emojis"
    let mentions = "mentions"
}
