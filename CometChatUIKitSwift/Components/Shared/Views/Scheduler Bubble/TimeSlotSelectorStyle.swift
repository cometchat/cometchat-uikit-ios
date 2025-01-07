//
//  TimeSlotSelectorStyle.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 04/01/24.
//

import Foundation
import UIKit

public class TimeSlotSelectorStyle: BaseStyle {
    
    private(set) var titleFont: UIFont = CometChatTheme_v4.typography.text1
    private(set) var titleColor: UIColor = CometChatTheme_v4.palatte.accent800
    private(set) var slotTextFont: UIFont = CometChatTheme_v4.typography.caption1
    private(set) var slotTextColor: UIColor = CometChatTheme_v4.palatte.accent700
    private(set) var selectedSlotBackgroundColor: UIColor?
    private(set) var selectedSlotTextColor: UIColor?
    
    public override init() {
        super.init()
        self.background = .clear
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(slotTextFont: UIFont) -> Self {
        self.slotTextFont = slotTextFont
        return self
    }
    
    @discardableResult
    public func set(slotTextColor: UIColor) -> Self {
        self.slotTextColor = slotTextColor
        return self
    }
    
    @discardableResult
    public func set(selectedSlotBackgroundColor: UIColor) -> Self {
        self.selectedSlotBackgroundColor = selectedSlotBackgroundColor
        return self
    }
    
    @discardableResult
    public func set(selectedSlotTextColor: UIColor) -> Self {
        self.selectedSlotTextColor = selectedSlotTextColor
        return self
    }
}
