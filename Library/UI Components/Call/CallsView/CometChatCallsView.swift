//  CometChatCallsView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatCallsView: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var callStatusIcon: UIImageView!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var time: UILabel!
    
     // MARK: - Declaration of Variables

    var currentUser: User?
    var currentGroup: Group?
    
    var call: BaseMessage! {
        didSet {
            if let call = call as? Call {
                time.text = String().setMessageDateHeader(time: Int(call.initiatedAt))
                self.tintColor = UIKitSettings.primaryColor
                switch call.callStatus  {
                case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                    // This case satisfies the condition where loggedIn Users makes audio call to another user.
                    if let user = call.callReceiver as? User {
                        self.currentUser = user
                        self.name.text = user.name
                        avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                        
                    }
                    callStatus.text = "Outgoing Audio"
                    callStatusIcon.image = UIImage(named: "outgoingAudio", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    
                    // This case satisfies the condition where other users sends incoming audio call to loggedIn user.
                    if let user = call.callInitiator as? User {
                        self.currentUser = user
                        self.name.text = user.name
                        avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                    }
                    callStatus.text = "Incoming Audio"
                    callStatusIcon.image = UIImage(named: "incomingAudio", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    
                    // This case satisfies the condition where other user sends incoming audio call in a  group.
                    if let group = call.callReceiver as? Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    }
                    callStatus.text = "Incoming Audio"
                    callStatusIcon.image = UIImage(named: "incomingAudio", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    
                    // This case satisfies the condition where loggedIn user sends  audio call in a group.
                    if let group = call.callReceiver as? Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    }
                    callStatus.text = "Outgoing Audio"
                    callStatusIcon.image = UIImage(named: "outgoingAudio", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                    
                case .initiated where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    if let user = call.callReceiver as? User {
                        self.currentUser = user
                        self.name.text = user.name
                        avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                        
                    }
                    callStatus.text = "Outgoing Video"
                    callStatusIcon.image = UIImage(named: "outgoingVideo", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .video && call.receiverType == .user && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    if let user = call.callInitiator as? User {
                        self.currentUser = user
                        self.name.text = user.name
                        avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                        
                    }
                    callStatus.text = "Incoming Video"
                    callStatusIcon.image = UIImage(named: "incomingVideo", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    if let group = call.callReceiver as? Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    }
                    callStatus.text = "Outgoing Video"
                    callStatusIcon.image = UIImage(named: "outgoingVideo", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .video && call.receiverType == .group && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    if let group = call.callReceiver as? Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    }
                    callStatus.text = "Incoming Video"
                    callStatusIcon.image = UIImage(named: "incomingVideo", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .unanswered where call.callType == .audio && call.receiverType == .user  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    if let user = call.callReceiver as? User {
                        self.currentUser = user
                        self.name.text = user.name
                        avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                    }
                    callStatus.text = "Unanswered Audio"
                    callStatusIcon.image = UIImage(named: "missedAudio", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    if let user = call.callInitiator as? User {
                        self.currentUser = user
                        self.name.text = user.name
                        avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                        
                    }
                    callStatus.text = "Missed Audio"
                    callStatusIcon.image = UIImage(named: "missedAudio", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .audio && call.receiverType == .group  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    if let group = call.callReceiver as? Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    }
                    callStatus.text = "Unanswered Audio"
                    callStatusIcon.image = UIImage(named: "missedAudio", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    if let group = call.callReceiver as? Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    }
                    callStatus.text = "Missed Audio"
                    callStatusIcon.image = UIImage(named: "missedAudio", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    if let user = call.callReceiver as? User {
                        self.currentUser = user
                        self.name.text = user.name
                        avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                    }
                    callStatus.text = "Unanswered Video"
                    callStatusIcon.image = UIImage(named: "missedVideo", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .video && call.receiverType == .user && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    if let user = call.callInitiator as? User {
                        self.currentUser = user
                        self.name.text = user.name
                        avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                        
                    }
                    callStatus.text = "Missed Video"
                    callStatusIcon.image = UIImage(named: "missedVideo", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? User)?.uid == LoggedInUser.uid:
                    if let group = call.callReceiver as? Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    }
                    callStatus.text = "Unanswered Video"
                    callStatusIcon.image = UIImage(named: "missedVideo", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .video && call.receiverType == .group && (call.callInitiator as? User)?.uid != LoggedInUser.uid:
                    if let group = call.callReceiver as? Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    }
                    callStatus.text = "Missed Video"
                    callStatusIcon.image = UIImage(named: "missedVideo", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
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
