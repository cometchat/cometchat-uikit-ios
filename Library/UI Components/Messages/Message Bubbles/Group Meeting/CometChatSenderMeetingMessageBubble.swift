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
            
            if let data = meetingMessage.customData, let type = data["callType"] as? String{
                if type == "audio" {
                    title.text = "YOU_INITIATED_GROUP_AUDIO_CALL".localized()
                    icon.image = UIImage(named: "calls.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }else{
                    title.text = "YOU_INITIATED_GROUP_VIDEO_CALL".localized()
                    icon.image = UIImage(named: "missedVideo.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
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
                receipt.image = UIImage(named: "read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(meetingMessage?.readAt ?? 0))
            }else if meetingMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "delivered", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(meetingMessage?.deliveredAt ?? 0))
            }else if meetingMessage.sentAt > 0 {
                receipt.image = UIImage(named: "sent", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(meetingMessage?.sentAt ?? 0))
            }else if meetingMessage.sentAt == 0 {
                receipt.image = UIImage(named: "wait", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = "SENDING".localized()
            }
            if meetingMessage?.replyCount != 0  && UIKitSettings.threadedChats == .enabled {
                replyButton.isHidden = false
                if meetingMessage?.replyCount == 1 {
                    replyButton.setTitle("ONE_REPLY".localized(), for: .normal)
                }else{
                    if let replies = meetingMessage?.replyCount {
                        replyButton.setTitle("\(replies) replies", for: .normal)
                    }
                }
            }else{
                replyButton.isHidden = true
            }
            if UIKitSettings.showReadDeliveryReceipts == .disabled {
                receipt.isHidden = true
            }else{
                receipt.isHighlighted = false
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
