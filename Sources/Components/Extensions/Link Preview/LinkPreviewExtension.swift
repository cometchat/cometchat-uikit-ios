//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 19/02/23.
//

import Foundation

public class CometChatLinkPreviewExtension: ExtensionDataSource {
    
    public init(){}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
            return LinkPreviewViewModel(dataSource: dataSource)
        }
    }
    
}
