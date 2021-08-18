//  CometChatCallDetailsLogItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

class CometChatCallDetailsLogItem: UITableViewCell {
    
    
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
                    self.callStatus.text = "OUTGOING_AUDIO_CALL".localized()
                    self.callStatusIcon.image = UIImage(named: "outgoing-audio-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    
                case .initiated where call.callType == .audio && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    
                    self.callStatus.text = "INCOMING_AUDIO_CALL".localized()
                    self.callStatusIcon.image = UIImage(named: "incoming-audio-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    
                    
                case .initiated where call.callType == .video  && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    
                    self.callStatus.text = "INCOMING_VIDEO_CALL".localized()
                    self.callStatusIcon.image = UIImage(named: "incoming-video-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    
                    
                case .initiated where call.callType == .video && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                    // This case satisfies the condition where loggedIn user sends  audio call in a group.
                    self.callStatus.text = "OUTGOING_VIDEO_CALL".localized()
                    self.callStatusIcon.image = UIImage(named: "outgoing-video-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    
                    
                case .unanswered where call.callType == .audio  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                    self.callStatus.text = "UNANSWERED_AUDIO_CALL".localized()
                    self.callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    
                case .unanswered where call.callType == .audio  && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    
                    self.callStatus.text = "MISSED_CALL".localized()
                    self.callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    
                case .unanswered where call.callType == .video   && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                    self.callStatus.text = "UNANSWERED_VIDEO_CALL".localized()
                    self.callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    
                case .unanswered where call.callType == .video  && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
    
                    self.callStatus.text = "MISSED_CALL".localized()
                    self.callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
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
