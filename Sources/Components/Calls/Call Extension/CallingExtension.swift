//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import UIKit
import UserNotifications
import PushKit
import CallKit
import AudioToolbox
import AVKit


#if canImport(CometChatCallsSDK)
public class CallingExtension: NSObject {
    
    public static func enable() {
        ChatConfigurator.enable { dataSource in
            return CallingExtensionDecorator(dataSource: dataSource,configuration: nil)
        }
    }
  
}
#endif


