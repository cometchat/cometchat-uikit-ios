//
//  MessageTranslationExtension.swift
//  
//
//  Created by Ajay Verma on 24/02/23.
//

import Foundation

public class MessageTranslationExtension: ExtensionDataSource {
    
    public init(){}
    
    public func enable() {
        ChatConfigurator.enable { dataSource in
           return MessageTranslationViewModel(dataSource: dataSource)
        }
  }

}
