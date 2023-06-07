//
//  DateConfiguration.swift
 
//
//  Created by Pushpsen Airekar on 02/06/22.
//

import UIKit

public class DateConfiguration  {
    
    var pattern: CometChatDatePattern?
    var customFormat: DateFormatter?
    var dateStyle: DateStyle?
    
    public init() {}

    
    @discardableResult
    public func set(customFormat: DateFormatter) -> Self {
        self.customFormat = customFormat
        return self
    }
    
    @discardableResult
    public func set(dateStyle: DateStyle) -> Self {
        self.dateStyle = dateStyle
        return self
    }
    
    
    @discardableResult
    public func set(pattern: CometChatDatePattern?) -> Self {
        self.pattern = pattern
        return self
    }
    
    
//    @discardableResult
//    @objc public func set(customPattern: @escaping ( _ timestamp: Int)->(String?)) -> Self {
//        if let timestamp = self.timestamp, let customFormat = customPattern(timestamp) {
//
//            self.customFormat = customFormat
//        }
//
        
//        return self
//      }
       
    
}
