//
//  AIEnableStyle.swift
//
//
//  Created by SuryanshBisen on 04/10/23.
//

import Foundation
import UIKit

public class AIEnableStyle: AIParentRepliesStyle {
    var auxiliaryButtonIcon: UIImage?
    var bottomSheetBackgroundColour: UIColor?
    var auxiliaryButtonTintColour: UIColor?
    
    @discardableResult
    @objc public func setBottomSheetBackgroundColour(colour: UIColor) -> Self {
        self.bottomSheetBackgroundColour = colour
        return self
    }
    
    @discardableResult
    @objc public func setAuxiliaryButtonIcon(icon: UIImage) -> Self {
        self.auxiliaryButtonIcon = icon
        return self
    }
    
    @discardableResult
    @objc public func setAuxiliaryButtonTintColour(colour: UIColor) -> Self {
        self.auxiliaryButtonTintColour = colour
        return self
    }
}
