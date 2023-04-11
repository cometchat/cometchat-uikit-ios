//
//  CometChatSmartReplyExtension.swift
//  
//
//  Created by Pushpsen Airekar on 16/02/23.
//
import Foundation

public class CometChatSmartReplyExtension: ExtensionDataSource {
    
    public init() {}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
           return SmartReplyExtensionDecorator(dataSource: dataSource)
        }
  }
}

