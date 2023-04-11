//
//  File.swift
//  Created by Pushpsen Airekar on 20/02/23.

import Foundation

public class ThumbnailGenerationExtension: ExtensionDataSource {
    
    public init() {}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
            return ThumbnailGenerationViewModel(dataSource: dataSource)
        }
    }
}

