//
//  FlagMessageStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 20/11/25.
//

import Foundation
import UIKit

public struct FlagMessageStyle {
    
    public var titleTextFont = CometChatTypography.Heading2.bold
    public var titleTextColor = CometChatTheme.textColorPrimary
    public var subtitleTextFont = CometChatTypography.Button.regular
    public var subtitleTextColor = CometChatTheme.textColorSecondary
    public var reasonTitleTextFont = CometChatTypography.Button.regular
    public var reasonTitleTextColor = CometChatTheme.textColorPrimary
    public var reasonTextFont = CometChatTypography.Button.regular
    public var reasonTextColor = CometChatTheme.textColorPrimary
    public var reportButtonBackgroundColor = CometChatTheme.primaryColor
    public var reportButtonTintColor = CometChatTheme.white
    public var errorTColor = CometChatTheme.errorColor
    public var errorTextFont = CometChatTypography.Button.regular
    public var reportButtonTextFont = CometChatTypography.Button.regular
    public var cancelButtonTextFont = CometChatTypography.Button.regular
    
    public init() {  }
}

