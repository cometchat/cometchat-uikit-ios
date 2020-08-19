
//  LeftTextMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

protocol LeftTextMessageBubbleDelegate: AnyObject {
    func didTapOnSentimentAnalysisViewForLeftBubble(indexPath: IndexPath)
}



/*  ----------------------------------------------------------------------------------------- */

class LeftTextMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageStack: UIStackView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var sentimentAnalysisView: UIView!
    @IBOutlet weak var spaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthconstraint: NSLayoutConstraint!
    
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    weak var delegate: LeftTextMessageBubbleDelegate?
    let systemLanguage = Locale.preferredLanguages.first
    unowned var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.white
        }
    }
    
    
    weak var textMessage: TextMessage? {
        didSet {
            if let currentMessage = textMessage {
                receiptStack.isHidden = true
                if let userName = currentMessage.sender?.name {
                    name.text = userName + ":"
                }
                self.parseSentimentAnalysis(forMessage: currentMessage)
                self.parseProfanityFilter(forMessage: currentMessage)
                if textMessage?.replyCount != 0 {
                    replybutton.isHidden = false
                    if textMessage?.replyCount == 1 {
                        replybutton.setTitle("1 reply", for: .normal)
                    }else{
                        if let replies = textMessage?.replyCount {
                            replybutton.setTitle("\(replies) replies", for: .normal)
                        }
                    }
                }else{
                    replybutton.isHidden = true
                }
                
                if currentMessage.receiverType == .group {
                    nameView.isHidden = false
                }else {
                    nameView.isHidden = true
                }
                if let avatarURL = currentMessage.sender?.avatar  {
                    avatar.set(image: avatarURL, with: currentMessage.sender?.name ?? "")
                }
                timeStamp.text = String().setMessageTime(time: currentMessage.sentAt)
            }
        }
    }
    
    weak var textMessageInThread: TextMessage? {
        didSet {
            if let textmessage  = textMessageInThread {
                self.receiptStack.isHidden = true
                self.parseSentimentAnalysis(forMessage: textmessage)
                self.parseProfanityFilter(forMessage: textmessage)
                if textmessage.readAt > 0 && textmessage.receiverType == .user{
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.readAt ?? 0))
                }else if textmessage.deliveredAt > 0 {
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.deliveredAt ?? 0))
                }else if textmessage.sentAt > 0 {
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.sentAt ?? 0))
                }else if textmessage.sentAt == 0 {
                    timeStamp.text = NSLocalizedString("SENDING", comment: "")
                    name.text = LoggedInUser.name.capitalized + ":"
                }
            }
            receiptStack.isHidden = true
            if #available(iOS 13.0, *) {
                message.textColor = .label
            } else {
                message.textColor = .black
            }
            nameView.isHidden = false
            replybutton.isHidden = true
            if let userName = textMessageInThread?.sender?.name {
                name.text = userName + ":"
            }
            if let avatarURL = textMessageInThread?.sender?.avatar  {
                avatar.set(image: avatarURL, with: textMessageInThread?.sender?.name ?? "")
            }
        }
    }
    
    weak var deletedMessage: BaseMessage? {
        didSet {
            // self.selectionStyle = .none
            self.replybutton.isHidden = true
            sentimentAnalysisView.isHidden = true
            spaceConstraint.constant = 0
            widthconstraint.constant = 0
            if let currentMessage = deletedMessage {
                if let userName = currentMessage.sender?.name {
                    name.text = userName + ":"
                }
                if (currentMessage.sender?.name) != nil {
                    switch currentMessage.messageType {
                    case .text:  message.text =  NSLocalizedString("THIS_MESSAGE_DELETED", comment: "")
                    case .image: message.text = NSLocalizedString("THIS_IMAGE_DELETED", comment: "")
                    case .video: message.text = NSLocalizedString("THIS_VIDEO_DELETED", comment: "")
                    case .audio: message.text =  NSLocalizedString("THIS_AUDIO_DELETED", comment: "")
                    case .file:  message.text = NSLocalizedString("THIS_FILE_DELETED", comment: "")
                    case .custom: message.text = NSLocalizedString("THIS_CUSTOM_MESSAGE_DELETED", comment: "")
                    case .groupMember: break
                    @unknown default: break }}
                receiptStack.isHidden = true
                if currentMessage.receiverType == .group {
                    nameView.isHidden = false
                }else {
                    nameView.isHidden = true
                }
                if let avatarURL = currentMessage.sender?.avatar  {
                    avatar.set(image: avatarURL, with: currentMessage.sender?.name ?? "")
                }
                timeStamp.text = String().setMessageTime(time: Int(currentMessage.sentAt))
                message.textColor = .darkGray
                message.font = UIFont (name: "SFProDisplay-RegularItalic", size: 17)
            }
        }
    }
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textMessage = nil
        deletedMessage = nil
    }
    
    @IBAction func didViewButtonPressed(_ sender: Any) {
        if let indexPAth = indexPath {
            delegate?.didTapOnSentimentAnalysisViewForLeftBubble(indexPath: indexPAth)
        }
    }
    
    
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if let message = textMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        switch selected {
        case true: self.tintedView.isHidden = false
        case false: self.tintedView.isHidden = true
        }
    }
    
    /**
     This method used to set the image for LeftTextMessageBubble class
     - Parameter image: This specifies a `URL` for  the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.cf.setImage(with: url)
    }
    
    func parseProfanityFilter(forMessage: TextMessage){
        if let metaData = textMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let profanityFilterDictionary = cometChatExtension["profanity-filter"] as? [String : Any] {
            
            if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
                
                if profanity == "yes" {
                    message.text = filteredMessage
                }else{
                    message.text = forMessage.text
                }
            }else{
                message.text = forMessage.text
            }
        }else{
            
            if forMessage.text.containsOnlyEmojis() {
                if forMessage.text.count == 1 {
                    message.font = UIFont (name: "SFProDisplay-Regular", size: 51)
                }else if forMessage.text.count == 2 {
                    message.font = UIFont (name: "SFProDisplay-Regular", size: 34)
                }else if forMessage.text.count == 3{
                    message.font = UIFont (name: "SFProDisplay-Regular", size: 25)
                }else{
                    message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
                }
                print("contains only emoji 11: \(forMessage.text.count)")
            }else{
                message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
            }
            self.message.text = forMessage.text
        }
    }
    
    private func parseSentimentAnalysis(forMessage: TextMessage){
        if let metaData = textMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let sentimentAnalysisDictionary = cometChatExtension["sentiment-analysis"] as? [String : Any] {
            if let sentiment = sentimentAnalysisDictionary["sentiment"] as? String {
                if sentiment == "negative" {
                    sentimentAnalysisView.isHidden = false
                    message.textColor = UIColor.white
                    message.font = UIFont (name: "SFProDisplay-Regular", size: 15)
                    message.text = NSLocalizedString("MAY_CONTAIN_NEGATIVE_SENTIMENT", comment: "")
                    spaceConstraint.constant = 10
                    widthconstraint.constant = 45
                }else{
                    if #available(iOS 13.0, *) {
                        message.textColor = .label
                    } else {
                        message.textColor = .black
                    }
                    message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
                    sentimentAnalysisView.isHidden = true
                    spaceConstraint.constant = 0
                    widthconstraint.constant = 0
                }
            }
        }else{
            if #available(iOS 13.0, *) {
                message.textColor = .label
            } else {
                message.textColor = .black
            }
            message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
            sentimentAnalysisView.isHidden = true
            spaceConstraint.constant = 0
            widthconstraint.constant = 0
        }
    }
    
}


/*  ----------------------------------------------------------------------------------------- */


