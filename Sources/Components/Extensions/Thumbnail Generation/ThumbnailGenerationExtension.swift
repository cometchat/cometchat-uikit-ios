//
//  File.swift
//  Created by Pushpsen Airekar on 20/02/23.

import Foundation

public class ThumbnailGenerationExtension: ExtensionDataSource {
    
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return ThumbnailGenerationViewModel(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.thumbnailGeneration
    }
}

