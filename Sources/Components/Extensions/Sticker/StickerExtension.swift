//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 15/02/23.
//

import Foundation


public class CometChatStickerExtension: ExtensionDataSource {
    
    var configuration: StickerConfiguration?
    
    public init(configuration: StickerConfiguration? = nil) {
        self.configuration = configuration
    }
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return StickersExtensionDecorator(dataSource: dataSource, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.stickers
    }
    
}

