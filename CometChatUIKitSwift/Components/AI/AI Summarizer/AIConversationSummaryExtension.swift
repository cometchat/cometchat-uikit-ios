//
//  AIConversationSummaryExtension.swift
//  
//
//  Created by SuryanshBisen on 20/10/23.
//

import Foundation
import CometChatSDK

public class AIConversationSummaryExtension: ExtensionDataSource {
    
    private let configuration: AIConversationSummaryConfiguration?
    
    public init(configuration: AIConversationSummaryConfiguration? = nil) {
        self.configuration = configuration
        super.init()
    }
    
    override public func enable() {
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
            return AIConversationSummaryDecorator(dataSource: dataSource, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.aiConversationSummary
    }
    
    internal func getConfiguration() -> AIConversationSummaryConfiguration? {
        return configuration
    }

    
}
