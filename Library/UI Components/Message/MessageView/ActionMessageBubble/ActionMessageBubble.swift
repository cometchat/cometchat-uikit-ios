//  ActionMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class ActionMessageBubble: UITableViewCell {
    
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
    
    var call: Call? {
           didSet {
            if let call = call {
                
                message.font =  UIFont.systemFont(ofSize: 15, weight: .bold)
                   switch call.callStatus  {
                   case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                       message.text = "Outgoing Audio Call"
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                   case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                       
                       message.text = "Incoming Audio Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid != LoggedInUser.uid:

                       message.text = "Incoming Audio Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                       message.text = "Outgoing Audio Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
            
                   case .initiated where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:

                       message.text = "Outgoing Video Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .video && call.receiverType == .user && (call.callInitiator as? User)?.uid != LoggedInUser.uid:

                       message.text = "Incoming Video Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                       message.text = "Outgoing Video Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .initiated where call.callType == .video && call.receiverType == .group && (call.callInitiator as? User)?.uid != LoggedInUser.uid:

                       message.text = "Incoming Video Call"
                      
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       
                   case .unanswered where call.callType == .audio && call.receiverType == .user  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:

                       message.text = "Unanswered Audio Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                
                       message.text = "Missed Audio Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .audio && call.receiverType == .group  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                      
                       message.text = "Unanswered Audio Call"
                     
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                      
                       message.text = "Missed Audio Call"
                     
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                      
                       message.text = "Unanswered Video Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .video && call.receiverType == .user && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                     
                       message.text = "Missed Video Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                       
                       message.text = "Unanswered Video Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                       
                   case .unanswered where call.callType == .video && call.receiverType == .group && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                     
                       message.text = "Missed Video Call"
                       
                       if #available(iOS 13.0, *) {
                           message.textColor = .systemRed
                       } else {
                           message.textColor = .red
                       }
                   case .rejected: message.text = "Call Rejected"
                   case .busy: message.text = "Call Busy"
                   case .cancelled: message.text = "Call Cancelled"
                   case .ended:  message.text = "Call Ended"
                   case .initiated: message.text =  "Call Initiated"
                   case .ongoing: message.text = "Call Ongoing"
                   case .unanswered:  message.text = "Call Unanswered"
                   @unknown default: message.text = "Call Cancelled"
                   }
               }else{
                message.text = "Action Message"
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
