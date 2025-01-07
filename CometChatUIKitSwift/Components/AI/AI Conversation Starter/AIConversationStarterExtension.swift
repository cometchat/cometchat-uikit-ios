//
//  CometChatAIConversationStarterExtension.swift
//  
//
//  Created by SuryanshBisen on 13/09/23.
//

import Foundation
import CometChatSDK

public class AIConversationStarterExtension: ExtensionDataSource {
    
    private let configuration: AIConversationStarterConfiguration?
    private let extensionName = "Conversation Starter"
    
    public init(configuration: AIConversationStarterConfiguration? = nil) {
        self.configuration = configuration
        super.init()
    }
    
    public override func enable() {
        CometChat.isAIFeatureEnabled(feature: getExtensionId(), onSuccess: {
            success in
            if success {
                self.addExtension()
            }
        }, onError: {
            _ in
        })
    }
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return AIConversationStarterDecorator(dataSource: dataSource, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.aiConversationStarter
    }
    
    func getConfiguration() -> AIConversationStarterConfiguration? {
        return configuration
    }
    
    func getExtensionName() -> String {
        return extensionName
    }
}
