//
//  AIEnablerConfiguration.swift
//
//
//  Created by SuryanshBisen on 14/09/23.
//

import Foundation
import UIKit

public class AIEnablerConfiguration: AIParentConfiguration {
    
    var style: AIEnableStyle?
    
    @discardableResult
    @objc public func set(style: AIEnableStyle) -> Self {
        self.style = style
        return self
    }

}
