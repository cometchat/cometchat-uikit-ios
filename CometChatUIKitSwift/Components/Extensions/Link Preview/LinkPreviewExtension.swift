//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 19/02/23.
//

import Foundation

public class CometChatLinkPreviewExtension: ExtensionDataSource {
    
    public override init(){}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return LinkPreviewViewModel(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.linkPreview
    }
}
