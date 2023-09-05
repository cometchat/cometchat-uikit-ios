//
//  MediaRecorderStyle.swift
//
//
//  Created by Abhishek Saralaya on 10/08/23.
//

import UIKit

public final class MediaRecorderStyle: BaseStyle {
    
    private(set) var pauseIconTint = CometChatTheme.palatte.primary
    private(set) var playIconTint = CometChatTheme.palatte.primary
    private(set) var deleteIconTint = CometChatTheme.palatte.error
    private(set) var timerTextFont = CometChatTheme.typography.text1
    private(set) var timerTextColor = CometChatTheme.palatte.primary
    private(set) var startIconTint = CometChatTheme.palatte.secondary
    private(set) var stopIconTint = CometChatTheme.palatte.error
    private(set) var submitIconTint = CometChatTheme.palatte.primary
    override var background: UIColor {
        get {
            return CometChatTheme.palatte.secondary
        }
        set {
            super.background = newValue
        }
    }
    
    override public func set(background: UIColor) -> Self {
        self.background = background
        return self
    }
    
    @discardableResult
    public func set(pauseIconTint: UIColor) -> Self {
        self.pauseIconTint = pauseIconTint
        return self
    }
    
    @discardableResult
    public func set(playIconTint: UIColor) -> Self {
        self.playIconTint = playIconTint
        return self
    }
    
    @discardableResult
    public func set(deleteIconTint: UIColor) -> Self {
        self.deleteIconTint = deleteIconTint
        return self
    }
    
    @discardableResult
    public func set(timerTextFont: UIFont) -> Self {
        self.timerTextFont = timerTextFont
        return self
    }
    
    @discardableResult
    public func set(timerTextColor: UIColor) -> Self {
        self.timerTextColor = timerTextColor
        return self
    }
    
    @discardableResult
    public func set(submitIconTint: UIColor) -> Self {
        self.submitIconTint = submitIconTint
        return self
    }
    
    @discardableResult
    public func set(startIconTint: UIColor) -> Self {
        self.startIconTint = startIconTint
        return self
    }
    
    @discardableResult
    public func set(stopIconTint: UIColor) -> Self {
        self.stopIconTint = stopIconTint
        return self
    }
}


