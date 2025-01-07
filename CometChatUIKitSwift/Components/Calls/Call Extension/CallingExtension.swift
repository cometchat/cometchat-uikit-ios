//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import UIKit

#if canImport(CometChatCallsSDK)
public class CallingExtension: ExtensionDataSource {
    
    private let configuration: CallingConfiguration?

    public init(configuration: CallingConfiguration? = nil) {
        self.configuration = configuration
        super.init()
    }
    
    public override func enable() {
        ChatConfigurator.enable { dataSource in
            return CallingExtensionDecorator(dataSource: dataSource,configuration: configuration)
        }
    }
    
    public override func getExtensionId() -> String {
        return "Calling-Extension"
    }
  
}
#endif


