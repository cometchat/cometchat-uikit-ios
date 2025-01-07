//
//  AIAssistBotExtension.swift
//
//
//  Created by SuryanshBisen on 31/10/23.
//

import Foundation
import CometChatSDK

public class AIAssistBotExtension: ExtensionDataSource {
    
    private let configuration: AIAssistBotConfiguration?
    
    public init(configuration: AIAssistBotConfiguration? = nil) {
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
            return AIAssistBotDecorator(dataSource: dataSource, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.aiAssistBot
    }

}
