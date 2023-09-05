//
//  ProfanityDataMaskingExtension.swift
//  
//
//  Created by Pushpsen Airekar on 21/02/23.
//
import Foundation

public class ReactionExtension: ExtensionDataSource {
    
    public override init(){}
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return ReactionExtensionDecorator(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.reactions
    }
}
