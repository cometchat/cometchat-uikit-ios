//
//  InputData.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 22/03/22.
//

import Foundation
import CometChatPro


public class InputData : NSObject {
    
    var id: Bool?
    var title: Bool?
    var subtitle: ((_ object: AnyObject) -> String)?
    var thumbnail: Bool?
    var status: Bool?
   
    
    override init() { }
    
    public init(title: Bool?, thumbnail: Bool?, status: Bool?, subtitle: ((_ object: AnyObject) -> String)?) {
        self.title = title
        self.subtitle = subtitle
        self.thumbnail = thumbnail
        self.status = status
    }
}


public class ConversationInputData : InputData {
    
    var unreadCount: Bool?
    var readReceipt: Bool?
    var timestamp: Bool?
    
    public init(title: Bool?, thumbnail: Bool?, status: Bool?, unreadCount: Bool?, readReceipt: Bool?, timestamp: Bool?, subtitle: ((_ object: AnyObject) -> String)?) {
        super.init()
        self.thumbnail = thumbnail
        self.status = status
        self.unreadCount = unreadCount
        self.readReceipt = readReceipt
        self.timestamp = timestamp
        self.title = title
        self.subtitle = subtitle
    }
    
}

public class SentMessageInputData : InputData {
    
    var timestamp: Bool?
    var readReceipt: Bool?
    
    public init(title: Bool?, thumbnail: Bool?, readReceipt: Bool?,  timestamp: Bool?) {
        super.init()
        self.title = title
        self.thumbnail = thumbnail
        self.readReceipt = readReceipt
        self.timestamp = timestamp
    }
}


public class ReceivedMessageInputData : InputData {
    
    var timestamp: Bool?
    var readReceipt: Bool?
    
    public init(title: Bool?, thumbnail: Bool?, readReceipt: Bool?,  timestamp: Bool?) {
        super.init()
        self.title = title
        self.thumbnail = thumbnail
        self.readReceipt = readReceipt
        self.timestamp = timestamp
    }
}

