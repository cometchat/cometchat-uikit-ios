//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//
import Foundation

class CollaborativeDocumentConfiguration{}

public class CollaborativeDocumentExtension: ExtensionDataSource {
        
    public override init() {}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return CollaborativeDocumentViewModel(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.document
    }
}
