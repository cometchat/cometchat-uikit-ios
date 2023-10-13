//
//  CometChatAIConversationStartersExtension.swift
//  
//
//  Created by SuryanshBisen on 13/09/23.
//

import Foundation

public class CometChatAIConversationStartersExtension: ExtensionDataSource {
    
    let configuration: AIConversationStartersConfiguration?
    let extensionName = "Conversation Starters"
    var enablerConfiguration: AIEnablerConfiguration?
    
    public init(configuration: AIConversationStartersConfiguration? = nil) {
        self.configuration = configuration
        super.init()
    }
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return AIConversationStartersDecorator(dataSource: dataSource, configuration: configuration, enablerConfiguration: enablerConfiguration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.aiConversationStarters
    }
    
    func set(enablerConfiguration: AIEnablerConfiguration?){
        self.enablerConfiguration = enablerConfiguration
    }
    
    func getConfiguration() -> AIConversationStartersConfiguration? {
        return configuration
    }
    
    func getExtensionName() -> String {
        return extensionName
    }
}
