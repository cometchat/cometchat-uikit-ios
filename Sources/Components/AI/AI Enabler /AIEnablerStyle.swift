//
//  AIEnableStyle.swift
//
//
//  Created by SuryanshBisen on 04/10/23.
//

import Foundation
import UIKit

public class AIEnablerStyle: AIParentRepliesStyle {
    
    private(set) var bottomSheetBackgroundColour: UIColor?
    private(set) var auxiliaryButtonTintColour: UIColor?
    
    @discardableResult
    @objc public func set(bottomSheetBackgroundColour: UIColor) -> Self {
        self.bottomSheetBackgroundColour = bottomSheetBackgroundColour
        return self
    }
    
    @discardableResult
    @objc public func set(auxiliaryButtonTintColour: UIColor) -> Self {
        self.auxiliaryButtonTintColour = auxiliaryButtonTintColour
        return self
    }
}
