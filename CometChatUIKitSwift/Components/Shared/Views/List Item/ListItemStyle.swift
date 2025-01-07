//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 15/11/22.
//

import Foundation
import UIKit

public protocol ListItemStyle {
    var listItemTitleTextColor: UIColor { get set }
    var listItemTitleFont: UIFont { get set }
    var listItemSubTitleTextColor: UIColor { get set }
    var listItemSubTitleFont: UIFont { get set }
    var listItemBackground: UIColor { get set }
    var listItemSelectedBackground: UIColor { get set }
    var listItemBorderWidth: CGFloat { get set }
    var listItemBorderColor: UIColor { get set }
    var listItemCornerRadius: CometChatCornerStyle { get set }
    var listItemSelectionImageTint: UIColor { get set }
    var listItemDeSelectedImageTint: UIColor { get set }
    var listItemSelectedImage: UIImage { get set }
    var listItemDeSelectedImage: UIImage { get set }
}


public struct ListItemStyleDefault: ListItemStyle {
    public var listItemDeSelectedImageTint: UIColor = CometChatTheme.borderColorDefault
    
    public var listItemSelectedImage: UIImage = UIImage(systemName: "checkmark.square.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var listItemDeSelectedImage: UIImage = UIImage(systemName: "square")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var listItemTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var listItemTitleFont: UIFont = CometChatTypography.Heading4.medium
    
    public var listItemSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var listItemSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var listItemBackground: UIColor = .clear
    
    public var listItemSelectedBackground: UIColor = CometChatTheme.backgroundColor04
    
    public var listItemBorderWidth: CGFloat = 0
    
    public var listItemBorderColor: UIColor = .clear
    
    public var listItemSelectionImageTint: UIColor = CometChatTheme.backgroundColor03
    
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public init() {  }
}
