//
//  CometChatToastStyle.swift
//  CometChatUIKitSwift
//

import Foundation
import UIKit

public struct CometChatToastStyle {

    public var textFont: UIFont = CometChatTypography.Body.regular
    /// Fixed light-on-dark per the design — the pill keeps the same contrast in both
    /// appearances, so these do not follow the light/dark theme colours.
    public var textColor: UIColor = CometChatTheme.white
    public var backgroundColor: UIColor = CometChatTheme.toastBackground
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    public var horizontalPadding: CGFloat = CometChatSpacing.Padding.p4
    public var verticalPadding: CGFloat = CometChatSpacing.Padding.p2

    /// Shadows/Shadow-lg. CALayer renders one shadow per layer, so the design's
    /// three-layer stack collapses to its most visible pass.
    ///
    /// Not visible today: the pill clips to its rounded corners (`masksToBounds`), which
    /// clips this shadow too. The four shadow fields are set on the layer but draw nothing.
    public var shadowColor: UIColor = CometChatTheme.toastBackground
    /// Not visible: clipped with the pill's rounded corners (see `shadowColor`).
    public var shadowOpacity: Float = 0.04
    /// Not visible: clipped with the pill's rounded corners (see `shadowColor`).
    public var shadowOffset: CGSize = .init(width: 0, height: 4)
    /// Not visible: clipped with the pill's rounded corners (see `shadowColor`).
    public var shadowRadius: CGFloat = 6

    public init() { }
}
