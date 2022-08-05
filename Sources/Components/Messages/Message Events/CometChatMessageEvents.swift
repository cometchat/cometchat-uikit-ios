//
//  CometChatMessageEvents.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatPro
import Foundation




public protocol CometChatMessageEventListner {
    
    func onMessageSent(message: BaseMessage, status: UIKitConstants.MessageStatusConstants)
    func onMessageEdit(message: BaseMessage, status: UIKitConstants.MessageStatusConstants)
    func onMessageDelete(message: BaseMessage, status: UIKitConstants.MessageStatusConstants)
    func onMessageReply(message: BaseMessage, status: UIKitConstants.MessageStatusConstants)
    func onMessageRead(message: BaseMessage)
    func onLiveReaction(reaction: TransientMessage)
    func onMessageError(error: CometChatException)
    func onVoiceCall(user: User)
    func onVoiceCall(group: Group)
    func onVideoCall(user: User)
    func onVideoCall(group: Group)
    func onViewInformation(user: User)
    func onViewInformation(group: Group)
    func onError(message: BaseMessage?, error: CometChatException)
    func onMessageReact(message: BaseMessage, reaction: CometChatMessageReaction)
    
}



public class CometChatMessageEvents {
    
    static private var observer = [String: CometChatMessageEventListner]()
    
     public static func addListener(_ id: String,_ observer: CometChatMessageEventListner) {
        self.observer[id] = observer
    }
    
     public static func removeListner(_ id: String) {
        self.observer.removeValue(forKey: id)
    }
    
    internal static  func emitOnMessageSent(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        self.observer.forEach({
            (key,observer) in
            observer.onMessageSent(message: message, status: status)
        })
    }
    internal static  func emitOnMessageEdit(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        self.observer.forEach({
            (key,observer) in
            observer.onMessageEdit(message: message, status: status)
        })
    }
    internal static  func emitOnMessageDelete(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        self.observer.forEach({
            (key,observer) in
            observer.onMessageDelete(message: message, status: status)
        })
    }
    internal static  func emitOnMessageReply(message: BaseMessage, status: UIKitConstants.MessageStatusConstants) {
        self.observer.forEach({
            (key,observer) in
            observer.onMessageReply(message: message, status: status)
        })
        
    }
    internal static  func emitOnMessageRead(message: BaseMessage) {
        self.observer.forEach({
            (key,observer) in
            observer.onMessageRead(message: message)
        })
    }
    
    internal static  func emitOnLiveReaction(reaction: TransientMessage) {
        self.observer.forEach({
            (key,observer) in
            observer.onLiveReaction(reaction: reaction)
        })
    }
    
    internal static  func emitOnVoiceCall(user: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onVoiceCall(user: user)
        })
    }
    internal static  func emitOnVoiceCall(group: Group) {
        self.observer.forEach({
            (key,observer) in
            observer.onVoiceCall(group: group)
        })
    }
    internal static  func emitOnVideoCall(user: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onVideoCall(user: user)
        })
    }
    internal static  func emitOnVideoCall(group: Group) {
        self.observer.forEach({
            (key,observer) in
            observer.onVideoCall(group: group)
        })
    }
    internal static  func emitOnViewInformation(user: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onViewInformation(user: user)
        })
    }
    internal static  func emitOnViewInformation(group: Group) {
        self.observer.forEach({
            (key,observer) in
            observer.onViewInformation(group: group)
        })
    }
    internal static  func emitOnError(message: BaseMessage?, error: CometChatException) {
        self.observer.forEach({
            (key,observer) in
            observer.onError(message: message, error: error)
        })
    }
    internal static  func emitOnMessageReact(message: BaseMessage, reaction: CometChatMessageReaction) {
        self.observer.forEach({
            (key,observer) in
            observer.onMessageReact(message: message, reaction: reaction)
        })
    }
}
