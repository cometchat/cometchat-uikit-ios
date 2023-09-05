//
//  CollaborativeWhiteboardExtension.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//
import Foundation

class CollaborativeWhiteboardConfiguration{}

public class CollaborativeWhiteboardExtension: ExtensionDataSource {
    
    public override init() {}
        
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return CollaborativeWhiteboardViewModel(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.whiteboard
    }
}
