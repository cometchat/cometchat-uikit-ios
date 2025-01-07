//
//  NSLayoutConstraint+Extensions.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 02/09/24.
//

import Foundation
import UIKit

// MARK: - NSLayoutAnchor Extensions
extension NSLayoutAnchor {
    /// Creates an inactive constraint of the form `thisAnchor = otherAnchor` with a custom priority.
    @objc func pin(equalTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(equalTo: anchor).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor >= otherAnchor` with a custom priority.
    @objc func pin(greaterThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor <= otherAnchor` with a custom priority.
    @objc func pin(lessThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor = otherAnchor + constant` with a custom priority.
    @objc func pin(
        equalTo anchor: NSLayoutAnchor<AnchorType>,
        constant c: CGFloat
    ) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: c).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor >= otherAnchor + constant` with a custom priority.
    @objc func pin(
        greaterThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>,
        constant c: CGFloat
    ) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: c).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor <= otherAnchor + constant` with a custom priority.
    @objc func pin(
        lessThanOrEqualTo anchor: NSLayoutAnchor<AnchorType>,
        constant c: CGFloat
    ) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: c).with(priority: .cometChatHigh)
    }
}

// MARK: - NSLayoutDimension Extensions
extension NSLayoutDimension {
    /// Creates an inactive constraint of the form `thisVariable = constant` with a custom priority.
    @objc func pin(equalToConstant c: CGFloat) -> NSLayoutConstraint {
        constraint(equalToConstant: c).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisVariable >= constant` with a custom priority.
    @objc func pin(greaterThanOrEqualToConstant c: CGFloat) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToConstant: c).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisVariable <= constant` with a custom priority.
    @objc func pin(lessThanOrEqualToConstant c: CGFloat) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToConstant: c).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor = otherAnchor * multiplier` with a custom priority.
    @objc func pin(
        equalTo anchor: NSLayoutDimension,
        multiplier m: CGFloat
    ) -> NSLayoutConstraint {
        constraint(equalTo: anchor, multiplier: m).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor >= otherAnchor * multiplier` with a custom priority.
    @objc func pin(
        greaterThanOrEqualTo anchor: NSLayoutDimension,
        multiplier m: CGFloat
    ) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, multiplier: m).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor <= otherAnchor * multiplier` with a custom priority.
    @objc func pin(
        lessThanOrEqualTo anchor: NSLayoutDimension,
        multiplier m: CGFloat
    ) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, multiplier: m).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor = otherAnchor * multiplier + constant` with a custom priority.
    @objc func pin(
        equalTo anchor: NSLayoutDimension,
        multiplier m: CGFloat,
        constant c: CGFloat
    ) -> NSLayoutConstraint {
        constraint(equalTo: anchor, multiplier: m, constant: c).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor >= otherAnchor * multiplier + constant` with a custom priority.
    @objc func pin(
        greaterThanOrEqualTo anchor: NSLayoutDimension,
        multiplier m: CGFloat,
        constant c: CGFloat
    ) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, multiplier: m, constant: c).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor <= otherAnchor * multiplier + constant` with a custom priority.
    @objc func pin(
        lessThanOrEqualTo anchor: NSLayoutDimension,
        multiplier m: CGFloat,
        constant c: CGFloat
    ) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, multiplier: m, constant: c).with(priority: .cometChatHigh)
    }
}

// MARK: - NSLayoutXAxisAnchor Extensions
extension NSLayoutXAxisAnchor {
    /// Creates an inactive constraint of the form `thisAnchor = otherAnchor + multiplier * system space` with a custom priority.
    @objc func pin(
        equalToSystemSpacingAfter anchor: NSLayoutXAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(equalToSystemSpacingAfter: anchor, multiplier: multiplier).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor >= otherAnchor + multiplier * system space` with a custom priority.
    @objc func pin(
        greaterThanOrEqualToSystemSpacingAfter anchor: NSLayoutXAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToSystemSpacingAfter: anchor, multiplier: multiplier).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor <= otherAnchor + multiplier * system space` with a custom priority.
    @objc func pin(
        lessThanOrEqualToSystemSpacingAfter anchor: NSLayoutXAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToSystemSpacingAfter: anchor, multiplier: multiplier).with(priority: .cometChatHigh)
    }
}

// MARK: - NSLayoutYAxisAnchor Extensions
extension NSLayoutYAxisAnchor {
    /// Creates an inactive constraint of the form `thisAnchor = otherAnchor + multiplier * system space` with a custom priority.
    @objc func pin(
        equalToSystemSpacingBelow anchor: NSLayoutYAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(equalToSystemSpacingBelow: anchor, multiplier: multiplier).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor >= otherAnchor + multiplier * system space` with a custom priority.
    @objc func pin(
        greaterThanOrEqualToSystemSpacingBelow anchor: NSLayoutYAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToSystemSpacingBelow: anchor, multiplier: multiplier).with(priority: .cometChatHigh)
    }

    /// Creates an inactive constraint of the form `thisAnchor <= otherAnchor + multiplier * system space` with a custom priority.
    @objc func pin(
        lessThanOrEqualToSystemSpacingBelow anchor: NSLayoutYAxisAnchor,
        multiplier: CGFloat = 1
    ) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: multiplier).with(priority: .cometChatHigh)
    }
}

// MARK: - NSLayoutConstraint Extensions
extension NSLayoutConstraint {
    /// Changes the priority of `self` to the provided one.
    /// - Parameter priority: The priority to be applied.
    /// - Returns: `self` with updated `priority`.
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    /// Returns updated `self` with `priority == .cometChatAlmostHigh`.
    var almostHigh: NSLayoutConstraint {
        with(priority: .cometChatAlmostHigh)
    }
}

// MARK: - UILayoutPriority Extensions
extension UILayoutPriority {
    
    /// Having our default priority lower than `.required(1000)` allows the user to easily override any default constraints and customize the layout.
    static let cometChatHigh = UILayoutPriority(rawValue: 850)
    static let cometChatAlmostHigh = UILayoutPriority.cometChatHigh - 1

    /// The default low priority used for the default layouts. It's higher than the system `defaultLow`.
    static let cometChatLow = UILayoutPriority.defaultLow + 10
}
