//
//  MentionTextStyle.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 15/03/24.
//

import UIKit
import Foundation

public struct MentionTextStyle {
    
    public var textColor: UIColor = CometChatTheme.primaryColor
    public var textFont: UIFont = CometChatTypography.Body.regular
    public var textBackgroundColor: UIColor = CometChatTheme.primaryColor.withAlphaComponent(0.2)
    public var loggedInUserTextColor: UIColor = CometChatTheme.warningColor
    public var loggedInUserTextFont: UIFont = CometChatTypography.Body.regular
    public var loggedInUserTextBackgroundColor: UIColor = CometChatTheme.warningColor.withAlphaComponent(0.2)
    
    public init() {  }
    
    public func getTextAttributes() -> [NSAttributedString.Key: Any] {
        var textAttributes: [NSAttributedString.Key: Any] = [:]
        textAttributes[.foregroundColor] = textColor
        textAttributes[.font] = textFont
        textAttributes[.backgroundColor] = textBackgroundColor
        return textAttributes
    }
    
    public func getLoggedInUserTextAttributes() -> [NSAttributedString.Key: Any] {
        var textAttributes: [NSAttributedString.Key: Any] = [:]
        textAttributes[.foregroundColor] = loggedInUserTextColor
        textAttributes[.font] = loggedInUserTextFont
        textAttributes[.backgroundColor] = loggedInUserTextBackgroundColor
        return textAttributes
    }
    
}
