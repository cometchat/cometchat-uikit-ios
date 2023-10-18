//
//  CometChatAIConversationStarterExtension.swift
//  
//
//  Created by SuryanshBisen on 13/09/23.
//

import Foundation

public class AIConversationStarterExtension: ExtensionDataSource {
    
    private let configuration: AIConversationStarterConfiguration?
    private let extensionName = "Conversation Starter"
    private var enablerConfiguration: AIEnablerConfiguration?
    
    public init(configuration: AIConversationStarterConfiguration? = nil) {
        self.configuration = configuration
        super.init()
    }
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return AIConversationStarterDecorator(dataSource: dataSource, configuration: configuration, enablerConfiguration: enablerConfiguration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.aiConversationStarter
    }
    
    func set(enablerConfiguration: AIEnablerConfiguration?){
        self.enablerConfiguration = enablerConfiguration
    }
    
    func getConfiguration() -> AIConversationStarterConfiguration? {
        return configuration
    }
    
    func getExtensionName() -> String {
        return extensionName
    }
}
