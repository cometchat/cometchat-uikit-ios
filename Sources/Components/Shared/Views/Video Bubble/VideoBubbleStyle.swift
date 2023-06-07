//
//  VideoBubbleStyle.swift
 
//
//  Created by Abdullah Ansari on 23/05/22.
//

import Foundation
import UIKit

public class VideoBubbleStyle: BaseStyle {
    
    var activityIndicatorTint: UIColor = CometChatTheme.palatte.primary
    var playIconTint: UIColor = CometChatTheme.palatte.background
    var playIconBackgroundColor = CometChatTheme.palatte.accent200
    
    override var borderWidth: CGFloat {
        get {
            return 1.0
        }
        
        set {
            super.borderWidth = newValue
        }
    }
    
    @discardableResult
    public func set(activityIndicatorTint: UIColor) -> Self {
        self.activityIndicatorTint = activityIndicatorTint
        return self
    }
    
    @discardableResult
    public func set(playIconTint: UIColor) -> Self {
        self.playIconTint = playIconTint
        return self
    }
    
    @discardableResult
    public func set(playIconBackgroundColor: UIColor) -> Self {
        self.playIconBackgroundColor = playIconBackgroundColor
        return self
    }
    
    
}
