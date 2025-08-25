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

extension CallUtils {
    
    public func configureCallLogSubtitleView(
        callData: Any,
        style: CallLogStyle,
        incomingCallIcon: UIImage? = nil,
        outgoingCallIcon: UIImage? = nil,
        missedCallIcon: UIImage? = nil,
        callDate: String?,
        dateTimeFormatter: CometChatDateTimeFormatter?
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
            if let callDate = callDate, !callDate.isEmpty{
                subtitleLabel.text = callDate
            }else{
                subtitleLabel.text = convertTimeStampToCallDate(timestamp: callData.initiatedAt, dateTimeFormatter: dateTimeFormatter)
            }
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

        guard let call = call as? CallLog else {
            return ("", "", UIImage())
        }

        let loggedInUserId = CometChat.getLoggedInUser()?.uid
        let isOutgoing = (call.initiator as? CallUser)?.uid == loggedInUserId
        let isAudio = call.type == .audio
        let isVideo = call.type == .video || call.type == .audioVideo

        let incomingIcon = incomingCallIcon?.withRenderingMode(.alwaysOriginal)
        let outgoingIcon = outgoingCallIcon?.withRenderingMode(.alwaysOriginal)
        let missedIcon = missedCallIcon?.withRenderingMode(.alwaysOriginal)

        var statusWithType = ""
        var status = ""
        var icon: UIImage?

        let successTint = style?.outgoingCallIconTint ?? CometChatTheme.successColor
        let errorTint = style?.missedCallIconTint ?? CometChatTheme.errorColor

        func tint(_ image: UIImage?, color: UIColor) -> UIImage? {
            return image?.withTintColor(color, renderingMode: .alwaysOriginal)
        }

        switch call.status {
        case .initiated, .ongoing, .ended:
            if isOutgoing {
                if isAudio {
                    statusWithType = "OUTGOING_AUDIO_CALL".localize()
                } else {
                    statusWithType = "OUTGOING_VIDEO_CALL".localize()
                }
                status = "OUTGOING_CALL".localize()
                icon = tint(outgoingIcon, color: successTint)
            } else {
                if isAudio {
                    statusWithType = "INCOMING_AUDIO_CALL".localize()
                } else {
                    statusWithType = "INCOMING_VIDEO_CALL".localize()
                }
                status = "INCOMING_CALL".localize()
                icon = tint(incomingIcon, color: successTint)
            }

        case .unanswered, .busy, .cancelled, .rejected:
            if call.status == .unanswered {
                if isAudio {
                    statusWithType = "UNANSWERED_AUDIO_CALL".localize()
                } else {
                    statusWithType = "UNANSWERED_VIDEO_CALL".localize()
                }
                status = "UNANSWERED_CALL".localize()
                icon = tint(missedIcon, color: errorTint)
            } else {
                if call.status == .rejected {
                    if isAudio {
                        statusWithType = "REJECTED_AUDIO_CALL".localize()
                    } else {
                        statusWithType = "REJECTED_VIDEO_CALL".localize()
                    }
                    status = "REJECTED_CALL".localize()
                } else {
                    if isAudio {
                        statusWithType = "MISSED_AUDIO_CALL".localize()
                    } else {
                        statusWithType = "MISSED_VIDEO_CALL".localize()
                    }
                    status = "MISSED_CALL".localize()
                }
                icon = tint(missedIcon, color: errorTint)
            }
        @unknown default:
            break
        }

        return (statusWithType, status, icon ?? UIImage())
    }
    
    public func convertTimeStampToCallDate(timestamp: Int, dateTimeFormatter: CometChatDateTimeFormatter?) -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let dateTimeFormatterUtils = DateTimeFormatterUtils()
        
        if let formatter = dateTimeFormatterUtils.getFormattedDateFromClosures(timeStamp: timestamp, dateTimeFormatter: dateTimeFormatter){
            return formatter
        }else{
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM, h:mm a"
            formatter.amSymbol = "am"
            formatter.pmSymbol = "pm"
            formatter.locale = Locale(identifier: CometChatLocalize.getLocale())

            let formattedDate = formatter.string(from: date)
            return formattedDate
        }
    }
    
}

#endif


