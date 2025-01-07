//
//  CometChatPNHelper.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 05/09/23.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift
import PushKit
import CallKit
import AVFAudio

#if canImport(CometChatCallsSDK)
import CometChatCallsSDK
#endif

class CometChatAPNsHelper {
    
    var uuid: UUID?
    var activeCall: Call?
    var cancelCall: Bool = true
    var onCall = true
    var callController = CXCallController()
    let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    var provider: CXProvider? = nil
    
    //Start For APNs Push notification
    public func configurePushNotification(application: UIApplication, delegate: AppDelegate) {
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        // Define the reply action
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_ACTION",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your reply here"
        )
        
        // Define the notification category
        let messageCategory = UNNotificationCategory(
            identifier: "",
            actions: [replyAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Register the category
        UNUserNotificationCenter.current().setNotificationCategories([messageCategory])

        UIApplication.shared.registerForRemoteNotifications()
        application.registerForRemoteNotifications()
        
        CometChat.addLoginListener("loginlistener-pnToken-register-login", self)
        
        #if canImport(CometChatCallsSDK)
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = (delegate as? PKPushRegistryDelegate)
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        CometChatCallEvents.addListener("loginlistener-pnToken-register-login", self)
        #endif
        
    }
    
    
    public func registerTokenForPushNotification(deviceToken: Data) {
        guard CometChat.getLoggedInUser() != nil else {
            return
        }
        let hexString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(hexString, forKey: "apnspuToken")
        print("apns token \(hexString)")
        CometChatNotifications.registerPushToken(pushToken: hexString, platform: CometChatNotifications.PushPlatforms.APNS_IOS_DEVICE, providerId: AppConstants.PROVIDER_ID, onSuccess: { (success) in
            print("registerPushToken apns: \(success)")
            
        }) { (error) in
            print("registerPushToken apns: \(error.errorCode) \(error.errorDescription)")
        }
        
    }
    //end for APNs Push notification
    
    
    //start for VoIP
    
    public func registerForVoIPCalls(pushCredentials: PKPushCredentials) {
        
        guard CometChat.getLoggedInUser() != nil else {
            return
        }
        let deviceToken = pushCredentials.token.reduce("", {$0 + String(format: "%02X", $1) })
        UserDefaults.standard.set(deviceToken, forKey: "voipToken")
        print("VOIP token \(deviceToken)")
        CometChatNotifications.registerPushToken(pushToken: deviceToken, platform: CometChatNotifications.PushPlatforms.APNS_IOS_VOIP, providerId: AppConstants.PROVIDER_ID, onSuccess: { (success) in
            print("registerPushToken VOIP: \(success)")
            
        }) { (error) in
            print("registerPushToken VOIP: \(error.errorCode) \(error.errorDescription)")
        }
    }
    
    public func onProviderDidReset(provider: CXProvider) {
        if let uuid = self.uuid {
            onCall = true
            provider.reportCall(with: uuid, endedAt: Date(), reason: .unanswered)
        }
    }
    
    
    public func handleMissedCallNotification(payload: [AnyHashable: Any]) {
        guard let senderName = payload["senderName"] as? String,
              let senderAvatar = payload["senderAvatar"] as? String else {
            print("Missing required payload fields.")
            return
        }
        
        let content = UNMutableNotificationContent()
        if let avatarURL = URL(string: senderAvatar), let imageData = try? Data(contentsOf: avatarURL) {
            do {
                let fileManager = FileManager.default
                let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
                let fileURL = temporaryDirectory.appendingPathComponent("avatar.png")
                try imageData.write(to: fileURL)
                let attachment = try UNNotificationAttachment(identifier: "avatar", url: fileURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("Error creating notification attachment: \(error.localizedDescription)")
            }
        }
        
        //CometChatIncomingMissedCall
        content.title = "\(senderName)"
        content.body = "Missed call"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error displaying missed call notification: \(error.localizedDescription)")
            } else {
                print("Missed call notification displayed successfully")
            }
        }
    }

    
    func reloadViewController(_ rootViewController : UIViewController) {
        if let navigationController = rootViewController as? UINavigationController {
            if let visibleViewController = navigationController.visibleViewController {
                visibleViewController.viewWillAppear(true)
                visibleViewController.viewDidAppear(true)
            }
        } else {
            rootViewController.viewWillAppear(true)
            rootViewController.viewDidAppear(true)
        }
        
    }
    
    //end for VoIP
    public func presentMessageFromPayload(response:  UNNotificationResponse) {
        let notification = response.notification.request.content.userInfo as? [String: Any]
        
        if let userInfo = notification, let messageObject =
            userInfo["message"], let dict = messageObject as? [String: Any] {
            
            let message = CometChat.processMessage(dict).0
            let cometChatMessages = MessagesVC()
            
            if message?.receiverType == .user {
                guard let uid = message?.senderUid, let userName = message?.sender?.name else { return }
                let user = User(uid: uid, name: userName)
                cometChatMessages.user = user
            }else {
                guard let group = (message?.receiver as? Group)else { return }
                cometChatMessages.group = group
            }
            
            cometChatMessages.modalPresentationStyle = .fullScreen
            
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            
            if let window = sceneDelegate?.window, let rootViewController = window.rootViewController {
                var currentController = rootViewController
                while let presentedController = currentController.presentedViewController {
                    currentController = presentedController
                }
                currentController.present(cometChatMessages, animated: true)
            }
        }
    }
}


//MARK: Login Token handling
extension CometChatAPNsHelper: CometChatLoginDelegate {
    
    func onLoginSuccess(user: CometChatSDK.User) {
        #if canImport(CometChatCallsSDK)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            UIApplication.shared.registerForRemoteNotifications()
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let registry = PKPushRegistry(queue: DispatchQueue.main)
                registry.delegate = appDelegate
                appDelegate.pushRegistry(registry, didInvalidatePushTokenFor: .voIP)
            }
        }
        #endif
    }
    
    func onLoginFailed(error: CometChatSDK.CometChatException?) {  return }
    
    func onLogoutSuccess() { return }
    
    func onLogoutFailed(error: CometChatSDK.CometChatException?) { return }
    
    
}

// MARK: - VoIP & CALL KIT FUNCTIONS -

#if canImport(CometChatCallsSDK)

extension CometChatAPNsHelper {
    
    public func didReceiveIncomingPushWith(payload: PKPushPayload) -> CXProvider? {
        guard let sender = payload.dictionaryPayload["sender"] as? String,
              let senderName = payload.dictionaryPayload["senderName"] as? String,
              let body = payload.dictionaryPayload["body"] as? String,
              let callAction = payload.dictionaryPayload["callAction"] as? String,
              let receiver = payload.dictionaryPayload["receiver"] as? String,
              let type = payload.dictionaryPayload["type"] as? String,
              let callType = payload.dictionaryPayload["callType"] as? String,
              let sessionId = payload.dictionaryPayload["sessionId"] as? String,
              let conversationId = payload.dictionaryPayload["conversationId"] as? String else {
            return nil
        }
        let applicationState = UIApplication.shared.applicationState
        if type == "call" {
            switch callAction {
            case "initiated":
                switch applicationState{
                case.active:
                    return updatedInitiateCall(sender: sender, senderName: senderName, body: body, callAction: callAction, receiver: receiver, callType: callType, sessionId: sessionId, conversationId: conversationId)
                case .inactive:
                    return updatedInitiateCall(sender: sender, senderName: senderName, body: body, callAction: callAction, receiver: receiver, callType: callType, sessionId: sessionId, conversationId: conversationId)
                case .background:
                    return updatedInitiateCall(sender: sender, senderName: senderName, body: body, callAction: callAction, receiver: receiver, callType: callType, sessionId: sessionId, conversationId: conversationId)
                @unknown default:
                    break
                }
            case "ongoing":
                print("----------ongoing voip received----------")
                break
            case "unanswered":
                provider?.reportCall(with: uuid!, endedAt: Date(), reason: .unanswered)
                handleMissedCallNotification(payload: payload.dictionaryPayload)
            case "rejected" :
                provider?.reportCall(with: uuid!, endedAt: Date(), reason: .unanswered)
            case "busy" :
                provider?.reportCall(with: uuid!, endedAt: Date(), reason: .unanswered)
            case "cancelled":
                provider?.reportCall(with: uuid!, endedAt: Date(), reason: .failed)
                handleMissedCallNotification(payload: payload.dictionaryPayload)
            case "ended":
                provider?.reportCall(with: uuid!, endedAt: Date(), reason: .remoteEnded)
            default:
                provider?.reportCall(with: uuid!, endedAt: Date(), reason: .remoteEnded)
            }
        }
        
        return nil
    }
    
    public func onAnswerCallAction(action: CXAnswerCallAction) {
        if activeCall != nil {
            startCall()
        }
        
        action.fulfill()
    }
    
    private func updatedInitiateCall(sender: String, senderName: String, body: String, callAction: String, receiver: String, callType: String, sessionId: String, conversationId: String) -> CXProvider? {
        
        let callTypeValue: CometChat.CallType = callType == "audio" ? .audio : .video
        let receiverType: CometChat.ReceiverType = conversationId.contains("group") ? .group : .user
        let call = Call(receiverId: receiver, callType: callTypeValue, receiverType: receiverType)
        call.sessionID = sessionId
        call.callStatus = .initiated
        call.initiatedAt = Date().timeIntervalSince1970
        call.callInitiator = User(uid: sender, name: senderName)
        call.callType = callTypeValue
        call.callReceiver = User(uid: receiver, name: receiver)
        
        activeCall = call
        uuid = UUID()
        
        let callerName = senderName
        let config = CXProviderConfiguration(localizedName: "APNS + Callkit")
        config.iconTemplateImageData = UIImage(named: "AppIcon")?.pngData()
        config.includesCallsInRecents = true
        config.ringtoneSound = "ringtone.caf"
        config.iconTemplateImageData = #imageLiteral(resourceName: "cometchat_white").pngData()
        config.supportsVideo = true
        
        provider = CXProvider(configuration: config)
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: callerName.capitalized)
        update.hasVideo = callType == "video"
        
        provider?.reportNewIncomingCall(with: uuid!, update: update, completion: { error in
            if error == nil {
                self.configureAudioSession()
            }
        })
        
        return provider!
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: [.mixWithOthers, .allowBluetooth, .defaultToSpeaker])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
    }
    
    private func startCall() {
        let cometChatOngoingCall = CometChatOngoingCall()
        
        // Attempt to accept the call using the session ID from the active call
        CometChat.acceptCall(sessionID: activeCall?.sessionID ?? "") { call in
            DispatchQueue.main.async {
                let isAudioCall = (self.activeCall?.callType == .audio)
                let appDelegate = AppDelegate()
                var callSettingsBuilder = CometChatCallsSDK.CallSettingsBuilder()
                callSettingsBuilder = callSettingsBuilder.setIsAudioOnly(isAudioCall)
                cometChatOngoingCall.set(callSettingsBuilder: callSettingsBuilder)
                cometChatOngoingCall.set(callWorkFlow: .defaultCalling)
                cometChatOngoingCall.set(sessionId: call?.sessionID ?? "")
                cometChatOngoingCall.modalPresentationStyle = .fullScreen
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                   let window = sceneDelegate.window,
                   let rootViewController = window.rootViewController {
                    var currentController = rootViewController
                    while let presentedController = currentController.presentedViewController {
                        currentController = presentedController
                    }
                    currentController.present(cometChatOngoingCall, animated: true)
                }
            }
            cometChatOngoingCall.setOnCallEnded { [weak self] call in
                DispatchQueue.main.async {
                    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        if let rootViewController = scene.windows.first?.rootViewController {
                            self?.dismissCometChatIncomingCall(from: rootViewController)
                            self?.reloadViewController(rootViewController)
                        }
                    }
                }
                self?.provider?.reportCall(with: self?.uuid ?? UUID(), endedAt: Date(), reason: .remoteEnded)
            }
        } onError: { error in
            print("Error while accepting the call: \(String(describing: error?.errorDescription))")
        }
    }
    
    func onCallEnded(call: CometChatSDK.Call) {
        guard let uuid = uuid else { return }
        
        if activeCall != nil {
            let transaction = CXTransaction(action: CXEndCallAction(call: uuid))
            callController.request(transaction, completion: { error in })
            activeCall = nil
        }
        DispatchQueue.main.sync { [self] in
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                if let rootViewController = scene.windows.first?.rootViewController {
                    dismissCometChatIncomingCall(from: rootViewController)
                    self.reloadViewController(rootViewController)
                }
            }
        }
    }
    
    func onCallInitiated(call: CometChatSDK.Call) {
        let callerName = (call.callReceiver as? User)?.name
        callController = CXCallController()
        uuid = UUID()
        
        let transactionCallStart = CXTransaction(action: CXStartCallAction(call: uuid!, handle: CXHandle(type: .generic, value: callerName ?? "")))
        callController.request(transactionCallStart, completion: { error in })
    }
    
    private func dismissCometChatIncomingCall(from viewController: UIViewController) {
        if let presentedViewController = viewController.presentedViewController {
            if presentedViewController is CometChatIncomingCall {
                presentedViewController.dismiss(animated: false, completion: nil)
            } else {
                dismissCometChatIncomingCall(from: presentedViewController)
            }
        }
    }
    
    public func onEndCallAction(action: CXEndCallAction) {
        
        let endCallAction = CXEndCallAction(call: uuid!)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("Requested transaction successfully")
            }
        }
        
        if let activeCall = activeCall {
            if CometChat.getActiveCall() == nil || (CometChat.getActiveCall()?.callStatus == .initiated && CometChat.getActiveCall()?.callInitiator != CometChat.getLoggedInUser())  {
                CometChat.rejectCall(sessionID: activeCall.sessionID ?? "", status: .rejected, onSuccess: { [self](rejectedCall) in
                    action.fulfill()
                    print("CallKit: Reject call success")
                    DispatchQueue.main.async { [self] in
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            if let rootViewController = scene.windows.first?.rootViewController {
                                self.dismissCometChatIncomingCall(from: rootViewController)
                                self.reloadViewController(rootViewController)
                            }
                        }
                        if let uuid = uuid {
                            provider?.reportCall(with: uuid, endedAt: Date(), reason: .remoteEnded)
                            self.uuid = nil
                        }
                    }
                }) { (error) in
                    print("CallKit: Reject call failed with error: \(String(describing: error?.errorDescription))")
                }
            } else {
                CometChat.endCall(sessionID: CometChat.getActiveCall()?.sessionID ?? "") { call in
                    CometChatCalls.endSession()
                    action.fulfill()
                    print("CallKit: End call success")
                    DispatchQueue.main.async { [self] in
                        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                            if let rootViewController = scene.windows.first?.rootViewController {
                                self.dismissCometChatIncomingCall(from: rootViewController)
                                self.reloadViewController(rootViewController)
                            }
                        }
                    }
                } onError: { error in
                    print("CallKit: End call failed with error: \(String(describing: error?.errorDescription))")
                }

            }
        }
    }

}

extension CometChatAPNsHelper: CometChatCallEventListener {

    ///[ccCallEnded] is used to inform the listeners that a call is ended by either the logged-in user.
    func ccCallEnded(call: Call) {
        guard let uuid = uuid else { return }
        
        if activeCall != nil {
            let transactionCallAccepted = CXTransaction(action: CXEndCallAction(call: uuid))
            callController.request(transactionCallAccepted, completion: { error in })
            activeCall = nil
        }
    }
}

#endif
