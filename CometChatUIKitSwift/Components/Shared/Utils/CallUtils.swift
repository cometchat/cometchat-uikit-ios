//
//  CallUtils.swift
//  
//
//  Created by Ajay Verma on 16/03/23.
//

import Foundation
import UIKit
import CometChatSDK

public class CallUtils {
    
    public init() { }
    
    public func setupCallDetail(call: Call) -> String {

            switch call.callStatus  {
            case .initiated where call.callType == .audio   && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "OUTGOING_AUDIO_CALL".localize()
                
            case .initiated where call.callType == .audio && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return  "INCOMING_AUDIO_CALL".localize()
                
            case .initiated where call.callType == .video  && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "INCOMING_VIDEO_CALL".localize()
                
            case .initiated where call.callType == .video && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "OUTGOING_VIDEO_CALL".localize()
                
            case .unanswered where call.callType == .audio  && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "UNANSWERED_AUDIO_CALL".localize()
                
            case .unanswered where call.callType == .audio  && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "MISSED_CALL".localize()
                
            case .unanswered where call.callType == .video   && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "UNANSWERED_VIDEO_CALL".localize()
                
            case .unanswered where call.callType == .video  && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "MISSED_CALL".localize()
                
            case .cancelled where call.callType == .audio && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "OUTGOING_AUDIO_CALL".localize()
                
            case .cancelled where call.callType == .audio && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "MISSED_CALL".localize()
                
            case .cancelled where call.callType == .video && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "OUTGOING_VIDEO_CALL".localize()
                
            case .cancelled where call.callType == .video && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "MISSED_CALL".localize()
                
            case .rejected where call.callType == .audio && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "CALL_REJECTED".localize()
                
            case .rejected where call.callType == .audio && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "REJECTED_CALL".localize()
                
            case .rejected where call.callType == .video && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "CALL_REJECTED".localize()
                
            case .rejected where call.callType == .video && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "REJECTED_CALL".localize()
                

            case .ongoing where call.callType == .audio && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
               return "OUTGOING_AUDIO_CALL".localize()
                
            case .ongoing where call.callType == .audio && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "MISSED_CALL".localize()
                
            case .ongoing where call.callType == .video && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "OUTGOING_VIDEO_CALL".localize()
                
            case .ongoing where call.callType == .video && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "MISSED_CALL".localize()
                
            case .ended where call.callType == .audio && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "OUTGOING_AUDIO_CALL".localize()
                
            case .ended where call.callType == .audio && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "INCOMING_AUDIO_CALL".localize()
                
            case .ended where call.callType == .video && (call.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid:
                return "OUTGOING_VIDEO_CALL".localize()
                
            case .ended where call.callType == .video && (call.callInitiator as? User)?.uid != CometChat.getLoggedInUser()?.uid:
                return "INCOMING_VIDEO_CALL".localize()
                
            case .rejected: break
            case .busy: break
            case .cancelled: break
            case .ended: break
            case .initiated: break
            case .ongoing: break
            case .unanswered: break
            @unknown default: break
            }
        return ""
    }
  
}

#if canImport(CometChatCallsSDK)

import CometChatCallsSDK

extension CallUtils {
    
    public func configureCallLogSubtitleView(
        callData: Any,
        style: CallLogStyle,
        incomingCallIcon: UIImage? = nil,
        outgoingCallIcon: UIImage? = nil,
        missedCallIcon: UIImage? = nil
    ) -> UIView {
        
        if let callData = (callData as? CallLog) {
            
            let subtitleView = UIStackView()
            subtitleView.axis = .horizontal
            subtitleView.translatesAutoresizingMaskIntoConstraints = false
            subtitleView.spacing = 5
            
            let callStatus = setupCallLogStatus(
                call: callData,
                style: style,
                incomingCallIcon: incomingCallIcon,
                outgoingCallIcon: outgoingCallIcon,
                missedCallIcon: missedCallIcon
            )
                                                
            let callStatusIcon = UIImageView(image: callStatus.icon)
            callStatusIcon.translatesAutoresizingMaskIntoConstraints = false
            callStatusIcon.widthAnchor.constraint(equalToConstant: 16).isActive = true
            callStatusIcon.heightAnchor.constraint(equalToConstant: 16).isActive = true
            callStatusIcon.contentMode = .scaleAspectFit
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = convertTimeStampToCallDate(timestamp: callData.initiatedAt)
            subtitleLabel.font = style.listItemSubTitleFont
            subtitleLabel.textColor = style.listItemSubTitleTextColor
            subtitleView.addArrangedSubview(callStatusIcon)
            subtitleView.addArrangedSubview(subtitleLabel)
            
            return subtitleView
            
        }
        
        return UIView()
        
    }
    
    public func setupCallLogStatus(
        call: Any,
        style: CallLogStyle? = nil,
        incomingCallIcon: UIImage? = nil,
        outgoingCallIcon: UIImage? = nil,
        missedCallIcon: UIImage? = nil
    ) -> (statusWithType: String, status: String, icon: UIImage?) {
        
        guard let call = call as? CallLog else { return ("", "", UIImage()) }
        
        if call.type == .audioVideo {
            call.type = .video
        }
        
        switch call.status {
        case .initiated where call.type == .audio && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "OUTGOING_AUDIO_CALL".localize(),
                "OUTGOING_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.successColor, renderingMode: .alwaysOriginal)
            )
            
        case .initiated where call.type == .audio && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "INCOMING_AUDIO_CALL".localize(),
                "INCOMING_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .initiated where call.type == .video  && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "INCOMING_VIDEO_CALL".localize(),
                "INCOMING_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.incomingCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .initiated where call.type == .video && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "OUTGOING_VIDEO_CALL".localize(),
                "OUTGOING_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.successColor, renderingMode: .alwaysOriginal)
            )
            
        case .unanswered where call.type == .audio  && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "UNANSWERED_AUDIO_CALL".localize(),
                "UNANSWERED_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .unanswered where call.type == .audio  && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "MISSED_AUDIO_CALL".localize(),
                "MISSED_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .unanswered where call.type == .video   && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "UNANSWERED_VIDEO_CALL".localize(),
                "UNANSWERED_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .unanswered where call.type == .video  && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "MISSED_VIDEO_CALL".localize(),
                "MISSED_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .cancelled where call.type == .audio && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "CANCELLED_AUDIO_CALL".localize(),
                "CANCELLED_AUDIO_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .cancelled where call.type == .audio && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "MISSED_AUDIO_CALL".localize(),
                "MISSED_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .cancelled where call.type == .video && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "CANCELLED_VIDEO_CALL".localize(),
                "CANCELLED_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .cancelled where call.type == .video && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "MISSED_VIDEO_CALL".localize(),
                "MISSED_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .rejected where call.type == .audio && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "CANCELLED_AUDIO_CALL".localize(),
                "CANCELLED_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .rejected where call.type == .audio && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "REJECTED_AUDIO_CALL".localize(),
                "REJECTED_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .rejected where call.type == .video && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "CANCELLED_VIDEO_CALL".localize(),
                "CANCELLED_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .rejected where call.type == .video && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "REJECTED_VIDEO_CALL".localize(),
                "REJECTED_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .ongoing where call.type == .audio && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "OUTGOING_AUDIO_CALL".localize(),
                "OUTGOING_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.successColor, renderingMode: .alwaysOriginal)
            )
            
        case .ongoing where call.type == .audio && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "OUTGOING_AUDIO_CALL".localize(),
                "OUTGOING_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.successColor, renderingMode: .alwaysOriginal)
            )
            
        case .ongoing where call.type == .video && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "OUTGOING_VIDEO_CALL".localize(),
                "OUTGOING_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.successColor, renderingMode: .alwaysOriginal)
            )
            
        case .ongoing where call.type == .video && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "OUTGOING_VIDEO_CALL".localize(),
                "OUTGOING_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.successColor, renderingMode: .alwaysOriginal)
            )
            
        case .ended where call.type == .audio && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "OUTGOING_AUDIO_CALL".localize(),
                "OUTGOING_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.successColor, renderingMode: .alwaysOriginal)
            )
            
        case .ended where call.type == .audio && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "INCOMING_AUDIO_CALL".localize(),
                "INCOMING_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.incomingCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .ended where call.type == .video && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "OUTGOING_VIDEO_CALL".localize(),
                "OUTGOING_CALL".localize(),
                outgoingCallIcon?.withTintColor(style?.outgoingCallIconTint ?? CometChatTheme.successColor, renderingMode: .alwaysOriginal)
            )
            
        case .ended where call.type == .video && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "INCOMING_VIDEO_CALL".localize(),
                "INCOMING_CALL".localize(),
                incomingCallIcon?.withTintColor(style?.incomingCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .busy where call.type == .video && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "UNANSWERED_VIDEO_CALL".localize(),
                "UNANSWERED_CALL".localize(),
                missedCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
        
        case .busy where call.type == .audio  && (call.initiator as? CallUser)?.uid == CometChat.getLoggedInUser()?.uid:
            return (
                "UNANSWERED_AUDIO_CALL".localize(),
                "UNANSWERED_CALL".localize(),
                missedCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .busy where call.type == .video  && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "MISSED_VIDEO_CALL".localize(),
                "MISSED_CALL".localize(),
                missedCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .busy where call.type == .audio  && (call.initiator as? CallUser)?.uid != CometChat.getLoggedInUser()?.uid:
            return (
                "MISSED_AUDIO_CALL".localize(),
                "MISSED_CALL".localize(),
                missedCallIcon?.withTintColor(style?.missedCallIconTint ?? CometChatTheme.errorColor, renderingMode: .alwaysOriginal)
            )
            
        case .rejected: break
        case .busy: break
        case .cancelled: break
        case .ended: break
        case .initiated: break
        case .ongoing: break
        case .unanswered: break
        @unknown default: break
        }
        return ("", "", UIImage())
    }
    
    public func convertTimeStampToCallDate(timestamp: Int) -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"

        let formattedDate = formatter.string(from: date)
        return formattedDate
    }
    
}

#endif


