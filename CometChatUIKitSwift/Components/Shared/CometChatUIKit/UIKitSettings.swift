//
//  AuthenticationSettings.swift
//  
//
//  Created by Abdullah Ansari on 11/08/22.
//

import Foundation
import CometChatSDK

final public class UIKitSettings {
    
    var region = ""
    var authKey = ""
    var appID = ""
    var deviceToken = ""
    var voipToken = ""
    var fcmKey = ""
    var googleApiKey = ""
    var stripeKey = ""
    var isCallingDisabled: Bool = false
    var enableIncomingCall = false
    var appSettingsBuilder:  AppSettings.AppSettingsBuilder!
    var extensions:  [ExtensionDataSource]?
    var aiExtensions: [ExtensionDataSource]?
    
    #if canImport(CometChatCallsSDK)
    var callingExtensions: CallingExtension?
    #endif
    
    
    public init() {
        appSettingsBuilder = AppSettings.AppSettingsBuilder()
        if NSClassFromString("CometChatCallsSDK.CometChatCalls") == nil {
            isCallingDisabled = true
        }
    }
    
    @discardableResult
    public func enable(inAppIncomingCall: Bool) -> Self {
        self.enableIncomingCall = inAppIncomingCall
        return self
    }
    
    @discardableResult
    public func set(appID: String) -> Self {
        self.appID = appID
        return self
    }
    
    @discardableResult
    public func set(authKey: String) -> Self {
        self.authKey = authKey
        return self
    }
    
    @discardableResult
    public func set(region: String) -> Self {
        self.region = region
        return self
    }
    
    @discardableResult
    public func set(deviceToken: String) -> Self {
        self.deviceToken = deviceToken
        return self
    }
    
    @discardableResult
    public func set(voipToken: String) -> Self {
        self.voipToken = voipToken
        return self
    }
    
    @discardableResult
    public func enable(extensions: [ExtensionDataSource]) -> Self {
        self.extensions = extensions
        return self
    }
    
    @discardableResult
    public func enable(aiExtensions: [ExtensionDataSource]) -> Self {
        self.aiExtensions = aiExtensions
        return self
    }
    
    @discardableResult
    public func set(fcmKey: String) -> Self {
        self.fcmKey = fcmKey
        return self
    }
    
    @discardableResult
    public func set(googleApiKey: String) -> Self {
        self.googleApiKey = googleApiKey
        return self
    }
    
    @discardableResult
    public func set(stripeKey: String) -> Self {
        self.stripeKey = stripeKey
        return self
    }
    
    @discardableResult
    public func disableCalling() -> Self {
        self.isCallingDisabled = true
       return self
    }
    
    @discardableResult
    public func setEnableAutoJoinForGroups(enableAutoJoinForGroups: Bool) -> Self {
        appSettingsBuilder.setEnableAutoJoinForGroups(enableAutoJoinForGroups: enableAutoJoinForGroups)
        return self
    }
    
    @discardableResult
    public func setExtensionGroupID(id: String) -> Self {
        appSettingsBuilder.setExtensionGroupID(id: id)
        return self
    }
    
    @discardableResult
    public func subscribePresenceForAllUsers() -> Self {
        appSettingsBuilder.subscribePresenceForAllUsers()
        return self
    }
    
    @discardableResult
    public func subcribePresenceForRoles(roles: [String]) -> Self {
        appSettingsBuilder.subcribePresenceForRoles(roles: roles)
        return self
    }
    
    @discardableResult
    public func subscribePresenceForFriends() -> Self {
        appSettingsBuilder.subscribePresenceForFriends()
        return self
    }
    
    @discardableResult
    public func autoEstablishSocketConnection(bool: Bool) -> Self {
        appSettingsBuilder.autoEstablishSocketConnection(bool)
        return self
    }
    
    @discardableResult
    public func overrideAdminHost(_ adminHost: String) -> Self {
        appSettingsBuilder.overrideAdminHost(adminHost)
        return self
    }
    
    @discardableResult
    public func overrideClientHost(_ clientHost: String) -> Self {
        appSettingsBuilder.overrideClientHost(clientHost)
        return self
    }
    
#if canImport(CometChatCallsSDK)
    @discardableResult
    public func set(callingExtensions: CallingExtension) -> Self {
        self.callingExtensions = callingExtensions
        return self
    }
#endif
    
    @discardableResult
    public func build() -> Self {
        self.appSettingsBuilder.setRegion(region: self.region)
        self.appSettingsBuilder.autoEstablishSocketConnection(true)
        self.appSettingsBuilder.build()
        return self
    }
        
    func clear() {
        region = ""
        authKey = ""
        appID = ""
        deviceToken = ""
        voipToken = ""
        fcmKey = ""
        googleApiKey = ""
        stripeKey = ""
    }
}
