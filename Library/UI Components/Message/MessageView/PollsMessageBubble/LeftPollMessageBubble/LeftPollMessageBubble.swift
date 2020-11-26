//
//  LeftPollMessageBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 16/09/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro

protocol PollExtensionDelegate: NSObject {
    func voteForPoll(pollID: String, with option: String, cell: UITableViewCell)
}

class LeftPollMessageBubble: UITableViewCell {
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var messgeView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var receiptStack: UIStackView!
    
    @IBOutlet weak var optionStack: UIStackView!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var option1: UIView!
    @IBOutlet weak var option2: UIView!
    @IBOutlet weak var option3: UIView!
    @IBOutlet weak var option4: UIView!
    @IBOutlet weak var option5: UIView!
    
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
    
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var avatar: Avatar!
    
    @IBOutlet weak var votes: UILabel!
    var pollID: String?
    weak var pollDelegate: PollExtensionDelegate?
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
    
    var pollMessage: CustomMessage! {
        didSet{
            self.reactionView.parseMessageReactionForMessage(message: pollMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            receiptStack.isHidden = true
            if pollMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            if let userName = pollMessage.sender?.name {
                name.text = userName + ":"
            }
            
            self.parsePollsExtension(forMessage: pollMessage)
            if let avatarURL = pollMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: pollMessage.sender?.name ?? "")
            }
            time.text = String().setMessageTime(time: Int(pollMessage?.sentAt ?? 0))
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
        
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
 
    
    private func parsePollsExtension(forMessage: CustomMessage){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
                                if voter.keys.contains(LoggedInUser.uid){
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
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if #available(iOS 13.0, *) {
            
        } else {
            messgeView.backgroundColor =  .lightGray
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if #available(iOS 13.0, *) {
            
        } else {
            messgeView.backgroundColor =  .lightGray
        }
    }
    
}
