//
//  CometChatFileBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro

protocol PollsDelegate: NSObject {
    
    func voteForPoll(pollID: String, with option: String, cell: UITableViewCell)
    func didLongPressedOnPollMessage(message: CustomMessage,cell: UITableViewCell)
}

class CometChatPollsBubble: UITableViewCell {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var receiptStack: UIStackView!

    @IBOutlet weak var optionStack: UIStackView!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var option1: UIView!
    @IBOutlet weak var option2: UIView!
    @IBOutlet weak var option3: UIView!
    @IBOutlet weak var option4: UIView!
    @IBOutlet weak var option5: UIView!
    @IBOutlet weak var votes: UILabel!
    
    @IBOutlet weak var option1Tick: UIImageView!
    @IBOutlet weak var option2Tick: UIImageView!
    @IBOutlet weak var option3Tick: UIImageView!
    @IBOutlet weak var option4Tick: UIImageView!
    @IBOutlet weak var option5Tick: UIImageView!
    
    @IBOutlet weak var option1Text: UILabel!
    @IBOutlet weak var option2Text: UILabel!
    @IBOutlet weak var option3Text: UILabel!
    @IBOutlet weak var option4Text: UILabel!
    @IBOutlet weak var option5Text: UILabel!
    
    @IBOutlet weak var option1Count: UILabel!
    @IBOutlet weak var option2Count: UILabel!
    @IBOutlet weak var option3Count: UILabel!
    @IBOutlet weak var option4Count: UILabel!
    @IBOutlet weak var option5Count: UILabel!
    
    
    var pollID: String?
    
    var bubbleType: BubbleType = CometChatThemeOld.messageList.bubbleType
    
    weak var pollDelegate: PollsDelegate?
    
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

    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatPollsBubble {
        switch corner.corner {
        case .leftTop:
            self.background.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightTop:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .leftBottom:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightBottom:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner], radius: corner.radius)
        case .none:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        }
        self.background.clipsToBounds = true
        return self
    }
    
  
    
    @discardableResult
    public func set(backgroundColor: [Any]?) ->  CometChatPollsBubble {
        if let backgroundColors = backgroundColor as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: backgroundColor)
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func set(title: String) -> CometChatPollsBubble {
        self.question.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatPollsBubble {
        self.question.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatPollsBubble {
        self.question.textColor = titleColor
        return self
    }
    
    
    @discardableResult
    @objc func set(borderColor : UIColor) -> CometChatPollsBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatPollsBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatPollsBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatPollsBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatPollsBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatPollsBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatPollsBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatPollsBubble {
        switch  bubbleType {
        case .standard:
            self.topTime.isHidden = true
            self.time.isHidden = false
            self.topTime = time
            self.time = time
        case .leftAligned:
            self.topTime.isHidden = false
            self.time.isHidden = true
            self.topTime = time
            self.time = time
        }
        return self
    }
    
    @discardableResult
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatPollsBubble {
        switch messageAlignment {
        case .left:
            name.isHidden = false
            alightmentStack.alignment = .leading
            spacer.isHidden = false
            avatar.isHidden = false
            receipt.isHidden = true
            leadingReplyButton.isHidden = true
            trailingReplyButton.isHidden = true
            
        case .right:
            alightmentStack.alignment = .trailing
            spacer.isHidden = true
            avatar.isHidden = true
            name.isHidden = true
            receipt.isHidden = false
            leadingReplyButton.isHidden = true
            trailingReplyButton.isHidden = true
        }
        return self
    }
    
    @discardableResult
    @objc public func set(messageObject: BaseMessage) -> CometChatPollsBubble {
        self.pollsMessage = messageObject
        return self
    }
    
    @objc fileprivate func enable(tap: Bool) {
        if tap == true {
            let tapOnOption1 = UITapGestureRecognizer(target: self, action: #selector(self.voteForOption1(tapGestureRecognizer:)))
            self.option1.isUserInteractionEnabled = true
            self.option1.addGestureRecognizer(tapOnOption1)
            
            let tapOnOption2 = UITapGestureRecognizer(target: self, action: #selector(self.voteForOption2(tapGestureRecognizer:)))
            self.option2.isUserInteractionEnabled = true
            self.option2.addGestureRecognizer(tapOnOption2)
            
            let tapOnOption3 = UITapGestureRecognizer(target: self, action: #selector(self.voteForOption3(tapGestureRecognizer:)))
            self.option3.isUserInteractionEnabled = true
            self.option3.addGestureRecognizer(tapOnOption3)
            
            let tapOnOption4 = UITapGestureRecognizer(target: self, action: #selector(self.voteForOption4(tapGestureRecognizer:)))
            self.option4.isUserInteractionEnabled = true
            self.option4.addGestureRecognizer(tapOnOption4)
            
            let tapOnOption5 = UITapGestureRecognizer(target: self, action: #selector(self.voteForOption5(tapGestureRecognizer:)))
            self.option5.isUserInteractionEnabled = true
            self.option5.addGestureRecognizer(tapOnOption5)
        }
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = pollsMessage {
            if message.sender?.uid == CometChatMessages.loggedInUser?.uid ?? "" {
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    private func enableLongPress(bool: Bool) {
        if bool == true {
            let longPressOnMessage = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            background.addGestureRecognizer(longPressOnMessage)
        }
    }
    
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            if let pollsMessage = pollsMessage as? CustomMessage {
                pollDelegate?.didLongPressedOnPollMessage(message: pollsMessage, cell: self)
            }
        }
    }
    
    
    var pollsMessage: BaseMessage? {
        didSet {
            if let pollsMessage = pollsMessage as? CustomMessage {
                self.parsePolls(forMessage: pollsMessage)
                self.set(borderColor: .clear)
                self.set(borderWidth: 1.0)
                self.set(userName: pollsMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: pollsMessage))
                self.topTime.set(time: pollsMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: pollsMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: pollsMessage.sender?.avatar ?? "", with: pollsMessage.sender?.name ?? ""))
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(corner: CometChatThemeOld.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.rightBubbleBackgroundColor)
                        self.set(titleColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                    }
                }
                self.enable(tap: true)
                self.enableLongPress(bool: true)
            }
        }
    }

    @objc func voteForOption1(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let pollId = pollID {
            pollDelegate?.voteForPoll(pollID: pollId, with: "1", cell: self)
        }
    }
    
    @objc func voteForOption2(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let pollId = pollID {
            pollDelegate?.voteForPoll(pollID: pollId, with: "2", cell: self)
        }
    }
    
    @objc func voteForOption3(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let pollId = pollID {
            pollDelegate?.voteForPoll(pollID: pollId, with: "3", cell: self)
        }
    }
    
    @objc func voteForOption4(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let pollId = pollID {
            pollDelegate?.voteForPoll(pollID: pollId, with: "4", cell: self)
        }
    }
    
    @objc func voteForOption5(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let pollId = pollID {
            pollDelegate?.voteForPoll(pollID: pollId, with: "5", cell: self)
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
  
    private func parsePolls(forMessage: CustomMessage){
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let pollsDictionary = cometChatExtension["polls"] as? [String : Any] {
            if let pollID = pollsDictionary["id"] as? String {
                self.pollID = pollID
            }
            
            if let currentQuestion = pollsDictionary["question"] as? String {
                self.question.text = currentQuestion
            }
    
            if let results = pollsDictionary["results"] as? [String:Any], let options = results["options"] as? [String:Any], let total = results["total"] as? Int {
                
               
                if total == 0 {
                    votes.isHidden = true
                    votes.text = ""
                }else if total == 1{
                    votes.isHidden = false
                    votes.text = "1 Vote"
                }else{
                    votes.isHidden = false
                    votes.text = "\(total) Votes"
                }
                
                    switch options.count {
                    case 1:
                        option1.isHidden = false
                        if let option1Dictionary = options["1"] as? [String:Any], let count = option1Dictionary["count"] as? Int, let text = option1Dictionary["text"] as? String {
                            option1Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option1Count.text = "\(countValue)%"
                            if let voter = option1Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option1Tick.isHidden = false
                                }else{
                                    option1Tick.isHidden = true
                                }
                            }else{
                                option1Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option1.backgroundColor = .systemBackground
                                } else {
                                    option1.backgroundColor = .white
                                }
                                option1Count.isHidden = true
                            }else{
                                option1.backgroundColor = .lightText
                                option1Count.isHidden = false
                            }
                        }
                    case 2:
                        option1.isHidden = false
                        if let option1Dictionary = options["1"] as? [String:Any], let count = option1Dictionary["count"] as? Int, let text = option1Dictionary["text"] as? String {
                            option1Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option1Count.text = "\(countValue)%"
                            if let voter = option1Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option1Tick.isHidden = false
                                }else{
                                    option1Tick.isHidden = true
                                }
                            }else{
                                option1Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option1.backgroundColor = .systemBackground
                                } else {
                                    option1.backgroundColor = .white
                                }
                                option1Count.isHidden = true
                            }else{
                                option1.backgroundColor = .lightText
                                option1Count.isHidden = false
                            }
                        }
                        option2.isHidden = false
                        if let option2Dictionary = options["2"] as? [String:Any], let count = option2Dictionary["count"] as? Int, let text = option2Dictionary["text"] as? String {
                            option2Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option2Count.text = "\(countValue)%"
                            if let voter = option2Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option2Tick.isHidden = false
                                }else{
                                    option2Tick.isHidden = true
                                }
                            }else{
                                option2Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option2.backgroundColor = .systemBackground
                                } else {
                                    option2.backgroundColor = .white
                                }
                                option2Count.isHidden = true
                            }else{
                                option2.backgroundColor = .lightText
                                option2Count.isHidden = false
                            }
                        }
                        
                    case 3:
                        option1.isHidden = false
                        if let option1Dictionary = options["1"] as? [String:Any], let count = option1Dictionary["count"] as? Int, let text = option1Dictionary["text"] as? String {
                            option1Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option1Count.text = "\(countValue)%"
                            if let voter = option1Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option1Tick.isHidden = false
                                }else{
                                    option1Tick.isHidden = true
                                }
                            }else{
                                option1Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option1.backgroundColor = .systemBackground
                                } else {
                                    option1.backgroundColor = .white
                                }
                                option1Count.isHidden = true
                            }else{
                                option1.backgroundColor = .lightText
                                option1Count.isHidden = false
                            }
                        }
                        option2.isHidden = false
                        if let option2Dictionary = options["2"] as? [String:Any], let count = option2Dictionary["count"] as? Int, let text = option2Dictionary["text"] as? String {
                            option2Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option2Count.text = "\(countValue)%"
                            if let voter = option2Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option2Tick.isHidden = false
                                }else{
                                    option2Tick.isHidden = true
                                }
                            }else{
                                option2Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option2.backgroundColor = .systemBackground
                                } else {
                                    option2.backgroundColor = .white
                                }
                                option2Count.isHidden = true
                            }else{
                                option2.backgroundColor = .lightText
                                option2Count.isHidden = false
                            }
                        }
                        option3.isHidden = false
                        if let option3Dictionary = options["3"] as? [String:Any], let count = option3Dictionary["count"] as? Int, let text = option3Dictionary["text"] as? String {
                            option3Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option3Count.text = "\(countValue)%"
                            if let voter = option3Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option3Tick.isHidden = false
                                }else{
                                    option3Tick.isHidden = true
                                }
                            }else{
                                option3Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option3.backgroundColor = .systemBackground
                                } else {
                                    option3.backgroundColor = .white
                                }
                                option3Count.isHidden = true
                            }else{
                                option3.backgroundColor = .lightText
                                option3Count.isHidden = false
                            }
                        }
                    case 4:
                        option1.isHidden = false
                        if let option1Dictionary = options["1"] as? [String:Any], let count = option1Dictionary["count"] as? Int, let text = option1Dictionary["text"] as? String {
                            option1Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option1Count.text = "\(countValue)%"
                            if let voter = option1Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option1Tick.isHidden = false
                                }else{
                                    option1Tick.isHidden = true
                                }
                            }else{
                                option1Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option1.backgroundColor = .systemBackground
                                } else {
                                    option1.backgroundColor = .white
                                }
                                option1Count.isHidden = true
                            }else{
                                option1.backgroundColor = .lightText
                                option1Count.isHidden = false
                            }
                        }
                        option2.isHidden = false
                        if let option2Dictionary = options["2"] as? [String:Any], let count = option2Dictionary["count"] as? Int, let text = option2Dictionary["text"] as? String {
                            option2Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option2Count.text = "\(countValue)%"
                            if let voter = option2Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option2Tick.isHidden = false
                                }else{
                                    option2Tick.isHidden = true
                                }
                            }else{
                                option2Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option2.backgroundColor = .systemBackground
                                } else {
                                    option2.backgroundColor = .white
                                }
                                option2Count.isHidden = true
                            }else{
                                option2.backgroundColor = .lightText
                                option2Count.isHidden = false
                            }
                        }
                        option3.isHidden = false
                        if let option3Dictionary = options["3"] as? [String:Any], let count = option3Dictionary["count"] as? Int, let text = option3Dictionary["text"] as? String {
                            option3Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option3Count.text = "\(countValue)%"
                            if let voter = option3Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option3Tick.isHidden = false
                                }else{
                                    option3Tick.isHidden = true
                                }
                            }else{
                                option3Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option3.backgroundColor = .systemBackground
                                } else {
                                    option3.backgroundColor = .white
                                }
                                option3Count.isHidden = true
                            }else{
                                option3.backgroundColor = .lightText
                                option3Count.isHidden = false
                            }
                        }
                        option4.isHidden = false
                        if let option4Dictionary = options["4"] as? [String:Any], let count = option4Dictionary["count"] as? Int, let text = option4Dictionary["text"] as? String {
                            option4Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option4Count.text = "\(countValue)%"
                            if let voter = option4Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option4Tick.isHidden = false
                                }else{
                                    option4Tick.isHidden = true
                                }
                            }else{
                                option4Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option4.backgroundColor = .systemBackground
                                } else {
                                    option4.backgroundColor = .white
                                }
                                option4Count.isHidden = true
                            }else{
                                option4.backgroundColor = .lightText
                                option4Count.isHidden = false
                            }
                        }
                    case 5:
                        option1.isHidden = false
                        if let option1Dictionary = options["1"] as? [String:Any], let count = option1Dictionary["count"] as? Int, let text = option1Dictionary["text"] as? String {
                            option1Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option1Count.text = "\(countValue)%"
                            if let voter = option1Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option1Tick.isHidden = false
                                }else{
                                    option1Tick.isHidden = true
                                }
                            }else{
                                option1Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option1.backgroundColor = .systemBackground
                                } else {
                                    option1.backgroundColor = .white
                                }
                                option1Count.isHidden = true
                            }else{
                                option1.backgroundColor = .lightText
                                option1Count.isHidden = false
                            }
                        }
                        option2.isHidden = false
                        if let option2Dictionary = options["2"] as? [String:Any], let count = option2Dictionary["count"] as? Int, let text = option2Dictionary["text"] as? String {
                            option2Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option2Count.text = "\(countValue)%"
                            if let voter = option2Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option2Tick.isHidden = false
                                }else{
                                    option2Tick.isHidden = true
                                }
                            }else{
                                option2Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option2.backgroundColor = .systemBackground
                                } else {
                                    option2.backgroundColor = .white
                                }
                                option2Count.isHidden = true
                            }else{
                                option2.backgroundColor = .lightText
                                option2Count.isHidden = false
                            }
                        }
                        option3.isHidden = false
                        if let option3Dictionary = options["3"] as? [String:Any], let count = option3Dictionary["count"] as? Int, let text = option3Dictionary["text"] as? String {
                            option3Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option3Count.text = "\(countValue)%"
                            if let voter = option3Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option3Tick.isHidden = false
                                }else{
                                    option3Tick.isHidden = true
                                }
                            }else{
                                option3Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option3.backgroundColor = .systemBackground
                                } else {
                                    option3.backgroundColor = .white
                                }
                                option3Count.isHidden = true
                            }else{
                                option3.backgroundColor = .lightText
                                option3Count.isHidden = false
                            }
                        }
                        option4.isHidden = false
                        if let option4Dictionary = options["4"] as? [String:Any], let count = option4Dictionary["count"] as? Int, let text = option4Dictionary["text"] as? String {
                            option4Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option4Count.text = "\(countValue)%"
                            if let voter = option4Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option4Tick.isHidden = false
                                }else{
                                    option4Tick.isHidden = true
                                }
                            }else{
                                option4Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option4.backgroundColor = .systemBackground
                                } else {
                                    option4.backgroundColor = .white
                                }
                                option4Count.isHidden = true
                            }else{
                                option4.backgroundColor = .lightText
                                option4Count.isHidden = false
                            }
                        }
                        option5.isHidden = false
                        if let option5Dictionary = options["5"] as? [String:Any], let count = option5Dictionary["count"] as? Int, let text = option5Dictionary["text"] as? String {
                            option5Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option5Count.text = "\(countValue)%"
                            if let voter = option5Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option5Tick.isHidden = false
                                }else{
                                    option5Tick.isHidden = true
                                }
                            }else{
                                option5Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option5.backgroundColor = .systemBackground
                                } else {
                                    option5.backgroundColor = .white
                                }
                                option5Count.isHidden = true
                            }else{
                                option5.backgroundColor = .lightText
                                option5Count.isHidden = false
                            }
                        }
                    default:
                        option1.isHidden = false
                        if let option1Dictionary = options["1"] as? [String:Any], let count = option1Dictionary["count"] as? Int, let text = option1Dictionary["text"] as? String {
                            option1Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option1Count.text = "\(countValue)%"
                            if let voter = option1Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option1Tick.isHidden = false
                                }else{
                                    option1Tick.isHidden = true
                                }
                            }else{
                                option1Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option1.backgroundColor = .systemBackground
                                } else {
                                    option1.backgroundColor = .white
                                }
                                option1Count.isHidden = true
                            }else{
                                option1.backgroundColor = .lightText
                                option1Count.isHidden = false
                            }
                        }
                        option2.isHidden = false
                        if let option2Dictionary = options["2"] as? [String:Any], let count = option2Dictionary["count"] as? Int, let text = option2Dictionary["text"] as? String {
                            option2Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option2Count.text = "\(countValue)%"
                            if let voter = option2Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option2Tick.isHidden = false
                                }else{
                                    option2Tick.isHidden = true
                                }
                            }else{
                                option2Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option2.backgroundColor = .systemBackground
                                } else {
                                    option2.backgroundColor = .white
                                }
                                option2Count.isHidden = true
                            }else{
                                option2.backgroundColor = .lightText
                                option2Count.isHidden = false
                            }
                        }
                        option3.isHidden = false
                        if let option3Dictionary = options["3"] as? [String:Any], let count = option3Dictionary["count"] as? Int, let text = option3Dictionary["text"] as? String {
                            option3Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option3Count.text = "\(countValue)%"
                            if let voter = option3Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option3Tick.isHidden = false
                                }else{
                                    option3Tick.isHidden = true
                                }
                            }else{
                                option3Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option3.backgroundColor = .systemBackground
                                } else {
                                    option3.backgroundColor = .white
                                }
                                option3Count.isHidden = true
                            }else{
                                option3.backgroundColor = .lightText
                                option3Count.isHidden = false
                            }
                        }
                        option4.isHidden = false
                        if let option4Dictionary = options["4"] as? [String:Any], let count = option4Dictionary["count"] as? Int, let text = option4Dictionary["text"] as? String {
                            option4Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option4Count.text = "\(countValue)%"
                            if let voter = option4Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option4Tick.isHidden = false
                                }else{
                                    option4Tick.isHidden = true
                                }
                            }else{
                                option4Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option4.backgroundColor = .systemBackground
                                } else {
                                    option4.backgroundColor = .white
                                }
                                option4Count.isHidden = true
                            }else{
                                option4.backgroundColor = .lightText
                                option4Count.isHidden = false
                            }
                        }
                        option5.isHidden = false
                        if let option5Dictionary = options["5"] as? [String:Any], let count = option5Dictionary["count"] as? Int, let text = option5Dictionary["text"] as? String {
                            option5Text.text = text
                            let countValue = calculatePercentage(value: Double(count), total: Double(total))
                            option5Count.text = "\(countValue)%"
                            if let voter = option5Dictionary["voters"] as? [String:Any] {
                                if voter.keys.contains(CometChatMessages.loggedInUser?.uid ?? ""){
                                    option5Tick.isHidden = false
                                }else{
                                    option5Tick.isHidden = true
                                }
                            }else{
                                option5Tick.isHidden = true
                            }
                            if countValue == 0 {
                                if #available(iOS 13.0, *) {
                                    option5.backgroundColor = .systemBackground
                                } else {
                                    option5.backgroundColor = .white
                                }
                                option5Count.isHidden = true
                            }else{
                                option5.backgroundColor = .lightText
                                option5Count.isHidden = false
                            }
                        }
                    }
                }
            }else{
                
            }
    }
    
    public func calculatePercentage(value:Double, total: Double)-> Int {
        if total == 0 {
            return 0
        }else{
            let value =  value / total * 100
            return Int(value)
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
