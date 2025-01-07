//
//  MeetingBubbleStyle.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 25/12/23.
//

import Foundation
import UIKit

public final class SchedulerBubbleStyle: BaseStyle {
    
    private(set) var timeSlotSelectorStyle = TimeSlotSelectorStyle()
    private(set) var avatarStyle: AvatarStyle?
    private(set) var messageTintColor = CometChatTheme_v4.palatte.primary
    private(set) var titleTint = CometChatTheme_v4.palatte.accent
    private(set) var titleFont = CometChatTheme_v4.typography.heading
    private(set) var dividerTint = CometChatTheme_v4.palatte.accent800
    private(set) var deactivatedTint = CometChatTheme_v4.palatte.accent
    private(set) var lisItemStyle: ListItemStyle = ListItemStyleDefault()
    
    public override init() {
        super.init()
        self.set(background: CometChatTheme_v4.palatte.secondary)
    }
    
    @discardableResult
    public func set(timeSlotSelectorStyle: TimeSlotSelectorStyle) -> Self {
        self.timeSlotSelectorStyle = timeSlotSelectorStyle
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(messageTintColor: UIColor) -> Self {
        self.messageTintColor = messageTintColor
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(lisItemStyle: ListItemStyle) -> Self {
        self.lisItemStyle = lisItemStyle
        return self
    }
    
    @discardableResult
    public func set(dividerTint: UIColor) -> Self {
        self.dividerTint = dividerTint
        return self
    }
    
    @discardableResult
    public func set(titleTint: UIColor) -> Self {
        self.titleTint = titleTint
        return self
    }
    
    @discardableResult
    public func set(deactivatedTint: UIColor) -> Self {
        self.deactivatedTint = deactivatedTint
        return self
    }
}
