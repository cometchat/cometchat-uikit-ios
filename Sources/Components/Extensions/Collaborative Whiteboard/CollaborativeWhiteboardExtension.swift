//
//  CollaborativeWhiteboardExtension.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//
import Foundation

class CollaborativeWhiteboardConfiguration{}

public class CollaborativeWhiteboardExtension: ExtensionDataSource {
    
    public init() {}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
           return CollaborativeWhiteboardViewModel(dataSource: dataSource)
        }
  }
}
