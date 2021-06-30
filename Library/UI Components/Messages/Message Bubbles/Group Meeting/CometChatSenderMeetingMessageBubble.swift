//  CometChatSenderFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


protocol  MeetingDelegate: NSObject {
    
    func didJoinPressed(forSessionID: String, type: CometChatPro.CometChat.CallType)
}

/*  ----------------------------------------------------------------------------------------- */

class CometChatSenderMeetingMessageBubble: UITableViewCell {

    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var meetingTitle: UILabel!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    
     // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    weak var meetingDelegate: MeetingDelegate?
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
    
    var meetingMessage: CustomMessage! {
        didSet {
            receiptStack.isHidden = true
           
            joinButton.setTitle("JOIN".localized(), for: .normal)
            joinButton.tintColor = UIKitSettings.primaryColor
            if let data = meetingMessage.customData, let type = data["callType"] as? String{
                if type == "audio" {
                    title.text = "YOU_INITIATED_GROUP_AUDIO_CALL".localized()
                    icon.image = UIImage(named: "messages-video-call.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }else{
                    title.text = "YOU_INITIATED_GROUP_VIDEO_CALL".localized()
                    icon.image = UIImage(named: "messages-video-call.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
                
                if let title = data["title"] as? String {
                    meetingTitle.isHidden = false
                    seperator.isHidden = false
                    meetingTitle.text = title
                }else{
                    seperator.isHidden = true
                    meetingTitle.isHidden = true
                }
            }
            
            
            if meetingMessage.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
            }else{
                timeStamp.text = String().setMessageTime(time: meetingMessage.sentAt)
            }
            self.reactionView.parseMessageReactionForMessage(message: meetingMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if meetingMessage.readAt > 0 {
                receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(meetingMessage?.readAt ?? 0))
            }else if meetingMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = String().setMessageTime(time: Int(meetingMessage?.deliveredAt ?? 0))
            }else if meetingMessage.sentAt > 0 {
                receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = String().setMessageTime(time: Int(meetingMessage?.sentAt ?? 0))
            }else if meetingMessage.sentAt == 0 {
                receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = "SENDING".localized()
            }
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.meetingMessage.replyCount != 0 :
                    self.replyButton.isHidden = false
                    if self.meetingMessage.replyCount == 1 {
                        self.replyButton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.meetingMessage.replyCount as? Int {
                            self.replyButton.setTitle("\(replies) replies", for: .normal)
                        }
                    }
                case .disabled, .enabled : self.replyButton.isHidden = true
                }
            }
            FeatureRestriction.isDeliveryReceiptsEnabled { (success) in
                switch success {
                case .enabled: self.receipt.isHidden = false
                case .disabled: self.receipt.isHidden = true
                }
            }
            messageView.backgroundColor = UIKitSettings.primaryColor
            replyButton.tintColor = UIKitSettings.primaryColor
        }
    }
    
   
    
    // MARK: - Initialization of required Methods
    
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if let message = meetingMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
    }
    
    @IBAction func didJoinButtonPressed(_ sender: Any) {
        if let data = meetingMessage.customData, let type = data["callType"] as? String, let sessionID = data["sessionID"] as? String {
            if type == "audio" {
                meetingDelegate?.didJoinPressed(forSessionID: sessionID, type: .audio)
            }else if type == "video" {
                meetingDelegate?.didJoinPressed(forSessionID: sessionID, type: .video)
            }
        }
        
    }
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13.0, *) {
            selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if #available(iOS 13.0, *) {
            
        } else {
            messageView.backgroundColor =  UIKitSettings.primaryColor
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if #available(iOS 13.0, *) {
            
        } else {
            messageView.backgroundColor =  UIKitSettings.primaryColor
        }
    }
     
}

/*  ----------------------------------------------------------------------------------------- */
