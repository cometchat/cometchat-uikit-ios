//
//  GalleryBubbleStyle.swift
//  CometChatUIKitSwift
//
//  Styling for the multi-attachment gallery (media grid) bubble.
//

import UIKit

public struct GalleryBubbleStyle: BaseMessageBubbleStyle {

    // MARK: - BaseMessageBubbleStyle
    public var messagePreviewStyle: MessagePreviewStyle?
    public var backgroundColor: UIColor?
    public var backgroundDrawable: UIImage?
    public var borderWidth: CGFloat?
    public var borderColor: UIColor?
    public var cornerRadius: CometChatCornerStyle?
    public var avatarStyle: AvatarStyle?
    public var dateStyle: DateStyle?
    public var receiptStyle: ReceiptStyle?
    public var headerTextColor: UIColor?
    public var headerTextFont: UIFont?
    public var threadedIndicatorTextFont: UIFont?
    public var threadedIndicatorTextColor: UIColor?
    public var threadedIndicatorImageTint: UIColor?
    public var reactionsStyle: ReactionsStyle?

    // MARK: - Gallery specific

    /// Content width of the media grid / files bubble — a proportion of the device's own
    /// screen width (same convention as `CometChatTextBubble`/`CometChatCardBubble`'s
    /// screen-relative max widths), clamped so it neither cramps on an iPhone SE nor
    /// blows up into an absurdly wide bubble on an iPad. This is what keeps the bubble's
    /// PROPORTION to the screen consistent across an iPhone 12 mini, a Pro Max, and an
    /// iPad — a fixed point value would look right on only one screen size.
    public var bubbleWidth: CGFloat = GalleryBubbleStyle.scaledWidth(ratio: 0.62, min: 210, max: 300)

    /// Fixed height of an audio row. Taller than a file card because it stacks a name,
    /// a slider and a time line; a file card only needs a name + meta line, so it is more
    /// compact (`fileCardHeight`). Both share `bubbleWidth` (the media-bubble width), so
    /// a file, an audio and an image message all have the same WIDTH — only audio is
    /// taller. Fixed pt heights render identically on every device.
    public var audioCardHeight: CGFloat = 68

    /// Fixed height of a file card — shorter than an audio row (name + meta only).
    public var fileCardHeight: CGFloat = 56

    /// `ratio` of the CURRENT screen's width, clamped to `[min, max]`. Evaluated once per
    /// `GalleryBubbleStyle()` construction — since every bubble/tile builds its own style
    /// fresh when the message list (re)renders a cell, this naturally picks up rotation or
    /// multitasking-resize changes on the next reload, with no observer needed.
    private static func scaledWidth(ratio: CGFloat, min minWidth: CGFloat, max maxWidth: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return min(max(screenWidth * ratio, minWidth), maxWidth)
    }

    /// Gap between tiles in the grid. Shows the `gridGapColor` through it.
    public var gridSpacing: CGFloat = 3

    /// Corner radius applied to the whole grid container (tiles share a connected look).
    public var containerCornerRadius: CGFloat = CometChatSpacing.Radius.r3

    /// Corner radius of each individual media tile — every tile is rounded on all four
    /// corners, with the bubble color showing through the gaps between them.
    public var tileCornerRadius: CGFloat = CometChatSpacing.Radius.r2

    /// Aspect ratio (height / width) used when a single media item is shown full width.
    public var singleAspectRatio: CGFloat = 0.75

    /// Width fraction occupied by the large tile in the 3-up layout (one large + two stacked).
    public var threeUpLargeRatio: CGFloat = 0.62

    /// Color shown in the gaps between tiles. Clear lets the bubble background show
    /// through, framing each rounded tile in the bubble color.
    public var gridGapColor: UIColor = .clear

    /// Placeholder color shown while a tile's media is loading.
    public var placeholderColor: UIColor = CometChatTheme.neutralColor300

    /// Dark scrim drawn over the last tile when there are more items than visible cells.
    public var overflowOverlayColor: UIColor = UIColor.black.withAlphaComponent(0.45)

    /// "+N" overflow text color.
    /// Always true white: the label sits on a dark scrim over a photo, so it must not
    /// flip with the theme (textColorWhite maps to near-black in dark mode).
    public var overflowTextColor: UIColor = .white

    /// "+N" overflow text font.
    public var overflowTextFont: UIFont = .systemFont(ofSize: 22, weight: .semibold)

    /// Tint of the play badge shown on video tiles.
    public var playIconTint: UIColor = CometChatTheme.iconColorWhite

    /// Background of the circular play badge on video tiles.
    public var playIconBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.35)

    // MARK: - Sections (audio / files / caption)

    /// Vertical spacing between the media, audio, files and caption sections.
    public var sectionSpacing: CGFloat = 6

    // Files section
    public var fileCardBackgroundColor: UIColor = CometChatTheme.backgroundColor02
    public var fileCardCornerSmall: CGFloat = CometChatSpacing.Radius.r1
    public var fileCardSpacing: CGFloat = 2
    public var fileIconTint: UIColor = CometChatTheme.iconColorPrimary
    public var fileNameFont: UIFont = .systemFont(ofSize: 15, weight: .medium)
    public var fileNameColor: UIColor = CometChatTheme.textColorPrimary
    public var fileMetaFont: UIFont = .systemFont(ofSize: 13)
    public var fileMetaColor: UIColor = CometChatTheme.textColorSecondary
    public var expandButtonFont: UIFont = .systemFont(ofSize: 14, weight: .semibold)
    public var expandButtonColor: UIColor = CometChatTheme.textColorPrimary

    // Caption
    public var captionFont: UIFont = .systemFont(ofSize: 15)
    public var captionColor: UIColor = CometChatTheme.textColorPrimary
    public var captionDividerColor: UIColor = CometChatTheme.neutralColor300

    private var styleType: BubbleStyleType = .incoming

    public init() { }

    internal init(styleType: BubbleStyleType) { // for default values according to the bubble type
        self.styleType = styleType
    }
}
