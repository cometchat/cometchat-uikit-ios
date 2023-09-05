//
//  CollaborativeWhiteboardExtension.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//
import Foundation

public class CometChatPollsExtension: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return CometChatPollsViewModel(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.polls
    }
    
}
