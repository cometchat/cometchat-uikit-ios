//  CometChatReceiverFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatReceiverMeetingMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var meetingTitle: UILabel!
    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var heightReactions: NSLayoutConstraint!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    var collaborativeURL : String?
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
    var collaborativeType: WebViewType = .whiteboard
    weak var meetingDelegate: MeetingDelegate?
    var meetingMessage: CustomMessage? {
        didSet {
            if let meetingMessage = meetingMessage {
            self.reactionView.parseMessageReactionForMessage(message: meetingMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            receiptStack.isHidden = true
            if meetingMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            joinButton.setTitle("JOIN".localized(), for: .normal)
            joinButton.tintColor = UIKitSettings.primaryColor
            if let userName = meetingMessage.sender?.name {
                name.text = userName + ":"
                
                
                if let data = meetingMessage.customData, let type = data["callType"] as? String{
                    if type == "audio" {
                        title.text = "\(userName) " + "HAS_INITIATED_GROUP_AUDIO_CALL".localized()
                        if #available(iOS 13.0, *) {
                            icon.image = UIImage(named: "messages-video-call.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.systemGray)
                        } else {
                            icon.image = UIImage(named: "messages-video-call.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        }
                    }else{
                        title.text = "\(userName) " + "HAS_INITIATED_GROUP_VIDEO_CALL".localized()
                        if #available(iOS 13.0, *) {
                            icon.image = UIImage(named: "messages-video-call.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.systemGray)
                        } else {
                            icon.image = UIImage(named: "messages-video-call.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        }
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
            }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
            
            timeStamp.text = String().setMessageTime(time: Int(meetingMessage.sentAt ?? 0))
            
                if let avatarURL = meetingMessage.sender?.avatar  {
                    avatar.set(image: avatarURL, with: meetingMessage.sender?.name ?? "")
                }else{
                    avatar.set(image: "", with: meetingMessage.sender?.name ?? "")
                }
            
                FeatureRestriction.isThreadedMessagesEnabled { (success) in
                    switch success {
                    case .enabled where self.meetingMessage?.replyCount != 0 :
                        self.replybutton.isHidden = false
                        if self.meetingMessage?.replyCount == 1 {
                            self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                        }else{
                            if let replies = self.meetingMessage?.replyCount as? Int {
                                self.replybutton.setTitle("\(replies) replies", for: .normal)
                            }
                        }
                    case .disabled, .enabled : self.replybutton.isHidden = true
                    }
                }
            replybutton.tintColor = UIKitSettings.primaryColor
            calculateHeightForReactions(reactionView: reactionView, heightReactions: heightReactions)
            }
          
        }
    }
    
   
    
    // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if let message = meetingMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
    }
    
    @IBAction func didJoinButtonPressed(_ sender: Any) {
        if let data = meetingMessage?.customData, let type = data["callType"] as? String, let sessionID = data["sessionID"] as? String {
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
            messageView.backgroundColor =  .lightGray
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if #available(iOS 13.0, *) {
            
        } else {
            messageView.backgroundColor =  .lightGray
        }
    }
    
    override func prepareForReuse() {
        reactionView.reactions.removeAll()
    }

}

/*  ----------------------------------------------------------------------------------------- */
