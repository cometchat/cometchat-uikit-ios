//  CometChatSettingsItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

protocol CreateMeetingDelegate: NSObject {
    func didAudioCallPressed()
    func didVideoCallPressed()
}

class CometChatCreateMeetingView: UITableViewCell {
    
    // MARK: - Declaration of IBOutlet
    @IBOutlet weak var audioCallIcon: UIImageView!
    @IBOutlet weak var videoCallIcon: UIImageView!
    @IBOutlet weak var audioCallTitle: UILabel!
    @IBOutlet weak var videoCallTitle: UILabel!
    @IBOutlet weak var videoCallView: UIView!
    @IBOutlet weak var audioCallView: UIView!
    @IBOutlet weak var createMeetingIcon: UIImageView!
    @IBOutlet weak var createMeetingTitle: UILabel!
    
    
    weak var createMeetingDelegate: CreateMeetingDelegate?
     // MARK: - Initialization of required Methods
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupSuperView()
    }
    
    private func setupSuperView() {
        self.selectionStyle = .none
        createMeetingIcon.image = UIImage(named: "createMeeting.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        audioCallIcon.image = UIImage(named: "audioCalling.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        videoCallIcon.image = UIImage(named: "videoCalling.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        audioCallTitle.text = "AUDIO_CALL".localized()
        videoCallTitle.text = "VIDEO_CALL".localized()
        audioCallTitle.textColor = .white
        videoCallTitle.textColor = .white
        audioCallView.backgroundColor = UIKitSettings.primaryColor
        videoCallView.backgroundColor = UIKitSettings.primaryColor
        createMeetingTitle.text = "START_A_GROUP_CALL".localized()
        
        let tapOnAudioCall = UITapGestureRecognizer(target: self, action: #selector(self.didAudioCallPressed(tapGestureRecognizer:)))
        self.audioCallView.isUserInteractionEnabled = true
        self.audioCallView.addGestureRecognizer(tapOnAudioCall)
        
        let tapOnVideoCall = UITapGestureRecognizer(target: self, action: #selector(self.didVideoCallPressed(tapGestureRecognizer:)))
        self.videoCallView.isUserInteractionEnabled = true
        self.videoCallView.addGestureRecognizer(tapOnVideoCall)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    @objc func didAudioCallPressed(tapGestureRecognizer: UITapGestureRecognizer)
    {
        createMeetingDelegate?.didAudioCallPressed()
    }
    
    @objc func didVideoCallPressed(tapGestureRecognizer: UITapGestureRecognizer)
    {
        createMeetingDelegate?.didVideoCallPressed()
    }
}

/*  ----------------------------------------------------------------------------------------- */


