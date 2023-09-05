//
//  CometChatSmartReplyExtension.swift
//  
//
//  Created by Pushpsen Airekar on 16/02/23.
//
import Foundation

public class CometChatSmartReplyExtension: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return SmartReplyExtensionDecorator(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.smartReply
    }
}

