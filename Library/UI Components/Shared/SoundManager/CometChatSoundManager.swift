//  CometChatSoundManager.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import Foundation
import AVFoundation

// MARK: - Declaration of Enum

enum Sound {
    case incomingCall
    case incomingMessage
    case incomingMessageForOther
    case outgoingCall
    case outgoingMessage
}

// MARK: - Declaration of Public variable

public var audioPlayer: AVAudioPlayer?
var otherAudioPlaying = AVAudioSession.sharedInstance().isOtherAudioPlaying
/*  ----------------------------------------------------------------------------------------- */

public final class CometChatSoundManager: NSObject {
    
    /**
     This method play or pause different types of sounds for incoming outgoing calls and messages.
     - Parameters:
     - sound: Specifies an enum of Sound Types such as incomingCall, incomingMessage etc.
     - bool:  Specifies boolean value to play or pause the sound.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    func play(sound: Sound, bool: Bool){
       
        if bool == true {
            switch sound {
            case .incomingCall:
                if UIKitSettings.enableSoundForCalls == .enabled {
                 
                    if otherAudioPlaying == false {
                       
                        guard let soundURL = UIKitSettings.bundle.url(forResource: "IncomingCall", withExtension: "wav") else { return }
                        do {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
                            try AVAudioSession.sharedInstance().setActive(true)
                            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                            audioPlayer?.numberOfLoops = -1
                            audioPlayer?.prepareToPlay()
                            audioPlayer?.play()
                        } catch { }
                    }else{
                      
                        AudioServicesPlayAlertSound(SystemSoundID(1519))
                    }
                }else{
                    
                }
                
            case .incomingMessage:
                if UIKitSettings.enableSoundForMessages == .enabled {
                    if otherAudioPlaying == false {
                        guard let soundURL = UIKitSettings.bundle.url(forResource: "IncomingMessage", withExtension: "wav") else { return }
                        do {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
                            try AVAudioSession.sharedInstance().setActive(true)
                            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                            audioPlayer?.prepareToPlay()
                            audioPlayer?.play()
                        } catch { }
                    }else{
                        AudioServicesPlayAlertSound(SystemSoundID(1519))
                    }
                }
            case .outgoingCall:
                if UIKitSettings.enableSoundForCalls == .enabled {
                    if otherAudioPlaying == false {
                        guard let soundURL = UIKitSettings.bundle.url(forResource: "OutgoingCall", withExtension: "wav") else { return }
                        do {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
                            try AVAudioSession.sharedInstance().setActive(true)
                            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                            audioPlayer?.numberOfLoops = -1
                            audioPlayer?.prepareToPlay()
                            audioPlayer?.play()
                        } catch { }
                    }else{
                        AudioServicesPlayAlertSound(SystemSoundID(1519))
                    }
                }
            case .outgoingMessage:
                if UIKitSettings.enableSoundForMessages == .enabled {
                    if otherAudioPlaying == false {
                        guard let soundURL = UIKitSettings.bundle.url(forResource: "OutgoingMessege", withExtension: "wav") else { return }
                        do {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
                            try AVAudioSession.sharedInstance().setActive(true)
                            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                            audioPlayer?.prepareToPlay()
                            audioPlayer?.play()
                        } catch { }
                    }else{
                        AudioServicesPlayAlertSound(SystemSoundID(1519))
                    }
                }else{
                }
            case .incomingMessageForOther:
                if UIKitSettings.enableSoundForMessages == .enabled {
                    if otherAudioPlaying == false {
                        guard let soundURL = UIKitSettings.bundle.url(forResource: "IncomingMessageOther", withExtension: "wav") else { return }
                        do {
                            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default)
                            try AVAudioSession.sharedInstance().setActive(true)
                            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                            audioPlayer?.prepareToPlay()
                            audioPlayer?.play()
                        } catch { }
                    }else{
                        AudioServicesPlayAlertSound(SystemSoundID(1519))
                    }
                }
            }
        }else{
            if audioPlayer?.isPlaying == true {
                audioPlayer?.pause()
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
