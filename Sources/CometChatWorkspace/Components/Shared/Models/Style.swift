//
//  Stype.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 22/03/22.
//

import Foundation
import CometChatPro
import UIKit

public struct Style {
    
    var background: UIColor?
    var border: CGFloat?
    var cornerRadius: CGFloat?
    var titleColor: UIColor?
    var titleFont: UIFont?
    var subTitleColor: UIColor?
    var subTitleFont: UIFont?
    var loadingIconTint: UIColor?
    var emptyStateTextFont: UIFont?
    var emptyStateTextColor: UIColor?
    var errorStateTextFont: UIFont?
    var errorStateTextColor: UIColor?
    var typingIndicatorTextColor: UIColor?
    var typingIndicatorTextFont: UIFont?
    var threadIndicatorTextColor: UIColor?
    var threadIndicatorTextFont: UIFont?
    
    init() {}
    
    init(background: UIColor?, border:  CGFloat?, cornerRadius: CGFloat?, titleColor: UIColor?, titleFont: UIFont?) {
        self.background = background
        self.border = border
        self.cornerRadius = cornerRadius
        self.titleFont = titleFont
        self.titleColor = titleColor
    }
    
    init(background: UIColor?, border:  CGFloat?, cornerRadius: CGFloat?, titleColor: UIColor?, titleFont: UIFont?, subTitleColor: UIColor?, subTitleFont: UIFont?) {
        self.background = background
        self.border = border
        self.cornerRadius = cornerRadius
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subTitleColor = subTitleColor
        self.subTitleFont = subTitleFont
    }
    
    init(background: UIColor?, border:  CGFloat?, cornerRadius: CGFloat?, titleColor: UIColor?, titleFont: UIFont?, subTitleColor: UIColor?, subTitleFont: UIFont?, loadingIconTint: UIColor?, emptyStateTextFont: UIFont?, emptyStateTextColor: UIColor?, errorStateTextFont: UIFont?, errorStateTextColor: UIColor?) {
        self.background = background
        self.border = border
        self.cornerRadius = cornerRadius
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subTitleColor = subTitleColor
        self.subTitleFont = subTitleFont
        self.loadingIconTint = loadingIconTint
        self.emptyStateTextFont = emptyStateTextFont
        self.emptyStateTextColor = emptyStateTextColor
        self.errorStateTextFont = errorStateTextFont
        self.errorStateTextColor = errorStateTextColor
    }
    
    init(background: UIColor?, border:  CGFloat?, cornerRadius: CGFloat?, titleColor: UIColor?, titleFont: UIFont?, subTitleColor: UIColor?, subTitleFont: UIFont?, typingIndicatorTextColor: UIColor?, typingIndicatorTextFont: UIFont?, threadIndicatorTextColor: UIColor?, threadIndicatorTextFont: UIFont?) {
        self.background = background
        self.border = border
        self.cornerRadius = cornerRadius
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subTitleColor = subTitleColor
        self.subTitleFont = subTitleFont
        self.typingIndicatorTextColor = typingIndicatorTextColor
        self.typingIndicatorTextFont = typingIndicatorTextFont
        self.threadIndicatorTextColor = threadIndicatorTextColor
        self.threadIndicatorTextFont = threadIndicatorTextFont
    }
}
