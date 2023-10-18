//
//  CometChatAISmartRepliesExtension.swift
//  
//
//  Created by SuryanshBisen on 12/09/23.
//

import Foundation


public class AISmartRepliesExtension: ExtensionDataSource {
    
    private let configuration: AISmartRepliesConfiguration?
    private let extensionText = AIConstants.smartRepliesText
        
    public init(configuration: AISmartRepliesConfiguration? = nil) {
        self.configuration = configuration
        super.init()
    }
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return AISmartRepliesDecorator(dataSource: dataSource, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.aiSmartReply
    }
    
    public func getConfiguration() -> AISmartRepliesConfiguration? {
        return configuration
    }
    
    func getExtensionText() -> String {
        return extensionText
    }
}
