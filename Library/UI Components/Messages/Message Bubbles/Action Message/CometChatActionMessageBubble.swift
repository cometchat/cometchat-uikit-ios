//  CometChatActionMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatActionMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var message: UILabel!
    
    
    var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
        }
    }
    
    var actionMessage: ActionMessage? {
        didSet {
            
            if let action = actionMessage?.action {
                switch action {
                case .joined:
                    if let user = (actionMessage?.actionBy as? CometChatPro.User)?.name {
                        message.text = user + " " + "JOINED".localized()
                    }
                case .left:
                    if let user = (actionMessage?.actionBy as? CometChatPro.User)?.name {
                        message.text = user + " " + "LEFT".localized()
                    }
                case .kicked:
                    if let actionBy = (actionMessage?.actionBy as? CometChatPro.User)?.name,let actionOn = (actionMessage?.actionOn as? CometChatPro.User)?.name  {
                        message.text = actionBy + " " + "KICKED".localized() +  " " + actionOn
                    }
                case .banned:
                    if let actionBy = (actionMessage?.actionBy as? CometChatPro.User)?.name,let actionOn = (actionMessage?.actionOn as? CometChatPro.User)?.name  {
                        message.text = actionBy + " " + "BANNED".localized() +  " " + actionOn
                    }
                case .unbanned:
                    if let actionBy = (actionMessage?.actionBy as? CometChatPro.User)?.name,let actionOn = (actionMessage?.actionOn as? CometChatPro.User)?.name  {
                        message.text = actionBy + " " + "UNBANNED".localized() +  " " + actionOn
                    }
                case .scopeChanged:
                    if let actionBy = (actionMessage?.actionBy as? CometChatPro.User)?.name,let actionOn = (actionMessage?.actionOn as? CometChatPro.User)?.name, let scope = actionMessage?.newScope  {
                        
                        switch scope {
                        
                        case .admin:
                            let admin = "ADMIN".localized()
                            message.text = actionBy + " " + "MADE".localized() + " \(actionOn) \(admin)"
                        case .moderator:
                            let moderator = "MODERATOR".localized()
                            message.text = actionBy + " " + "MADE".localized() + " \(actionOn) \(moderator)"
                        case .participant:
                            let participant = "PARTICIPANT".localized()
                            message.text = actionBy + " " + "MADE".localized() + " \(actionOn) \(participant)"
                        @unknown default:
                            break
                        }
                        
                    }
                case .messageEdited:
                    message.text = actionMessage?.message
                case .messageDeleted:
                    message.text = actionMessage?.message
                case .added:
                    if let actionBy = (actionMessage?.actionBy as? CometChatPro.User)?.name,let actionOn = (actionMessage?.actionOn as? CometChatPro.User)?.name  {
                        message.text = actionBy + " " + "ADDED".localized() +  " " + actionOn
                    }
                @unknown default:
                    message.text = "ACTION_MESSAGE".localized()
                }
            }
        }
    }
        
    var call: CometChatPro.Call? {
           didSet {
            if let call = call {
                
                message.font =  UIFont.systemFont(ofSize: 15, weight: .bold)
                   switch call.callStatus  {
                   case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    message.text = "OUTGOING_AUDIO_CALL".localized()
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                   case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                       
                    message.text = "INCOMING_AUDIO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:

                    message.text = "INCOMING_AUDIO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    
                    message.text = "OUTGOING_AUDIO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
            
                   case .initiated where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:

                    message.text = "OUTGOING_VIDEO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .video && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:

                    message.text = "INCOMING_VIDEO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    
                    message.text = "OUTGOING_VIDEO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .video && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:

                    message.text = "INCOMING_VIDEO_CALL".localized()
                      
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .unanswered where call.callType == .audio && call.receiverType == .user  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:

                    message.text = "UNANSWERED_AUDIO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                
                    message.text = "MISSED_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .audio && call.receiverType == .group  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                      
                    message.text = "UNANSWERED_AUDIO_CALL".localized()
                     
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                      
                      message.text = "MISSED_CALL".localized()
                     
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                      
                    message.text = "UNANSWERED_VIDEO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .video && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                     
                    message.text = "MISSED_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                       
                    message.text = "UNANSWERED_VIDEO_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .video && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                     
                    message.text = "MISSED_CALL".localized()
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                   case .rejected: message.text = "REJECTED_CALL".localized()
                   case .busy: message.text = "CALL_BUSY".localized()
                   case .cancelled: message.text = "CALL_CANCELLED".localized()
                   case .ended:  message.text = "CALL_ENDED".localized()
                   case .initiated: message.text =  "CALL_INITIATED".localized()
                   case .ongoing: message.text = "CALL_OUTGOING".localized()
                   case .unanswered:  message.text = "CALL_UNANSWERED".localized()
                   @unknown default: message.text = "CALL_CANCELLED".localized()
                   }
               }else{
                message.text = "ACTION_MESSAGE".localized()
            }
           }
       }
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        if #available(iOS 13.0, *) {
            selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        // Configure the view for the selected state
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
