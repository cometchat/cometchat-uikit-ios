
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
                if let userName = currentMessage.sender?.name {
                    name.text = userName + ":"
                }
                self.parseProfanityFilter(forMessage: currentMessage)
                self.parseSentimentAnalysis(forMessage: currentMessage)
                receiptStack.isHidden = true
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
    
    weak var deletedMessage: BaseMessage? {
        didSet {
            // self.selectionStyle = .none
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        switch isEditing {
        case true:
            switch selected {
            case true: self.tintedView.isHidden = false
            case false: self.tintedView.isHidden = true
            }
        case false: break
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
            }
        }else{
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


