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
    
    func getDefaultTemplate(user: User? , group: Group?, controller: UIViewController, isFromCallDetail: Bool? = false) -> [CometChatDetailsTemplate] {
        var templates = [CometChatDetailsTemplate]()
        if let user = user {
            #if canImport(CometChatCallsSDK)
            let callingButton = CometChatCallButtons(width: 0, height: 0)
            callingButton.set(controller: controller)
            callingButton.set(voiceCallIconText: "CALL".localize())
            callingButton.set(videoCallIconText: "VIDEO".localize())

            callingButton.set(user: user)
            
            let callButtonTemplate = CometChatDetailsTemplate(id: "CallButtons", title: "", titleFont: nil, titleColor: nil, itemSeparatorColor: nil, hideItemSeparator: nil, customView: callingButton, options: nil)
            templates.append(callButtonTemplate)
            #endif
            
            let callDurationView = CallDuration()
            callDurationView.set(user: user)
            let callDurationTemplate = CometChatDetailsTemplate(id: "CallDuration", title: "", titleFont: nil, titleColor: nil, itemSeparatorColor: nil, hideItemSeparator: nil, customView: callDurationView, options: nil)
            
            templates.append(callDurationTemplate)
        }
        
        if let group = group {
            #if canImport(CometChatCallsSDK)
            let callingButton = CometChatCallButtons(width: 0, height: 0)
            callingButton.set(controller: controller)
            callingButton.set(videoCallIconText: "VIDEO".localize())
            callingButton.check(isFromCallDetail: isFromCallDetail ?? false)
            callingButton.set(group: group)
            let callButtonTemplate = CometChatDetailsTemplate(id: "CallButtons", title: "", titleFont: nil, titleColor: nil, itemSeparatorColor: nil, hideItemSeparator: nil, customView: callingButton, options: nil)
            templates.append(callButtonTemplate)
            #endif
            
            let callDurationView = CallDuration()
            callDurationView.set(group: group)
            let callDurationTemplate = CometChatDetailsTemplate(id: "CallDuration", title: "", titleFont: nil, titleColor: nil, itemSeparatorColor: nil, hideItemSeparator: nil, customView: callDurationView, options: nil)
            
            templates.append(callDurationTemplate)
        }
      
        
        return templates
    }
  
}
