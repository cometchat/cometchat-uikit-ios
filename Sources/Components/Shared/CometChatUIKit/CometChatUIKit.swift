//
//  Created by Pushpsen Airekar on 01/02/22.
//

import Foundation
import CometChatSDK
import CoreMedia

#if canImport(CometChatCallsSDK)
import CometChatCallsSDK
#endif


final public class CometChatUIKit {
    
    public enum ApiStatus {
        case success(User)
        case onError(CometChatException)
    }
    
    public static var bundle =  Bundle.module
    static var uiKitSettings: UIKitSettings?
    static var uiKitError: CometChatException = CometChatException(errorCode: "Err_101", errorDescription: "UIKit Settings are not initialised, Try calling CometChatUIKit.init method first.")
    
    static public let soundManager = CometChatSoundManager()
    
    @discardableResult
    public init(uiKitSettings: UIKitSettings, result: @escaping (Result<Bool, Error>) -> Void) {
        CometChat.init(appId: uiKitSettings.appID, appSettings: AppSettings(builder: uiKitSettings.appSettingsBuilder)) { [weak self] isSuccess  in
            CometChatUIKit.uiKitSettings = uiKitSettings
            if isSuccess {
                CometChat.setSource(resource: "uikit-v4", platform: "ios", language: "swift")
                #if canImport(CometChatCallsSDK)
                if !uiKitSettings.isCallingDisabled {
                    CallingExtension.enable()
                }
                #endif
                CometChatUIKit.configureExtensions(extensions: uiKitSettings.extensions)
                CometChatUIKit.registerForVOIP(with: uiKitSettings.voipToken)
                CometChatUIKit.registerForPushNotification(with: uiKitSettings.deviceToken)
                CometChatUIKit.registerForFCM(with: uiKitSettings.fcmKey)
            }
            result(.success(isSuccess))
        } onError: { error in
            result(.failure(error as! Error))
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
        registerForVOIP(with: uiKitSettings?.voipToken)
        registerForPushNotification(with: uiKitSettings?.deviceToken)
        registerForFCM(with: uiKitSettings?.fcmKey)
    }
    
    static public func login(authToken: String, result: @escaping (ApiStatus) -> Void) {
        if getLoggedInUser() != nil {
            CometChat.login(authToken: authToken) {  user in
                registerNotificationAndVOIP()
                result(.success(user))
                
            } onError: { error in
                result(.onError(error))
                debugPrint(error.description)
            }
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
    
    static public func login(uid: String, result: @escaping (ApiStatus) -> Void) {
        guard let authKey = CometChatUIKit.uiKitSettings?.authKey else { return result(.onError(uiKitError))}
        if (getLoggedInUser() == nil) || (getLoggedInUser()?.uid != uid) {
            CometChat.login(UID: uid, authKey: authKey) { user in
                registerNotificationAndVOIP()
                result(.success(user))
                CometChatUIKit.configureExtensions(extensions: CometChatUIKit.uiKitSettings?.extensions)
            } onError: { error in
                result(.onError(error))
                debugPrint(error.description)
            }
        }
    }
    
   static public func create(user: User, result: @escaping (ApiStatus) -> Void) {
        guard let authKey = CometChatUIKit.uiKitSettings?.authKey else { return result(.onError(uiKitError)) }
        CometChat.createUser(user: user, authKey: authKey) { user in
            result(.success(user))
        } onError: { error in
            if let error = error {
                result(.onError(error))
                debugPrint(error.description)
            }
        }
    }
    
    static public func update(user: User, result: @escaping (ApiStatus) -> Void) {
        guard let authKey = CometChatUIKit.uiKitSettings?.authKey else { return result(.onError(uiKitError)) }
        CometChat.updateUser(user: user, authKey: authKey) { user in
            result(.success(user))
        } onError: { error in
            if let error = error {
                result(.onError(error))
                debugPrint(error.description)
            }
        }
    }
    
    static public func logout(user: User, result: @escaping (ApiStatus) -> Void) {
        CometChat.logout { isSuccess in
            result(.success(user))
        } onError: { error in
            result(.onError(error))
            debugPrint(error.description)
        }
    }
    
    static public func getLoggedInUser() -> User? {
        guard let user = CometChat.getLoggedInUser() else { return nil }
        return user
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


extension CometChatUIKit {
    static public func getDataSource() -> DataSource {
        return ChatConfigurator.getDataSource()
    }
}
