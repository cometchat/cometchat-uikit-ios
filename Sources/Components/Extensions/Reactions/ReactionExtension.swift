//
//  ProfanityDataMaskingExtension.swift
//  
//
//  Created by Pushpsen Airekar on 21/02/23.
//
import Foundation

public class ReactionExtension: ExtensionDataSource {
    
    public init(){}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
           return ReactionExtensionDecorator(dataSource: dataSource)
        }
  }
}
