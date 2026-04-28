//
//  UIFont+CCTypography.swift
//  AISampleApp
//
//  Call site
//  ---------
//      label.font   = .heading2(.bold)
//      label.font   = .body(.medium)
//      caption.font = .caption1()              // .regular default
//
//      // SwiftUI parity, same Typography source of truth:
//      Text("Hi").font(.heading2(.bold))
//

import UIKit
import SwiftUI
import CometChatUIKitSwift

// MARK: - Single source of truth

public enum Typography {

    public enum Level {
        case title, heading1, heading2, heading3, heading4
        case body, caption1, caption2, button, link
    }

    public enum Weight {
        case bold, medium, regular
    }

    /// The one read path. Every UIKit/SwiftUI helper in this file routes here.
    public static func font(_ level: Level, _ weight: Weight = .regular) -> UIFont {
        switch (level, weight) {
        case (.title, .bold):       return CometChatTypography.Title.bold
        case (.title, .medium):     return CometChatTypography.Title.medium
        case (.title, .regular):    return CometChatTypography.Title.regular

        case (.heading1, .bold):    return CometChatTypography.Heading1.bold
        case (.heading1, .medium):  return CometChatTypography.Heading1.medium
        case (.heading1, .regular): return CometChatTypography.Heading1.regular

        case (.heading2, .bold):    return CometChatTypography.Heading2.bold
        case (.heading2, .medium):  return CometChatTypography.Heading2.medium
        case (.heading2, .regular): return CometChatTypography.Heading2.regular

        case (.heading3, .bold):    return CometChatTypography.Heading3.bold
        case (.heading3, .medium):  return CometChatTypography.Heading3.medium
        case (.heading3, .regular): return CometChatTypography.Heading3.regular

        case (.heading4, .bold):    return CometChatTypography.Heading4.bold
        case (.heading4, .medium):  return CometChatTypography.Heading4.medium
        case (.heading4, .regular): return CometChatTypography.Heading4.regular

        case (.body, .bold):        return CometChatTypography.Body.bold
        case (.body, .medium):      return CometChatTypography.Body.medium
        case (.body, .regular):     return CometChatTypography.Body.regular

        case (.caption1, .bold):    return CometChatTypography.Caption1.bold
        case (.caption1, .medium):  return CometChatTypography.Caption1.medium
        case (.caption1, .regular): return CometChatTypography.Caption1.regular

        case (.caption2, .bold):    return CometChatTypography.Caption2.bold
        case (.caption2, .medium):  return CometChatTypography.Caption2.medium
        case (.caption2, .regular): return CometChatTypography.Caption2.regular

        case (.button, .bold):      return CometChatTypography.Button.bold
        case (.button, .medium):    return CometChatTypography.Button.medium
        case (.button, .regular):   return CometChatTypography.Button.regular

        // Link upstream only exposes `.regular`. Any other weight collapses to it.
        case (.link, _):            return CometChatTypography.Link.regular
        }
    }

    /// Semantic override hook — replaces direct mutation of
    /// `CometChatTypography.Heading2.bold`. In an SDK-side refactor this
    /// would write into `Typography`'s own storage; today it forwards.
    public static func setFont(_ level: Level, _ weight: Weight, _ font: UIFont) {
        switch (level, weight) {
        case (.title, .bold):       CometChatTypography.Title.bold = font
        case (.title, .medium):     CometChatTypography.Title.medium = font
        case (.title, .regular):    CometChatTypography.Title.regular = font

        case (.heading1, .bold):    CometChatTypography.Heading1.bold = font
        case (.heading1, .medium):  CometChatTypography.Heading1.medium = font
        case (.heading1, .regular): CometChatTypography.Heading1.regular = font

        case (.heading2, .bold):    CometChatTypography.Heading2.bold = font
        case (.heading2, .medium):  CometChatTypography.Heading2.medium = font
        case (.heading2, .regular): CometChatTypography.Heading2.regular = font

        case (.heading3, .bold):    CometChatTypography.Heading3.bold = font
        case (.heading3, .medium):  CometChatTypography.Heading3.medium = font
        case (.heading3, .regular): CometChatTypography.Heading3.regular = font

        case (.heading4, .bold):    CometChatTypography.Heading4.bold = font
        case (.heading4, .medium):  CometChatTypography.Heading4.medium = font
        case (.heading4, .regular): CometChatTypography.Heading4.regular = font

        case (.body, .bold):        CometChatTypography.Body.bold = font
        case (.body, .medium):      CometChatTypography.Body.medium = font
        case (.body, .regular):     CometChatTypography.Body.regular = font

        case (.caption1, .bold):    CometChatTypography.Caption1.bold = font
        case (.caption1, .medium):  CometChatTypography.Caption1.medium = font
        case (.caption1, .regular): CometChatTypography.Caption1.regular = font

        case (.caption2, .bold):    CometChatTypography.Caption2.bold = font
        case (.caption2, .medium):  CometChatTypography.Caption2.medium = font
        case (.caption2, .regular): CometChatTypography.Caption2.regular = font

        case (.button, .bold):      CometChatTypography.Button.bold = font
        case (.button, .medium):    CometChatTypography.Button.medium = font
        case (.button, .regular):   CometChatTypography.Button.regular = font

        case (.link, _):            CometChatTypography.Link.regular = font
        }
    }
}

// MARK: - UIKit ergonomics
//
// Per-level functions for readable call sites. Each one-liner routes through
// `Typography.font(_:_:)` — no logic duplicated, single source of truth preserved.

extension UIFont {
    public static func title(_ w: Typography.Weight = .regular) -> UIFont    { Typography.font(.title, w) }
    public static func heading1(_ w: Typography.Weight = .regular) -> UIFont { Typography.font(.heading1, w) }
    public static func heading2(_ w: Typography.Weight = .regular) -> UIFont { Typography.font(.heading2, w) }
    public static func heading3(_ w: Typography.Weight = .regular) -> UIFont { Typography.font(.heading3, w) }
    public static func heading4(_ w: Typography.Weight = .regular) -> UIFont { Typography.font(.heading4, w) }
    public static func body(_ w: Typography.Weight = .regular) -> UIFont     { Typography.font(.body, w) }
    public static func caption1(_ w: Typography.Weight = .regular) -> UIFont { Typography.font(.caption1, w) }
    public static func caption2(_ w: Typography.Weight = .regular) -> UIFont { Typography.font(.caption2, w) }
    public static func button(_ w: Typography.Weight = .regular) -> UIFont   { Typography.font(.button, w) }
    public static func link() -> UIFont                                       { Typography.font(.link) }
}

// MARK: - SwiftUI parity (same per-level shape, same source of truth)

@available(iOS 14.0, *)
extension Font {
    public static func title(_ w: Typography.Weight = .regular) -> Font    { Font(Typography.font(.title, w)) }
    public static func heading1(_ w: Typography.Weight = .regular) -> Font { Font(Typography.font(.heading1, w)) }
    public static func heading2(_ w: Typography.Weight = .regular) -> Font { Font(Typography.font(.heading2, w)) }
    public static func heading3(_ w: Typography.Weight = .regular) -> Font { Font(Typography.font(.heading3, w)) }
    public static func heading4(_ w: Typography.Weight = .regular) -> Font { Font(Typography.font(.heading4, w)) }
    public static func body(_ w: Typography.Weight = .regular) -> Font     { Font(Typography.font(.body, w)) }
    public static func caption1(_ w: Typography.Weight = .regular) -> Font { Font(Typography.font(.caption1, w)) }
    public static func caption2(_ w: Typography.Weight = .regular) -> Font { Font(Typography.font(.caption2, w)) }
    public static func button(_ w: Typography.Weight = .regular) -> Font   { Font(Typography.font(.button, w)) }
    public static func link() -> Font                                       { Font(Typography.font(.link)) }
}
