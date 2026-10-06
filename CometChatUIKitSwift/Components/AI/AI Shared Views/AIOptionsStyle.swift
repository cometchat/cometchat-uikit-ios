//
//  AIOptionsStyle.swift
//
//
//  Created by SuryanshBisen on 25/10/23.
//

import Foundation
import UIKit

public struct AIOptionsStyle: AIParentStyle {    
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var errorViewTextFont: UIFont?
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var errorViewTextColor: UIColor?
    
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var emptyViewTextFont: UIFont?
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var emptyViewTextColor: UIColor?
    
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var aiImageTintColor: UIColor = CometChatTheme.iconColorHighlight
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var textColor: UIColor = CometChatTheme.textColorPrimary
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var textFont: UIFont = CometChatTypography.Heading4.regular
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var borderWidth: CGFloat = 0
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var borderColor: UIColor = .clear
    /// Not applied: the composer turns AI options into action-sheet items that carry no style. Kept for source compatibility.
    public var cornerRadius: CometChatCornerStyle? = nil
    
    public init(){ }
    
}
