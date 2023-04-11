//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//
import Foundation

class CollaborativeDocumentConfiguration{}

public class CollaborativeDocumentExtension: ExtensionDataSource {
    
    public init() {}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
           return CollaborativeDocumentViewModel(dataSource: dataSource)
        }
  }
}
