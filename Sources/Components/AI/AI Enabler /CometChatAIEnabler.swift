//
//  CometChatAIEnabler.swift
//  
//
//  Created by SuryanshBisen on 12/09/23.
//

import Foundation
import CometChatSDK

public class CometChatAIEnabler: ExtensionDataSource {
    
    var aiList: [ExtensionDataSource]
    var enabledAiExtensionList = [ExtensionDataSource]()
    var configuration: AIEnablerConfiguration? 
    
    public init(aiList: [ExtensionDataSource]? = nil, configuration: AIEnablerConfiguration? = nil) {
        
        if let aiList = aiList {
            self.aiList = aiList
        }else {
            self.aiList = DefaultExtensions.listOfAIExtensions()
        }
        
        self.configuration = configuration
    }
    
    public override func addExtension() {
        ChatConfigurator.enable { dataSource in
            return AIEnablerDecorator(dataSource: dataSource, enabledAiOptions: enabledAiExtensionList, configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return ExtensionConstants.aiExtension
    }
    
    public override func enable() {
        
        for aiExtension in aiList {
            
            let featureId = aiExtension.getExtensionId()
            
            CometChat.isAIFeatureEnabled(feature: featureId) { isEnabled in
                
                if isEnabled {
                    
                    if let aiExtension = aiExtension as? CometChatAIConversationStartersExtension {
                        aiExtension.set(enablerConfiguration: self.configuration)
                        aiExtension.addExtension()
                        return
                    }
                    
                    aiExtension.addExtension()
                    self.enabledAiExtensionList.append(aiExtension)
                
                } else {
                    print("\(featureId): is not enabled from the dashboard")
                }
                
            } onError: { error in
                print("error while checking isAIFeatureEnabled for ID \(featureId): \(String(describing: error?.errorDescription)) ")
            }
            
        }
        
        if enabledAiExtensionList.count > 0 {
            self.addExtension()
        }
    }
}
