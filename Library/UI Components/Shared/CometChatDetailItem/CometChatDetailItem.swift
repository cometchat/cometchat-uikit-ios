//  CometChatGroupListItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

CometChatGroupListItem: This component will be the class of UITableViewCell with components such as groupAvatar(Avatar), groupName(UILabel), groupDetails(UILabel).

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

protocol  DetailViewDelegate : AnyObject  {
    
    func didAudioCallButtonPressed(for: AppEntity)
    func didVideoCallButtonPressed(for: AppEntity)
}


/*  ----------------------------------------------------------------------------------------- */

class CometChatDetailItem: UITableViewCell {

     // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var icon: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var videoCall: UIButton!
    @IBOutlet weak var audioCall: UIButton!
    
    // MARK: - Declaration of Variables
    weak var detailViewDelegate: DetailViewDelegate?
    weak var user: User? {
       didSet {
        if let currentUser = user {
            name.text = currentUser.name
                switch currentUser.status {
                case .online:
                    detail.text = "ONLINE".localized()
                case .offline:
                     detail.text = "OFFLINE".localized()
                @unknown default:
                    detail.text = "OFFLINE".localized()
                }
            FeatureRestriction.isUserPresenceEnabled { (success) in
                switch success {
                case .enabled:  self.detail.isHidden = false
                case .disabled: self.detail.isHidden = true
                }
            }
                 icon.set(image: currentUser.avatar ?? "", with: currentUser.name ?? "")
            if #available(iOS 13.0, *) {
                let videoCallIcon = UIImage(named: "videoCall.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                videoCall.setImage(videoCallIcon, for: .normal)
                videoCall.tintColor = UIKitSettings.primaryColor
                
                let audioCallIcon = UIImage(named: "audioCall.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                audioCall.setImage(audioCallIcon, for: .normal)
                audioCall.tintColor = UIKitSettings.primaryColor
                
            } else {}
        }
        
        FeatureRestriction.isOneOnOneAudioCallEnabled { (success) in
            switch success {
            case .enabled: self.audioCall.isHidden = true
            case .disabled: self.audioCall.isHidden = true
            }
        }
        
        FeatureRestriction.isOneOnOneVideoCallEnabled { (success) in
            switch success {
            case .enabled: self.videoCall.isHidden = true
            case .disabled: self.videoCall.isHidden = true
            }
        }
    }
    }
    
    weak var group: Group? {
        didSet {
            if let currentGroup = group {
                name.text = currentGroup.name
                switch currentGroup.groupType {
                case .public:
                    detail.text = "PUBLIC".localized()
                case .private:
                    detail.text = "PRIVATE".localized()
                case .password:
                    detail.text = "PASSWORD_PROTECTED".localized()
                @unknown default:
                    break
                }
                icon.set(image: currentGroup.icon ?? "", with: currentGroup.name ?? "")
                if #available(iOS 13.0, *) {
                    let videoCallIcon = UIImage(named: "videoCall.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    videoCall.setImage(videoCallIcon, for: .normal)
                    videoCall.tintColor = UIKitSettings.primaryColor
                    
                    let audioCallIcon = UIImage(named: "audioCall.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    audioCall.setImage(audioCallIcon, for: .normal)
                    audioCall.tintColor = UIKitSettings.primaryColor
                } else {}
            }
            
            FeatureRestriction.isGroupVideoCallEnabled { (success) in
                switch success {
                case .enabled: self.videoCall.isHidden = true
                case .disabled: self.videoCall.isHidden = true
                }
            }
            
            audioCall.isHidden = true
        }
    }
    
    @IBAction func didVideoCallPressed(_ sender: Any) {
        
        if let currentUser = user {
             detailViewDelegate?.didVideoCallButtonPressed(for: currentUser)
        }
        
        if let currentGroup = group {
            detailViewDelegate?.didVideoCallButtonPressed(for: currentGroup)
        }
    }
    
    @IBAction func didAudioCallPressed(_ sender: Any) {
        
        if let currentUser = user {
             detailViewDelegate?.didAudioCallButtonPressed(for: currentUser)
        }
        
        if let currentGroup = group {
            detailViewDelegate?.didAudioCallButtonPressed(for: currentGroup)
        }
    }
    
    override func prepareForReuse() {
        group = nil
        user = nil
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
