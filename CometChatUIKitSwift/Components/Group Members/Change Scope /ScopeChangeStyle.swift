//
//  ScopeChangeStyle.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 22/10/24.
//

import UIKit
import Foundation

public struct ScopeChangeStyle {
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderColor: UIColor = .clear
    public var borderWidth: CGFloat = 0.0
    public var cornerRadius: CometChatCornerStyle?
    
    public var changeImage: UIImage = UIImage(systemName: "arrow.triangle.2.circlepath.circle")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var changeImageTintColor: UIColor = CometChatTheme.primaryColor
    
    public var titleTextColor: UIColor = CometChatTheme.textColorPrimary
    public var titleFont: UIFont = CometChatTypography.Heading2.medium
    
    public var subtitleTextColor: UIColor = CometChatTheme.textColorSecondary
    public var subtitleFont: UIFont = CometChatTypography.Body.regular
    
    public var saveButtonTintColor: UIColor = CometChatTheme.primaryColor
    public var cancelButonTintColor: UIColor = CometChatTheme.backgroundColor04
    
    
    public var optionContainerBorderColor: UIColor = CometChatTheme.borderColorLight
    public var optionContainerBorderWidth: CGFloat = 1
    public var optionsContainerCornerRadius: CometChatCornerStyle = .init(cornerRadius: 8)
    public var selectedOptionBackgroundColor: UIColor = CometChatTheme.neutralColor200
    public var optionBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var optionTextColor: UIColor = CometChatTheme.textColorSecondary
    public var selectedOptionTextColor: UIColor = CometChatTheme.textColorPrimary
    public var optionFont: UIFont = CometChatTypography.Body.medium

    public var selectedOptionImage = UIImage(named: "selected-option-image", in: CometChatUIKit.bundle, with: nil)
    public var optionImage = UIImage(named: "de-selected-option-image", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
    
    public init() {}
    
}
