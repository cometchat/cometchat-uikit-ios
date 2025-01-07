//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 07/03/23.
//

#if canImport(CometChatCallsSDK)

import CometChatCallsSDK
import Foundation
import CometChatSDK

protocol OngoingCallViewModelProtocol {
    
    var onUserJoined: ((CometChatSDK.User) -> Void)? { get }
    var onUserLeft: ((CometChatSDK.User) -> Void)? { get }
    var onUserListUpdated: (([CometChatSDK.User]) -> Void)? { get }
    var onAudioModesUpdated: (([OngoingCallViewModel.AudioDevice]) -> Void)? { get }
    var onCallSwitchedToVideo: (([String : Any]?) -> Void)? { get }
    var onRecordingStarted: ((CometChatSDK.User?) -> Void)? { get }
    var onRecordingStopped: ((CometChatSDK.User?) -> Void)? { get }
    var onCallEnded: (() -> Void)? { get }
    var onUserMuted: (([String : CometChatSDK.User]?) -> Void)? { get }
    var onError: ((CometChatCallException?) -> Void)? { get }
    
    func startCall()
}

class OngoingCallViewModel:  OngoingCallViewModelProtocol {
    
    var onUserJoined: ((CometChatSDK.User) -> Void)?
    var onUserLeft: ((CometChatSDK.User) -> Void)?
    var onUserMuted: (([String : CometChatSDK.User]?) -> Void)?
    var onUserListUpdated: (([CometChatSDK.User]) -> Void)?
    var onAudioModesUpdated: (([AudioDevice]) -> Void)?
    var onRecordingStarted: ((CometChatSDK.User?) -> Void)?
    var onRecordingStopped: ((CometChatSDK.User?) -> Void)?
    var onCallEnded: (() -> Void)?
    var onCallSwitchedToVideo: (([String : Any]?) -> Void)?
    var onError: ((CometChatCallException?) -> Void)?
    
    var callEvents = CallingEvents()
    var isMe: Bool?
    private var callView: UIView?
    private var sessionId: NSString?
    private var callSettings: CometChatCallsSDK.CallSettings?
    private var callWorkFlow: CallWorkFlow?
    private var user: User?
    var arrUser = [User]()
    
    init(callView: UIView, sessionId: String) {
        self.callView = callView
        self.sessionId = sessionId as NSString
        callEvents.parent = self
    }
    
    func startCall() {
        if let authToken = CometChat.getUserAuthToken() as? NSString, let sessionId = sessionId {
            CometChatCalls.generateToken(authToken: authToken, sessionID: sessionId) {
                token in
                if let callView = self.callView, let callSettings = self.callSettings {
                    CometChatCalls.startSession(callToken: token ?? "", callSetting: callSettings, view: callView, onSuccess: {_ in
                        
                        
                    }, onError: {error in
                        self.onError?(error)
                    })
                }
            } onError: {error in
                self.onError?(error)
            }
        }
    }
    
    func set(callSettingsBuilder: CometChatCallsSDK.CallSettingsBuilder) {
        self.callSettings = callSettingsBuilder.setDelegate(self.callEvents).build()
    }
    
    func set(callWorkFlow: CallWorkFlow) {
        self.callWorkFlow = callWorkFlow
    }
}

extension OngoingCallViewModel {
    class CallingEvents : CallsEventsDelegate {
        weak var parent: OngoingCallViewModel! = nil
        
        func onCallEnded() {
            if parent.callWorkFlow != .directCalling {
                CometChatCalls.endSession()
                CometChat.clearActiveCall()
                parent.onCallEnded?()
            }
        }
        
        func onCallEndButtonPressed() {
            if parent.callWorkFlow != .directCalling {
                endCall()
            } else {
                CometChatCalls.endSession()
                parent.onCallEnded?()
            }
        }
        
        func onUserJoined(user: NSDictionary) {
            if let user_ = OngoingCallViewModel.userFromDictionary(userData: user) {
                parent.onUserJoined?(user_)
            }
        }
        
        func onUserLeft(user: NSDictionary) {
            if let user_ = OngoingCallViewModel.userFromDictionary(userData: user) {
                parent.onUserLeft?(user_)
            }
        }
        
        func onUserListChanged(userList: NSArray) {
            parent.arrUser.removeAll()
            for userDict in userList {
                if let userDict_ = userDict as? [String:Any], let user = OngoingCallViewModel.userFromDictionary(userData: userDict_ as NSDictionary) {
                    parent.arrUser.append(user)
                }
            }
            parent.onUserListUpdated?(parent.arrUser)
        }
        
        func onAudioModeChanged(audioModeList: NSArray) {
            var arrAudio = [AudioDevice]()
            for audioDict in audioModeList {
                if let audioDict_ = audioDict as? [String:Any], let audio = OngoingCallViewModel.audioFromDictionary(audioData: audioDict_ as NSDictionary) {
                    arrAudio.append(audio)
                }
            }
                parent.onAudioModesUpdated?(arrAudio)
        }
        
        func onCallSwitchedToVideo(info: NSDictionary) {
            if let intiator = info["intiator"] as? [String:Any], let responder = info["responder"] as? [String:Any], let sessionId = info["sessionId"] {
                let data = ["intiator":intiator,"responder":responder,"sessionId":sessionId]
                parent.onCallSwitchedToVideo?(data)
            }
        }
        
        func onUserMuted(info: NSDictionary) {
            if let mutedByUserDict = info["mutedBy"], let mutedUserDict = info["muted"] {
                if let mutedByUserDict_ = mutedUserDict as? NSDictionary, let mutedByUser = OngoingCallViewModel.userFromDictionary(userData: mutedByUserDict_), let mutedUserDict_ = mutedUserDict as? NSDictionary,
                   let mutedUser = OngoingCallViewModel.userFromDictionary(userData: mutedUserDict_) {
                    let mutedDict = ["muted":mutedUser,"mutedBy":mutedByUser]
                    parent.onUserMuted?(mutedDict)
                }
            }
        }
        
        func onRecordingToggled(info: NSDictionary) {
            if let userDict = info["user"] as? NSDictionary, let recordStarted = info["recordingStarted"], let user = OngoingCallViewModel.userFromDictionary(userData: userDict) {
                    if let recordingStarted = recordStarted as? Bool, recordingStarted == true {
                        parent.onRecordingStarted?(user)
                    } else {
                        parent.onRecordingStopped?(user)
                    }
            }
        }
        
        private func endCall() {
            if let sessionId = parent.sessionId {
                CometChat.endCall(sessionID: sessionId as String, onSuccess: {call in
                    print("End Call Success")
                    if let call = call {
                        self.parent.onCallEnded?()
                        CometChatCallEvents.ccCallEnded(call: call)
                    }
                }, onError: { error in
                    print("End Call failed with error \(error?.errorDescription ?? "") ")
                })
            }
        }
    }
    
    static func userFromDictionary(userData: NSDictionary) -> User? {
        
        let user:User?
        let decoder = JSONDecoder()
            
            do {
                let user_  = try decoder.decode(UserCodable.self, from: JSONSerialization.data(withJSONObject: userData, options: []))
                
                user = User(uid: user_.uid, name: user_.name)
                user?.avatar = user_.avatar
                user?.link = user_.link
                user?.role = user_.role
                if let status = userData["status"] as? String {
                    if status == "offline" {
                        user?.status = .offline
                    } else {
                        user?.status = .online
                    }
                }
                user?.statusMessage = user_.statusMessage
                user?.lastActiveAt = user_.lastActiveAt ?? 0.0
                user?.hasBlockedMe = user_.hasBlockedMe ?? false
                user?.blockedByMe = user_.blockedByMe ?? false
                user?.tags = user_.tags ?? []
                user?.deactivatedAt = user_.deactivatedAt ?? 0.0
                
                if let metadata = userData["metadata"] as? [String:Any]{
                    user?.metadata = metadata
                }
                
            }catch{
                return (nil)
            }
        return (user)
    }
    
    static func audioFromDictionary(audioData: NSDictionary) -> AudioDevice? {
        
        let audio:AudioDevice?
        let decoder = JSONDecoder()
            
            do {
                let _audio  = try decoder.decode(AudioModeCodable.self, from: JSONSerialization.data(withJSONObject: audioData, options: []));
                audio = AudioDevice()
                audio?.mode = _audio.type;
                audio?.isSelected = _audio.selected;
                
            }catch{
                return nil
            }
        return audio
        
        
    }
    
    class AudioDevice: NSObject {
        internal var mode :String?
        internal var isSelected:Bool?
    }
    
    internal struct UserCodable:Codable{
        
        let  uid :String
        let  name :String
        let  avatar :String?
        let  link :String?
        let  role :String?
        let  status :String?
        let  lastActiveAt :Double?
        let  statusMessage: String?
        let  blockedByMe : Bool?
        let  hasBlockedMe : Bool?
        let  tags : [String]?
        let  deactivatedAt : Double?
        
        private enum CodingKeys:String,CodingKey{
            
            case uid = "uid"
            case name = "name"
            case avatar = "avatar"
            case link = "link"
            case role = "role"
            case status = "status"
            case lastActiveAt = "lastActiveAt"
            case statusMessage = "statusMessage"
            case blockedByMe = "blockedByMe"
            case hasBlockedMe = "hasBlockedMe"
            case tags = "tags"
            case deactivatedAt = "deactivatedAt"
        }
    }
    
    internal struct AudioModeCodable:Codable{
        
        let type :String
        let selected :Bool
        
        private enum CodingKeys:String,CodingKey{
            case type = "type"
            case selected = "selected"
        }
    }
}
#endif
