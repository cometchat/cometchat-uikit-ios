//
//  AIEnablerConfiguration.swift
//
//
//  Created by SuryanshBisen on 14/09/23.
//

import Foundation
import UIKit

public class AIEnablerConfiguration: AIParentConfiguration {
    
    private(set) var style: AIEnablerStyle?
    private(set) var auxiliaryButtonIcon: UIImage?
    
    @discardableResult
    @objc public func set(style: AIEnablerStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    @objc public func set(auxiliaryButtonIcon: UIImage) -> Self {
        self.auxiliaryButtonIcon = auxiliaryButtonIcon
        return self
    }
}
