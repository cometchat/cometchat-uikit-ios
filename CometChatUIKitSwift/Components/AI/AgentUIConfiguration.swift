//
// AgentUIConfiguration.swift
// CometChatUIKitSwift
//
// Created for AI Agents in Group Chat feature.
//

import Foundation
import UIKit

/// Configuration for AI agent rendering in group chat.
/// Every field is optional with safe defaults - zero-config still renders correctly.
/// Attach to the existing `CometChatMessageList` or message-list configuration.
public class AgentUIConfiguration {
 
 // MARK: - Singleton (global defaults; can be overridden per-instance)
 public static let shared = AgentUIConfiguration()
 
 // MARK: - Badge Configuration
 
 /// Style for the agent badge on message bubbles and member rows.
 public var agentBadgeStyle: AgentBadgeStyle = AgentBadgeStyle()
 
 // MARK: - Bubble Configuration
 
 /// Optional distinct bubble background for agent messages (default = member bubble background).
 /// Set to a color to apply a custom background on agent messages.
 public var agentBubbleBackgroundColor: UIColor? = nil
 
 // MARK: - Failure Message
 
 /// Custom text for the failure notice when an agent does not respond.
 /// Default: "Agent could not respond. Try again."
 public var failureMessageText: String? = nil
 
 // MARK: - Handoff Transition
 
 /// Mode for the handoff transition when a human joins via escalation.
 public var handoffTransitionMode: AgentHandoffMode = .systemMessage
 
 /// Custom text for the handoff system message.
 /// Default: "Connecting you with a team member..."
 public var handoffMessageText: String? = nil
 
 public init() {}
}

// MARK: - Supporting Enums

/// Mode for how the handoff transition is rendered.
public enum AgentHandoffMode: String {
 /// Show a system message in the chat (default).
 case systemMessage
 /// Only show the normal member-joined affordance.
 case silentJoin
}
