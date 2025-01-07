//
//  AppDelegate + VoIP.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 07/09/23.
//

#if canImport(CometChatCallsSDK)

import Foundation
import PushKit
import CallKit
import CometChatSDK
import CometChatCallsSDK


extension AppDelegate: PKPushRegistryDelegate, CXProviderDelegate {
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        cometchatAPNsHelper.registerForVoIPCalls(pushCredentials: pushCredentials)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("VoIP push token invalidated for type: \(type.rawValue)")
        initializePushKit()
        refreshPushCredentials()
        // Handle invalidated push token, perhaps re-register
    }
    
    func initializePushKit() {
        if pushRegistry == nil {
            pushRegistry = PKPushRegistry(queue: DispatchQueue.main)
            pushRegistry.delegate = self
            pushRegistry.desiredPushTypes = [.voIP]
            print("Push registry initialized")
        } else {
            print("Push registry already initialized")
        }
        
    }
    
    func refreshPushCredentials() {
        guard let pushRegistry = pushRegistry else {
            print("Push registry is nil")
            return
        }
        pushRegistry.desiredPushTypes = []
        pushRegistry.desiredPushTypes = [.voIP]
        print("VoIP token registered and deregistered")
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        //provider will only return when new call is trigged if its an update to an exciting call than it will just return nil
        let provider = cometchatAPNsHelper.didReceiveIncomingPushWith(payload: payload)
        provider?.setDelegate(self, queue: nil)
        completion()
    }
    
    func providerDidReset(_ provider: CXProvider) {
        cometchatAPNsHelper.onProviderDidReset(provider: provider)
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        cometchatAPNsHelper.onAnswerCallAction(action: action)
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        cometchatAPNsHelper.onEndCallAction(action: action)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        CometChatCalls.audioMuted(action.isMuted)
        action.fulfill()
    }
    
}


#endif
