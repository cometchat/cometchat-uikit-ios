//
//  File.swift
//  
//
//  Created by Ajay Verma on 20/03/23.
//

import Foundation
import CometChatSDK

public class ExtensionDataSource {
    public func enable() {
        CometChat.isExtensionEnabled(extensionId: getExtensionId(), onSuccess: {
            success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })
    }
    
    public func addExtension() {}
    
    public func getExtensionId() -> String {
        return ""
    }
}
