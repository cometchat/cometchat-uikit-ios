//
//  CometChatUIKit.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 01/02/22.
//

import Foundation
import CometChatPro
import CoreMedia

#if canImport(CometChatProCalls)
import CometChatProCalls
#endif


final public class CometChatUIKit {
    
    public enum LoginResult {
        case success(User)
        case failure(CometChatException)
    }
    
    var isInitialised = false
    public static var bundle =  Bundle.module
    static var authSettings: UIKitSettings?
    
    @discardableResult
    public init(authSettings: UIKitSettings, result: @escaping (Result<Bool, Error>) -> Void) {
        CometChat.init(appId: authSettings.appID, appSettings: AppSettings(builder: authSettings.appSettingsBuilder)) { [weak self] isSuccess  in
            guard let strongSelf = self else { return }
            result(.success(isSuccess))
            if isSuccess {
                CometChat.setSource(resource: "ui-kit", platform: "ios", language: "swift")
                strongSelf.isInitialised = true
                #if canImport(CometChatProCalls)
                CallingExtension.enable()
                #endif
                CometChatUIKit.configureExtensions(extensions: authSettings.extensions)
                CometChatUIKit.registerForVOIP(with: authSettings.voipToken)
                CometChatUIKit.registerForPushNotification(with: authSettings.deviceToken)
                CometChatUIKit.registerForFCM(with: authSettings.fcmKey)
            }
            CometChatUIKit.authSettings = authSettings
        } onError: { error in
            self.isInitialised = false
        }
    }
    
    // Registered Push Notification.
    private static func registerForPushNotification(with token: String?) {
        guard let token = token else { return }
        register(with: token, VOIP: false)
    }
    
    private static func register(with token: String, VOIP: Bool? = true) {
        CometChat.registerTokenForPushNotification(token: token, settings: ["voip": VOIP]) { (success) in
            print("onSuccess to registerTokenForPushNotification: \(success)")
        }
            onError: { (error) in
            print("error to registerTokenForPushNotification")
        }
    }
    
    private static func registerForFCM(with FCMToken: String?) {
        guard let token = FCMToken else { return }
        CometChat.registerTokenForPushNotification(token: token, onSuccess: { (sucess) in
            print("token registered \(sucess)")
        }) { (error) in
            print("token registered error \(String(describing: error?.errorDescription))")
        }
    }
    
    private static func registerForVOIP(with token: String?) {
        guard let token = token, !token.isEmpty else { print("VOIP Token should not be empty."); return }
        register(with: token)
    }
    
    private static func registerNotificationAndVOIP() {
        registerForVOIP(with: authSettings?.voipToken)
        registerForPushNotification(with: authSettings?.deviceToken)
        registerForFCM(with: authSettings?.fcmKey)
    }
    
    static public func login(authToken: String, result: @escaping (LoginResult) -> Void) {
        CometChat.login(authToken: authToken) {  user in
            registerNotificationAndVOIP()
            result(.success(user))
           
        } onError: { error in
            result(.failure(error))
        }
    }
    
    static private func configureExtensions(extensions: [ExtensionDataSource]?) {
        let extensions = extensions ?? DefaultExtensions.listOfExtensions()
        if  !extensions.isEmpty {
            if let extensions = extensions as? [ExtensionDataSource]  {
                for i in extensions {
                    i.enable()
                }
            }
        }
    }
    
    static public func login(uid: String, result: @escaping (LoginResult) -> Void) {
        guard let authKey = CometChatUIKit.authSettings?.authKey else { return }
        CometChat.login(UID: uid, apiKey: authKey) { user in
            registerNotificationAndVOIP()
            result(.success(user))
        } onError: { error in
            result(.failure(error))
        }
    }
    
   static public func create(user: User, result: @escaping (LoginResult) -> Void) {
        guard let authKey = CometChatUIKit.authSettings?.authKey else { return }
        CometChat.createUser(user: user, authKey: authKey) { user in
            result(.success(user))
        } onError: { error in
            if let error = error {
                result(.failure(error))
            }
        }
    }
    
    static public func update(user: User, result: @escaping (LoginResult) -> Void) {
        guard let apiKey = CometChatUIKit.authSettings?.apiKey else { return }
        CometChat.updateUser(user: user, apiKey: apiKey) { user in
            result(.success(user))
        } onError: { error in
            if let error = error {
                result(.failure(error))
            }
        }
    }
    
    static public func logout(user: User, result: @escaping (LoginResult) -> Void) {
        CometChat.logout { isSuccess in
            result(.success(user))
        } onError: { error in
            result(.failure(error))
        }
    }
}

//Methods related to Sending of messages
//=============================================
extension CometChatUIKit {
    
    public static func sendTextMessage(message: TextMessage) {
        CometChatMessageEvents.emitOnMessageSent(message: message, status: MessageStatus.inProgress)
        CometChat.sendTextMessage(message: message) { textMessage in
            CometChatMessageEvents.emitOnMessageSent(message: textMessage, status: MessageStatus.success)
        } onError: { (error) in
            if let error =  error {
                CometChatMessageEvents.emitOnError(message: message, error: error)
            }
        }
    }

    public static func sendCustomMessage(message: CustomMessage) {
        CometChatMessageEvents.emitOnMessageSent(message: message, status: MessageStatus.inProgress)
        CometChat.sendCustomMessage(message: message) { customMessage in
            CometChatMessageEvents.emitOnMessageSent(message: customMessage, status: MessageStatus.success)
        } onError: { error in
            if let error =  error {
                CometChatMessageEvents.emitOnError(message: message, error: error)
            }
        }
    }

    public static func sendMediaMessage(message: MediaMessage) {
        CometChatMessageEvents.emitOnMessageSent(message: message, status: MessageStatus.inProgress)
        CometChat.sendMediaMessage(message: message) { mediaMessage in
            CometChatMessageEvents.emitOnMessageSent(message: mediaMessage, status: MessageStatus.success)
        } onError: { error in
            if let error =  error {
                CometChatMessageEvents.emitOnError(message: message, error: error)
            }
        }
    }
}
