//
//  CometChatRichTextToolbarAction.swift
//  CometChatUIKitSwift
//

import UIKit

/// A custom button rendered at the trailing end of `CometChatRichTextToolbar`,
/// after a divider separating it from the built-in format buttons.
///
/// A value type, not a class: `CometChatRichTextToolbar.trailingActions` rebuilds
/// its buttons from `didSet`, which in-place mutation of a reference type would
/// not fire.
public struct CometChatRichTextToolbarAction {

    /// Identifies the action. Used to look the rendered button up in
    /// `CometChatRichTextToolbar.trailingActionButtons`.
    public var id: String

    /// The button glyph. Rendered as-is — apply `.withRenderingMode(.alwaysTemplate)`
    /// for `tint` or the toolbar's `iconTintColor` to take effect.
    public var icon: UIImage?

    /// Called on tap with a handle onto the composer's live input.
    ///
    /// The handle is valid only for the duration of this call; don't retain it.
    /// The action is retained by the toolbar, so capture `self` weakly.
    public var onClick: (CometChatComposerInput) -> Void

    /// Overrides `RichTextToolbarStyle.iconTintColor` when non-nil.
    public var tint: UIColor?

    /// VoiceOver label. Falls back to `id` so a button is never unlabelled.
    public var accessibilityLabel: String?

    public init(
        id: String,
        icon: UIImage?,
        tint: UIColor? = nil,
        accessibilityLabel: String? = nil,
        onClick: @escaping (CometChatComposerInput) -> Void
    ) {
        self.id = id
        self.icon = icon
        self.tint = tint
        self.accessibilityLabel = accessibilityLabel
        self.onClick = onClick
    }
}
