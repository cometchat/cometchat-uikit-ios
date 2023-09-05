//
//  MessageTranslationExtension.swift
//  
//
//  Created by Ajay Verma on 24/02/23.
//

import Foundation

public class MessageTranslationExtension: ExtensionDataSource {
    
    public override init(){}
        
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return MessageTranslationViewModel(dataSource: dataSource)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.messageTranslation
    }
}
