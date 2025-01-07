//
//  CometChatAISmartRepliesExtension.swift
//  
//
//  Created by SuryanshBisen on 12/09/23.
//

import Foundation
import CometChatSDK


public class AISmartRepliesExtension: ExtensionDataSource {
    
    private let configuration: AISmartRepliesConfiguration?
        
    public init(configuration: AISmartRepliesConfiguration? = nil) {
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
            return AISmartRepliesDecorator(dataSource: dataSource, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.aiSmartReply
    }
    
}
