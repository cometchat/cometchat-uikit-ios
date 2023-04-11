//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 20/02/23.
//

import Foundation

import Foundation

public class CometChatImageModerationExtension: ExtensionDataSource {
    
    public init() {}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
            return ImageModetarationViewModel(dataSource: dataSource)
        }
    }
}
