//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import UIKit
import CometChatPro
import UserNotifications
import PushKit
import CallKit
import AudioToolbox
import AVKit

public class CallingExtension: NSObject {
    
    public static func enable(_ configuration: CallingConfiguration? = nil) {
        ChatConfigurator.enable { dataSource in
            return CallingExtensionDecorator(dataSource: dataSource, configuration: configuration)
        }
    }
  
}


