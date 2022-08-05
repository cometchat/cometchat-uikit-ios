//
//  CometChatSoundManager.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.
//


// MARK: - Importing Frameworks
import Foundation
import AVFoundation


// MARK: - Declaration of Enum
/**
 `Sound` is an enum which is being used for playing different sounds for different enum states
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
public enum Sound {
    /// Specifies an enum value where in this case it will play sound for `incoming call`
    case incomingCall
    /// Specifies an enum value where in this case it will play sound for `incoming message`
    case incomingMessage
    /// Specifies an enum value where in this case it will play sound for` incoming message from others`
    case incomingMessageFromOther
    /// Specifies an enum value where in this case it will play sound for `outgoing call`
    case outgoingCall
    /// Specifies an enum value where in this case it will play sound for `outgoing message`
    case outgoingMessage
    
    var file: URL? {
        switch self {
        case .incomingCall:
            return CometChatUIKit.bundle.url(forResource: "IncomingCall", withExtension: "wav")
        case .incomingMessage:
            return CometChatUIKit.bundle.url(forResource: "IncomingMessage", withExtension: "wav")
        case .incomingMessageFromOther:
            return CometChatUIKit.bundle.url(forResource: "IncomingMessageFromOther", withExtension: "wav")
        case .outgoingCall:
            return CometChatUIKit.bundle.url(forResource: "OutgoingCall", withExtension: "wav")
        case .outgoingMessage:
            return CometChatUIKit.bundle.url(forResource: "OutgoingMessage", withExtension: "wav")
        }
    }
}

// MARK: - Declaration of Public variable

public var audioPlayer: AVAudioPlayer?
var otherAudioPlaying = AVAudioSession.sharedInstance().isOtherAudioPlaying

/**
 `CometChatSoundManager` is a subclass of `NSObject`
 - `CometChatSoundManager` is a subclass of `NSObject` that is responsible for playing different types of audio which is required for incoming & outgoing events in UI Kit.  This class plays the audio for incoming & outgoing messages as well as calls.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
public  class CometChatSoundManager: NSObject {
    
    /**
     This method is used for playing the sound for a particular state as mentioned in the enum cases.
     - This method is also capable of playing custom sounds by using **`customSound`** parameter mentioned in the method. If this parameter is **`nil`** then it will play the default sound otherwise it will play the custom sound for which the URL is being provided.
     - Parameters:
     - `sound`: Specifies an enum of Sound Types such as incomingCall, incomingMessage etc.
     - `customSound`: Specifies an `URL` which takes bundle URL and play's custom sound for that particular enum casew.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    func play(sound: Sound, customSound: URL? = nil) -> CometChatSoundManager {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
            
            switch sound {
                
            case .incomingCall:
                
                if let customSound = customSound {
                    audioPlayer = try AVAudioPlayer(contentsOf: customSound)
                }else if let incomingCallURL = sound.file {
                    audioPlayer = try AVAudioPlayer(contentsOf: incomingCallURL)
                }
                audioPlayer?.numberOfLoops = -1
                try session.setActive(true)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
            case .outgoingCall:
                if let customSound = customSound {
                    audioPlayer = try AVAudioPlayer(contentsOf: customSound)
                }else if let outgoingCallURL = sound.file {
                    audioPlayer = try AVAudioPlayer(contentsOf: outgoingCallURL)
                }
                audioPlayer?.numberOfLoops = -1
                try session.setCategory(.playAndRecord)
                try session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                try session.setActive(true)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                
            case .incomingMessage, .incomingMessageFromOther, .outgoingMessage:
                if otherAudioPlaying {
                    AudioServicesPlayAlertSound(SystemSoundID(1519))
                }else{
                    if let customSound = customSound {
                        audioPlayer = try AVAudioPlayer(contentsOf: customSound)
                    }else if let url = sound.file {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                    }
                    try session.setActive(true)
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                }
            }
        }catch { }
        return  self
    }
    
    
    /**
     This method pauses different types of sounds for incoming outgoing calls and messages.
     - This method pauses different types of sounds for incoming outgoing calls and messages.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    func pause() -> CometChatSoundManager {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
        }
        return  self
    }
}

/*  -------------------------------------------------------------------------- */


