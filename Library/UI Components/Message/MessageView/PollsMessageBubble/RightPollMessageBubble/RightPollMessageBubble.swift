//
//  RightPollMessageBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 16/09/20.
//  Copyright © 2020 MacMini-03. All rights reserved.

import UIKit
import CometChatPro

class RightPollMessageBubble: UITableViewCell {
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var option1: UIView!
    @IBOutlet weak var option2: UIView!
    @IBOutlet weak var option3: UIView!
    @IBOutlet weak var option4: UIView!
    @IBOutlet weak var option5: UIView!
    
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

    @IBOutlet weak var votes: UILabel!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
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
            receiptStack.isHidden = true
            self.parsePollsExtension(forMessage: pollMessage)
            self.reactionView.parseMessageReactionForMessage(message: pollMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            messageView.backgroundColor = UIKitSettings.primaryColor
            if pollMessage.readAt > 0 && pollMessage.receiverType == .user{
                receipt.image = UIImage(named: "read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(pollMessage?.readAt ?? 0))
            }else if pollMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "delivered", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(pollMessage?.deliveredAt ?? 0))
            }else if pollMessage.sentAt > 0 {
                receipt.image = UIImage(named: "sent", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(pollMessage?.sentAt ?? 0))
            }else if pollMessage.sentAt == 0 {
                receipt.image = UIImage(named: "wait", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
            }
        }
    }
  
    
    private func parsePollsExtension(forMessage: CustomMessage){
        
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let pollsDictionary = cometChatExtension["polls"] as? [String : Any] {
         
            if let pollID = pollsDictionary["id"] as? String {
               
            }
            if let options = pollsDictionary["options"] as? [String:String] {
                switch options.count {
                case 1:
                    option1.isHidden = false
                    if let option1String = options["1"] {
                        option1Text.text = option1String
                    }
                case 2:
                    option1.isHidden = false
                    option2.isHidden = false
                    if let option1String = options["1"] {
                        option1Text.text = option1String
                    }
                    if let option2String = options["2"] {
                        option2Text.text = option2String
                    }
                case 3:
                    option1.isHidden = false
                    option2.isHidden = false
                    option3.isHidden = false
                    if let option1String = options["1"] {
                        option1Text.text = option1String
                    }
                    if let option2String = options["2"] {
                        option2Text.text = option2String
                    }
                    if let option3String = options["3"] {
                        option3Text.text = option3String
                    }
                case 4:
                    option1.isHidden = false
                    option2.isHidden = false
                    option3.isHidden = false
                    option4.isHidden = false
                    
                    if let option1String = options["1"] {
                        option1Text.text = option1String
                    }
                    if let option2String = options["2"] {
                        option2Text.text = option2String
                    }
                    if let option3String = options["3"] {
                        option3Text.text = option3String
                    }
                    if let option4String = options["4"] {
                        option4Text.text = option4String
                    }
                    
                case 5:
                    
                    option1.isHidden = false
                    option2.isHidden = false
                    option3.isHidden = false
                    option4.isHidden = false
                    option5.isHidden = false
                    
                    if let option1String = options["1"] {
                        option1Text.text = option1String
                    }
                    if let option2String = options["2"] {
                        option2Text.text = option2String
                    }
                    if let option3String = options["3"] {
                        option3Text.text = option3String
                    }
                    if let option4String = options["4"] {
                        option4Text.text = option4String
                    }
                    if let option5String = options["5"] {
                        option5Text.text = option5String
                    }
                default:break
                }
            }
            if let currentQuestion = pollsDictionary["question"] as? String {
                self.question.text = currentQuestion
            }
            
            if let results = pollsDictionary["results"] as? [String:Any], let options = results["options"] as? [String:Any] {
                if let total = results["total"] as? Int {
            
                    if total == 0 {
                        votes.isHidden = true
                        votes.text = ""
                    }else if total == 1 {
                        votes.isHidden = false
                        votes.text = "1 Vote"
                    }else{
                        votes.isHidden = false
                        votes.text = "\(total) Votes"
                    }
              
                switch options.count {
                case 1:
                    if let option1Value = options["1"] as? [String:Any], let count1 = option1Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count1), total: Double(total))
                        
                       self.option1Count.text = "\(value)%"

                        if value == 0 {
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
                    if let option1Value = options["1"] as? [String:Any], let count1 = option1Value["count"] as? Int {
                       let value = calculatePercentage(value: Double(count1), total: Double(total))
                        
                       self.option1Count.text = "\(value)%"
                        if value == 0 {
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
                    if let option2Value = options["2"] as? [String:Any], let count2 = option2Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count2), total: Double(total))
                        self.option2Count.text = "\(value)%"
                        if value == 0{
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
                    if let option1Value = options["1"] as? [String:Any], let count1 = option1Value["count"] as? Int {
                       let value = calculatePercentage(value: Double(count1), total: Double(total))
                        
                       self.option1Count.text = "\(value)%"
                        if value == 0{
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
                    if let option2Value = options["2"] as? [String:Any], let count2 = option2Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count2), total: Double(total))
                        self.option2Count.text = "\(value)%"
                        if value == 0{
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
                    if let option3Value = options["3"] as? [String:Any], let count3 = option3Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count3), total: Double(total))
                        self.option3Count.text = "\(value)%"
                        if value == 0{
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
                    if let option1Value = options["1"] as? [String:Any], let count1 = option1Value["count"] as? Int {
                       let value = calculatePercentage(value: Double(count1), total: Double(total))
                        
                       self.option1Count.text = "\(value)%"
                        if value == 0 {
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
                    if let option2Value = options["2"] as? [String:Any], let count2 = option2Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count2), total: Double(total))
                        self.option2Count.text = "\(value)%"
        
                        if value == 0{
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
                    if let option3Value = options["3"] as? [String:Any], let count3 = option3Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count3), total: Double(total))
                        self.option3Count.text = "\(value)%"
                        if value == 0{
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
                    if let option4Value = options["4"] as? [String:Any], let count4 = option4Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count4), total: Double(total))
                        self.option4Count.text = "\(value)%"
                        if value == 0{
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
                    if let option1Value = options["1"] as? [String:Any], let count1 = option1Value["count"] as? Int {
                       let value = calculatePercentage(value: Double(count1), total: Double(total))
                        
                       self.option1Count.text = "\(value)%"
                        if value == 0 {
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
                    if let option2Value = options["2"] as? [String:Any], let count2 = option2Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count2), total: Double(total))
                        self.option2Count.text = "\(value)%"
                        if value == 0{
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
                    if let option3Value = options["3"] as? [String:Any], let count3 = option3Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count3), total: Double(total))
                        self.option3Count.text = "\(value)%"
                        if value == 0{
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
                    if let option4Value = options["4"] as? [String:Any], let count4 = option4Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count4), total: Double(total))
                        self.option4Count.text = "\(value)%"
                        if value == 0{
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
                    if let option5Value = options["5"] as? [String:Any], let count4 = option5Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count4), total: Double(total))
                        self.option5Count.text = "\(value)%"
                        if value == 0 {
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
                    if let option1Value = options["1"] as? [String:Any], let count1 = option1Value["count"] as? Int {
                       let value = calculatePercentage(value: Double(count1), total: Double(total))
                        
                       self.option1Count.text = "\(value)%"
                        if value == 0 {
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
                    if let option2Value = options["2"] as? [String:Any], let count2 = option2Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count2), total: Double(total))
                        self.option2Count.text = "\(value)%"
                        if value == 0{
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
                    if let option3Value = options["3"] as? [String:Any], let count3 = option3Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count3), total: Double(total))
                        self.option3Count.text = "\(value)%"
                      
                        if value == 0{
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
                    if let option4Value = options["4"] as? [String:Any], let count4 = option4Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count4), total: Double(total))
                        self.option4Count.text = "\(value)%"
                        if value == 0{
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
                    if let option5Value = options["5"] as? [String:Any], let count4 = option5Value["count"] as? Int {
                        let value = calculatePercentage(value: Double(count4), total: Double(total))
                        self.option5Count.text = "\(value)%"
                        if value == 0 {
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
              }else{
                    votes.isHidden = true
                    votes.text = ""
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
