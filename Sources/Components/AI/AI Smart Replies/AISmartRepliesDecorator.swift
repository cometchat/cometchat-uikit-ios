//
//  AISmartRepliesDecorator.swift
//  
//
//  Created by SuryanshBisen on 12/09/23.
//

import Foundation
import CometChatSDK

class AISmartRepliesDecorator: DataSourceDecorator {
    
    let configuration: AISmartRepliesConfiguration?
    
    public init(dataSource: DataSource, configuration: AISmartRepliesConfiguration? = nil) {
        self.configuration = configuration
        super.init(dataSource: dataSource)
    }
    
    override func getId() -> String {
        return ExtensionConstants.aiSmartReply
    }
    
}
