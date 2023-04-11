//
//  CollaborativeWhiteboardExtension.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//
import Foundation

public class CometChatPollsExtension: ExtensionDataSource {
    
    public init() {}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
           return CometChatPollsViewModel(dataSource: dataSource)
        }
  }
}
