//  CometChatCallListItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatCallListItem: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var callStatusIcon: UIImageView!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var time: UILabel!
    
     // MARK: - Declaration of Variables
    
    var currentUser: CometChatPro.User?
    var currentGroup: CometChatPro.Group?
    
    var call: BaseMessage! {
        didSet {
            if let call = call as? CometChatPro.Call {
                time.text = String().setMessageDateHeader(time: Int(call.initiatedAt))
                self.tintColor = UIKitSettings.primaryColor
                switch call.callStatus  {
                case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    
                    // This case satisfies the condition where loggedIn Users makes audio call to another user.
                    if let user = call.callReceiver as? CometChatPro.User {
                        self.currentUser = user
                        self.name.text = user.name
                        /// Set the image for the user.
                        avatar.set(image: user.avatar, with: user.name)
                    }
                    callStatus.text = "OUTGOING_AUDIO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "outgoing-audio-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                    
                    // This case satisfies the condition where other users sends incoming audio call to loggedIn user.
                    if let user = call.callInitiator as? CometChatPro.User {
                        self.currentUser = user
                        self.name.text = user.name
                        /// Set the avatar for the user.
                        avatar.set(image: user.avatar, with: user.name)
                    }
                    callStatus.text = "INCOMING_AUDIO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "incoming-audio-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                    
                    // This case satisfies the condition where other user sends incoming audio call in a  group.
                    if let group = call.callReceiver as? CometChatPro.Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        /// Set the avatar for the group.
                        avatar.set(image: group.icon, with: group.name)
                    }
                    callStatus.text = "INCOMING_AUDIO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "incoming-audio-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    
                    // This case satisfies the condition where loggedIn user sends  audio call in a group.
                    if let group = call.callReceiver as? CometChatPro.Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        /// Set the avatar for the group.
                        avatar.set(image: group.icon, with: group.name)
                    }
                    callStatus.text = "OUTGOING_AUDIO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "outgoing-audio-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                    
                case .initiated where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    if let user = call.callReceiver as? CometChatPro.User {
                        self.currentUser = user
                        self.name.text = user.name
                        /// Set the avatar for the user.
                        avatar.set(image: user.name, with: user.name)
                        
                    }
                    callStatus.text = "OUTGOING_VIDEO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "outgoing-video-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .video && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                    if let user = call.callInitiator as? CometChatPro.User {
                        self.currentUser = user
                        self.name.text = user.name
                        /// Set the avatar for the user.
                        avatar.set(image: user.name, with: user.name)
                    }
                    callStatus.text = "INCOMING_VIDEO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "incoming-video-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    if let group = call.callReceiver as? CometChatPro.Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        /// Set the avatar for the group.
                        avatar.set(image: group.icon, with: group.name)
                    }
                    callStatus.text = "OUTGOING_VIDEO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "outgoing-video-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .initiated where call.callType == .video && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                    if let group = call.callReceiver as? CometChatPro.Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        /// Set the avatar for the group.
                        avatar.set(image: group.icon, with: group.name)
                    }
                    callStatus.text = "INCOMING_VIDEO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "incoming-video-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .label
                    } else {
                        name.textColor = .black
                    }
                    
                case .unanswered where call.callType == .audio && call.receiverType == .user  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    if let user = call.callReceiver as? CometChatPro.User {
                        self.currentUser = user
                        self.name.text = user.name
                        /// Set the avatar for the user.
                        avatar.set(image: user.avatar, with: user.name)
                    }
                    callStatus.text = "UNANSWERED_AUDIO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                    if let user = call.callInitiator as? CometChatPro.User {
                        self.currentUser = user
                        self.name.text = user.name
                        /// Set the avatar for the user.
                        avatar.set(image: user.avatar, with: user.name)
                    }
                    callStatus.text = "MISSED_CALL".localized()
                    callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .audio && call.receiverType == .group  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    if let group = call.callReceiver as? CometChatPro.Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        /// Set the avatar for the group.
                        avatar.set(image: group.icon, with: group.name)
                    }
                    callStatus.text = "UNANSWERED_AUDIO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                    if let group = call.callReceiver as? CometChatPro.Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        /// Set the avatar for the group.
                        avatar.set(image: group.icon, with: group.name)
                    }
                    callStatus.text = "MISSED_CALL".localized()
                    callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    if let user = call.callReceiver as? CometChatPro.User {
                        self.currentUser = user
                        self.name.text = user.name
                        /// Set the avatar for the user.
                        avatar.set(image: user.avatar, with: user.name)
                    }
                    callStatus.text = "UNANSWERED_VIDEO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .video && call.receiverType == .user && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                    if let user = call.callInitiator as? CometChatPro.User {
                        self.currentUser = user
                        self.name.text = user.name
                        /// Set the avatar for the user.
                        avatar.set(image: user.avatar, with: user.name)
                    }
                    callStatus.text = "MISSED_CALL".localized()
                    callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? CometChatPro.User)?.uid == LoggedInUser.uid:
                    if let group = call.callReceiver as? CometChatPro.Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        /// Set the avatar for the group.
                        avatar.set(image: group.icon, with: group.name)
                    }
                    callStatus.text = "UNANSWERED_VIDEO_CALL".localized()
                    callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
                    if #available(iOS 13.0, *) {
                        name.textColor = .systemRed
                    } else {
                        name.textColor = .red
                    }
                    
                case .unanswered where call.callType == .video && call.receiverType == .group && (call.callInitiator as? CometChatPro.User)?.uid != LoggedInUser.uid:
                    if let group = call.callReceiver as? CometChatPro.Group {
                        self.currentGroup = group
                        self.name.text = group.name
                        /// Set the avatar for the group.
                        avatar.set(image: group.icon, with: group.name)
                    }
                    callStatus.text = "MISSED_CALL".localized()
                    callStatusIcon.image = UIImage(named: "end-call", in: UIKitSettings.bundle, compatibleWith: nil)
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Cancel Image Request
        avatar.cancel()
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
