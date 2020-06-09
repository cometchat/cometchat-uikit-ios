//  CometChatCallDetailLogView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

class CometChatCallDetailLogView: UITableViewCell {
    
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var callStatusIcon: UIImageView!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var duration: UILabel!
    
    
    // MARK: - Declaration of Variables
       

    var call: BaseMessage! {
        didSet {
            
            if let call = call as? Call {
                time.text =  String().setMessageDateHeader(time: Int(call.initiatedAt))
                duration.text = String().setCallsTime(time: Int(call.initiatedAt))
                switch call.callStatus  {
                case .initiated where call.callType == .audio && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    self.callStatus.text = "Outgoing Audio Call"
                    self.callStatusIcon.image = #imageLiteral(resourceName: "outgoingAudio")
                    
                case .initiated where call.callType == .audio && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    
                    self.callStatus.text = "Incoming Audio Call"
                    self.callStatusIcon.image = #imageLiteral(resourceName: "incomingAudio")
                    
                    
                case .initiated where call.callType == .video  && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    
                    self.callStatus.text = "Incoming Video Call"
                    self.callStatusIcon.image = #imageLiteral(resourceName: "incomingVideo")
                    
                    
                case .initiated where call.callType == .video && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                    // This case satisfies the condition where loggedIn user sends  audio call in a group.
                    self.callStatus.text = "Outgoing Video Call"
                    self.callStatusIcon.image = #imageLiteral(resourceName: "outgoingVideo")
                    
                    
                case .unanswered where call.callType == .audio  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                    self.callStatus.text = "Unanswered Audio Call"
                    self.callStatusIcon.image = #imageLiteral(resourceName: "missedAudio")
                    
                case .unanswered where call.callType == .audio  && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    
                    self.callStatus.text = "Missed Audio Call"
                    self.callStatusIcon.image = #imageLiteral(resourceName: "missedAudio")
                    
                case .unanswered where call.callType == .video   && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                    self.callStatus.text = "Unanswered Video Call"
                    self.callStatusIcon.image = #imageLiteral(resourceName: "missedVideo")
                    
                case .unanswered where call.callType == .video  && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
    
                    self.callStatus.text = "Missed Video Call"
                    self.callStatusIcon.image = #imageLiteral(resourceName: "missedVideo")
                case .rejected: break
                case .busy: break
                case .cancelled: break
                case .ended: break
                case .initiated: break
                case .ongoing: break
                case .unanswered: break
                @unknown default: break
                }
                callStatusIcon.contentMode = .scaleAspectFit
            }
            
        }
    }
    
     // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
