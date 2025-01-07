//
//  ProfanityDataMaskingExtension.swift
//  
//
//  Created by Pushpsen Airekar on 21/02/23.
//
import Foundation
import CometChatSDK

public class ProfanityDataMaskingExtension: ExtensionDataSource {
    
    public override init() {}
    
    var addedExtension = true
    
    public override func addExtension() {
        if addedExtension {
            ChatConfigurator.enable { dataSource in
                return ProfanityDataMaskingExtensionDecorator(dataSource: dataSource)
            }
            addedExtension = false
        }
    }
    
    public override func enable() {
        CometChat.isExtensionEnabled(extensionId: ExtensionConstants.profanityFilter, onSuccess: {success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })
        
        CometChat.isExtensionEnabled(extensionId: getExtensionId(), onSuccess: {success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.dataMasking
    }
    
}
