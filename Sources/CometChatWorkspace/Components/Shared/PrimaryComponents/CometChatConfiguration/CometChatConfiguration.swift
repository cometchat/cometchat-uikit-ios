//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation

public class CometChatConfiguration: NSObject {
 
    private static var  configurations: [CometChatConfiguration]?
 

    public static func set(configurations: [CometChatConfiguration] ) {
        self.configurations = configurations
    }
    
    
   
    
}

