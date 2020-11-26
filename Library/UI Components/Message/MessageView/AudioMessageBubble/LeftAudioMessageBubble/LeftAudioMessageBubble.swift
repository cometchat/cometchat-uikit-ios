//  LeftaudioMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class LeftAudioMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
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
    
    var audioMessage: MediaMessage! {
        didSet {
            
            replybutton.tintColor = UIKitSettings.primaryColor
            self.reactionView.parseMessageReactionForMessage(message: audioMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            receiptStack.isHidden = true
            if audioMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            if let userName = audioMessage.sender?.name {
                name.text = userName + ":"
            }
            
            timeStamp.text = String().setMessageTime(time: Int(audioMessage?.sentAt ?? 0))
            fileName.text = "Audio File"
            if let fileSize = audioMessage.attachment?.fileSize {
               
                size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
            }
            if let avatarURL = audioMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: audioMessage.sender?.name ?? "")
            }
            
            if audioMessage?.replyCount != 0 && UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if audioMessage?.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = audioMessage?.replyCount {
                        replybutton.setTitle("\(replies) replies", for: .normal)
                    }
                }
            }else{
                replybutton.isHidden = true
            }
        }
    }
    
    
    var audioMessageinThread: MediaMessage! {
        didSet {
            receiptStack.isHidden = true
            nameView.isHidden = false
            if let userName = audioMessageinThread.sender?.name {
                name.text = userName + ":"
            }
            self.reactionView.parseMessageReactionForMessage(message: audioMessageinThread) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            timeStamp.text = String().setMessageTime(time: Int(audioMessageinThread?.sentAt ?? 0))
            fileName.text = "Audio File"
            if let fileSize = audioMessageinThread.attachment?.fileSize {
               
                size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
            }
            if let avatarURL = audioMessageinThread.sender?.avatar  {
                avatar.set(image: avatarURL, with: audioMessageinThread.sender?.name ?? "")
            }
            
            if audioMessageinThread.readAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(audioMessageinThread?.readAt ?? 0))
            }else if audioMessageinThread.deliveredAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(audioMessageinThread?.deliveredAt ?? 0))
            }else if audioMessageinThread.sentAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(audioMessageinThread?.sentAt ?? 0))
            }else if audioMessageinThread.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                name.text = LoggedInUser.name.capitalized + ":"
            }
             nameView.isHidden = false
             replybutton.isHidden = true
            if let userName = audioMessageinThread?.sender?.name {
                name.text = userName + ":"
            }
            if let avatarURL = audioMessageinThread?.sender?.avatar  {
                avatar.set(image: avatarURL, with: audioMessageinThread?.sender?.name ?? "")
            }
        }
    }
    
    @IBAction func didReplyButtonPressed(_ sender: Any) {
           if let message = audioMessage, let indexpath = indexPath {
               CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
           }

       }
    
    // MARK: - Initialization of required Methods
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        if #available(iOS 13.0, *) {
           selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
        
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
