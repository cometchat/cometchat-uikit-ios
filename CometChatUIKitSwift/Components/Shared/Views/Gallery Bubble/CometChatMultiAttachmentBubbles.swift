//
//  CometChatGalleryBubble.swift
//  CometChatUIKitSwift
//
//  Rendering for multi-attachment messages. A single send is split by type into
//  separate messages (sharing a batchId), each drawn with its own per-type bubble:
//    • ImagesBubble / VideoBubble  — count-based media grid (1/2/3/4/5+, "+N" overflow)
//    • AudiosBubble                — one AudioFileRowView per audio file
//    • FilesBubble                 — connected file-card stack (4+ collapses to 3 + "+N more")
//  All inherit CometChatMultiAttachmentBubble (caption row + isOutgoing styling). This
//  file also holds the shared sub-views (GalleryGridView, GalleryFileListView,
//  GalleryMediaTile, GalleryFileCardView, FileTypeIconView) and galleryMediaKind(for:).
//

import UIKit
import CometChatSDK
import AVFoundation
import UniformTypeIdentifiers
import MobileCoreServices
import QuickLook

// MARK: - Media kind helper

enum GalleryMediaKind {
    case image
    case video
    case audio
    case other
}

/// Whether AVFoundation can actually decode this audio file. No hardcoded format
/// lists — the file's own type (MIME, or extension resolved through the system type
/// registry) is put to AVFoundation, which knows its decoders per OS version.
/// Formats it rejects render as file cards instead of a dead player row.
func isAVPlayableAudio(mime: String, ext: String) -> Bool {
    let resolvedMime = mime.isEmpty ? systemMIME(forExtension: ext) : mime
    // No resolvable type at all: let the player try rather than degrade playable files.
    guard !resolvedMime.isEmpty else { return true }
    return AVURLAsset.isPlayableExtendedMIMEType(resolvedMime)
}

/// The system type registry's MIME for a file extension (no hardcoded lists).
func systemMIME(forExtension ext: String) -> String {
    guard !ext.isEmpty else { return "" }
    if #available(iOS 14.0, *) {
        return UTType(filenameExtension: ext)?.preferredMIMEType?.lowercased() ?? ""
    }
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue(),
       let mimeTag = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
        return (mimeTag as String).lowercased()
    }
    return ""
}

/// Whether the media grid can actually render this attachment as an image/video tile.
/// Anything else (an mp3 or a pdf sent under an image/video message type) renders as a
/// "broken" tile: placeholder + unsupported glyph, no play badge.
func galleryTileIsRenderable(_ attachment: Attachment) -> Bool {
    let kind = galleryMediaKind(for: attachment)
    return kind == .image || kind == .video
}

func galleryMediaKind(for attachment: Attachment) -> GalleryMediaKind {
    let ext = attachment.fileExtension.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))

    // The file's own declared MIME wins; when it's absent or not a media type
    // (e.g. application/octet-stream), fall back to the type the system registry
    // derives from the extension. Audio AND video are additionally gated on
    // AVFoundation playability, so formats the OS can't decode (webm/wmv/flv,
    // and ogg/wma on older OSes) group — and send — as plain files.
    func kind(of mime: String) -> GalleryMediaKind? {
        if mime.hasPrefix("audio/") {
            return AVURLAsset.isPlayableExtendedMIMEType(mime) ? .audio : .other
        }
        if mime.hasPrefix("video/") {
            return AVURLAsset.isPlayableExtendedMIMEType(mime) ? .video : .other
        }
        if mime.hasPrefix("image/") { return .image }
        return nil
    }

    if let matched = kind(of: attachment.fileMimeType.lowercased()) { return matched }
    if let matched = kind(of: systemMIME(forExtension: ext)) { return matched }
    return .other
}

// MARK: - Grid container (media)

final class GalleryGridView: UIView {

    var style = GalleryBubbleStyle()
    var onTileTap: ((Int) -> Void)?

    private var tiles: [GalleryMediaTile] = []
    private var visibleCount = 0
    private var heightConstraint: NSLayoutConstraint?
    static let maxVisible = 4
    private var maxVisible: Int { GalleryGridView.maxVisible }

    /// h/w aspect ratios of already-measured lead images, keyed by URL — cells recycle,
    /// so the orientation decision must survive rebinds without refetching.
    private static var leadAspectCache: [String: CGFloat] = [:]
    /// 3-up only: true → wide first tile on top with two square tiles below;
    /// false (default) → tall first tile on the left with two stacked beside it.
    private var firstTileIsLandscape = false
    private var leadAspectKey: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyContainerStyle() {
        layer.cornerRadius = style.containerCornerRadius
        layer.masksToBounds = true
        backgroundColor = style.gridGapColor
    }

    func configure(with attachments: [Attachment], thumbnails: [Int: String] = [:]) {
        tiles.forEach { $0.removeFromSuperview() }
        tiles.removeAll()
        applyContainerStyle()

        let total = attachments.count
        guard total > 0 else {
            updateHeight(0)
            return
        }

        visibleCount = min(total, maxVisible)

        // Orientation-aware 3-up: the layout follows the FIRST image's own aspect
        // ratio. Known (cached) ratios decide the layout up front; otherwise the
        // portrait layout renders and flips once the lead image reports its size.
        firstTileIsLandscape = false
        leadAspectKey = nil
        // A broken lead tile (kind mismatch — e.g. an mp3 in an image message) never
        // loads an image, so it also skips the orientation detection entirely.
        if visibleCount == 3, galleryTileIsRenderable(attachments[0]) {
            let thumb = thumbnails[0]
            let key = (thumb?.isEmpty == false) ? thumb! : attachments[0].fileUrl
            leadAspectKey = key
            if let aspect = GalleryGridView.leadAspectCache[key] {
                firstTileIsLandscape = aspect < 1
            }
        }

        for index in 0..<visibleCount {
            let attachment = attachments[index]
            let isLastVisible = (index == visibleCount - 1)
            let overflow = (total > maxVisible && isLastVisible) ? (total - maxVisible) : 0

            let tile = GalleryMediaTile()
            tile.style = style
            tile.configure(attachment: attachment, overflowCount: overflow, thumbnailUrl: thumbnails[index])
            tile.onTap = { [weak self] in self?.onTileTap?(index) }
            if index == 0 && visibleCount == 3 {
                tile.onImageLoaded = { [weak self] image in
                    self?.leadImageMeasured(image)
                }
            }
            addSubview(tile)
            tiles.append(tile)
        }

        updateHeight(preferredHeight(forVisible: visibleCount, width: style.bubbleWidth))
        setNeedsLayout()
    }

    /// The lead image reported its size: cache the ratio and, if the layout choice
    /// changes, re-lay the grid and re-measure the enclosing self-sizing table row.
    private func leadImageMeasured(_ image: UIImage) {
        guard let key = leadAspectKey, image.size.width > 0 else { return }
        let aspect = image.size.height / image.size.width
        GalleryGridView.leadAspectCache[key] = aspect
        let landscape = aspect < 1
        guard visibleCount == 3, landscape != firstTileIsLandscape else { return }
        firstTileIsLandscape = landscape
        updateHeight(preferredHeight(forVisible: visibleCount, width: style.bubbleWidth))
        setNeedsLayout()

        var ancestor = superview
        while ancestor != nil && !(ancestor is UITableView) { ancestor = ancestor?.superview }
        if let tableView = ancestor as? UITableView {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }

    private func updateHeight(_ value: CGFloat) {
        if let heightConstraint {
            heightConstraint.constant = value
        } else {
            let constraint = heightAnchor.constraint(equalToConstant: value)
            constraint.priority = .required
            constraint.isActive = true
            heightConstraint = constraint
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let rects = frames(forVisible: visibleCount, in: bounds.size)
        for (index, tile) in tiles.enumerated() where index < rects.count {
            tile.frame = rects[index]
        }
    }

    // MARK: - Layout math

    func preferredHeight(forVisible count: Int, width: CGFloat) -> CGFloat {
        let gap = style.gridSpacing
        switch count {
        case 0:
            return 0
        case 1:
            return (width * style.singleAspectRatio).rounded()
        case 2:
            return ((width - gap) / 2).rounded()
        case 3:
            if firstTileIsLandscape {
                // Wide lead tile (16:9) on top, two square tiles below.
                let topHeight = (width * 9 / 16).rounded()
                let bottomHeight = ((width - gap) / 2).rounded()
                return topHeight + gap + bottomHeight
            }
            let rightWidth = (width - gap) * (1 - style.threeUpLargeRatio)
            return (rightWidth * 2 + gap).rounded()
        default: // 4+
            return width
        }
    }

    func frames(forVisible count: Int, in size: CGSize) -> [CGRect] {
        let gap = style.gridSpacing
        let width = size.width
        let height = size.height

        switch count {
        case 1:
            return [CGRect(x: 0, y: 0, width: width, height: height)]

        case 2:
            let tileWidth = (width - gap) / 2
            return [
                CGRect(x: 0, y: 0, width: tileWidth, height: height),
                CGRect(x: tileWidth + gap, y: 0, width: tileWidth, height: height)
            ]

        case 3:
            if firstTileIsLandscape {
                // Landscape lead: wide tile spans the top, the other two sit below.
                let bottomWidth = (width - gap) / 2
                let bottomHeight = bottomWidth.rounded()
                let topHeight = height - gap - bottomHeight
                return [
                    CGRect(x: 0, y: 0, width: width, height: topHeight),
                    CGRect(x: 0, y: topHeight + gap, width: bottomWidth, height: bottomHeight),
                    CGRect(x: bottomWidth + gap, y: topHeight + gap, width: bottomWidth, height: bottomHeight)
                ]
            }
            // Portrait/square lead: tall tile on the left, the other two stacked beside it.
            let leftWidth = ((width - gap) * style.threeUpLargeRatio).rounded()
            let rightWidth = width - gap - leftWidth
            let rightHeight = (height - gap) / 2
            return [
                CGRect(x: 0, y: 0, width: leftWidth, height: height),
                CGRect(x: leftWidth + gap, y: 0, width: rightWidth, height: rightHeight),
                CGRect(x: leftWidth + gap, y: rightHeight + gap, width: rightWidth, height: rightHeight)
            ]

        default: // 4+
            let tileWidth = (width - gap) / 2
            let tileHeight = (height - gap) / 2
            return [
                CGRect(x: 0, y: 0, width: tileWidth, height: tileHeight),
                CGRect(x: tileWidth + gap, y: 0, width: tileWidth, height: tileHeight),
                CGRect(x: 0, y: tileHeight + gap, width: tileWidth, height: tileHeight),
                CGRect(x: tileWidth + gap, y: tileHeight + gap, width: tileWidth, height: tileHeight)
            ]
        }
    }
}

// MARK: - Single media tile

final class GalleryMediaTile: UIView {

    var style = GalleryBubbleStyle()
    var onTap: (() -> Void)?
    /// Fires once the tile's image (or video thumbnail) is on screen — used by the
    /// grid to learn the first tile's aspect ratio for the orientation-aware 3-up.
    var onImageLoaded: ((UIImage) -> Void)?

    private let imageService = ImageService()
    private var imageRequest: Cancellable?
    private var currentURLString: String?

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = style.placeholderColor
        return imageView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = CometChatTheme.iconColorSecondary
        return indicator
    }()

    private lazy var playBadge: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        container.layer.cornerRadius = 22
        container.isHidden = true

        let icon = UIImageView(image: UIImage(systemName: "play.fill"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18)
        ])
        return container
    }()

    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 11, weight: .medium)
        return label
    }()

    private lazy var durationPill: UIView = {
        let pill = UIView()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        pill.layer.cornerRadius = 4
        pill.isHidden = true
        pill.addSubview(durationLabel)
        NSLayoutConstraint.activate([
            durationLabel.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 5),
            durationLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -5),
            durationLabel.topAnchor.constraint(equalTo: pill.topAnchor, constant: 2),
            durationLabel.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -2)
        ])
        return pill
    }()

    /// Centered "unsupported" glyph for broken tiles (kind mismatch — the attachment
    /// isn't a renderable image/video). Sits under the overflow overlay so the "+N"
    /// tile still reads as overflow even over a broken attachment.
    private lazy var unsupportedGlyph: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "unsupported", in: CometChatUIKit.bundle, compatibleWith: nil))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    private lazy var overflowOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = style.overflowOverlayColor
        overlay.isHidden = true
        return overlay
    }()

    private lazy var overflowLabel: UILabel = {
        let label = UILabel()
        label.textColor = style.overflowTextColor
        label.font = style.overflowTextFont
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildUI() {
        clipsToBounds = true
        backgroundColor = style.placeholderColor

        embed(imageView)

        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        playBadge.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playBadge)
        addSubview(durationPill)
        addSubview(unsupportedGlyph)

        embed(overflowOverlay)
        overflowOverlay.addSubview(overflowLabel)
        overflowLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

            unsupportedGlyph.centerXAnchor.constraint(equalTo: centerXAnchor),
            unsupportedGlyph.centerYAnchor.constraint(equalTo: centerYAnchor),
            unsupportedGlyph.widthAnchor.constraint(equalToConstant: 40),
            unsupportedGlyph.heightAnchor.constraint(equalToConstant: 40),

            playBadge.centerXAnchor.constraint(equalTo: centerXAnchor),
            playBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
            playBadge.widthAnchor.constraint(equalToConstant: 44),
            playBadge.heightAnchor.constraint(equalToConstant: 44),

            durationPill.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            durationPill.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),

            overflowLabel.centerXAnchor.constraint(equalTo: overflowOverlay.centerXAnchor),
            overflowLabel.centerYAnchor.constraint(equalTo: overflowOverlay.centerYAnchor)
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        isUserInteractionEnabled = true
    }

    func configure(attachment: Attachment, overflowCount: Int, thumbnailUrl: String? = nil) {
        // Every tile is individually rounded; the bubble color frames it through the
        // grid gaps.
        layer.cornerRadius = style.tileCornerRadius
        layer.masksToBounds = true

        imageView.image = nil
        imageView.backgroundColor = style.placeholderColor

        let kind = galleryMediaKind(for: attachment)
        playBadge.isHidden = (kind != .video)
        durationPill.isHidden = true

        if overflowCount > 0 {
            overflowOverlay.isHidden = false
            overflowLabel.text = String(format: "attachment_overflow".localize(), "\(overflowCount)")
        } else {
            overflowOverlay.isHidden = true
            overflowLabel.text = nil
        }

        // Kind mismatch (e.g. an mp3 in an image message): render the broken tile —
        // placeholder color + centered unsupported glyph, no play badge, nothing to
        // load. The "+N" overlay above still applies when this is the overflow tile.
        let broken = !galleryTileIsRenderable(attachment)
        unsupportedGlyph.isHidden = !broken
        if broken {
            playBadge.isHidden = true
            activityIndicator.stopAnimating()
            currentURLString = nil
            return
        }

        // Prefer the server-generated thumbnail (cheap, small) when the thumbnail
        // extension has produced one; fall back to the full file URL / client-side
        // video-frame extraction otherwise. Placeholder shows until either loads.
        // The thumbnail can 404 (e.g. not generated yet for a fresh upload), so a
        // failed thumbnail load also falls back to the original attachment.
        if let thumbnailUrl, !thumbnailUrl.isEmpty {
            currentURLString = thumbnailUrl
            activityIndicator.startAnimating()
            loadImage(thumbnailUrl, fallbackAttachment: attachment)
            return
        }

        loadOriginal(attachment)
    }

    private func loadOriginal(_ attachment: Attachment) {
        let urlString = attachment.fileUrl
        currentURLString = urlString
        activityIndicator.startAnimating()

        switch galleryMediaKind(for: attachment) {
        case .video:
            loadVideoThumbnail(urlString)
        default:
            loadImage(urlString)
        }
    }

    private func loadImage(_ urlString: String, fallbackAttachment: Attachment? = nil) {
        guard let url = URL(string: urlString) else {
            activityIndicator.stopAnimating()
            if let fallbackAttachment { loadOriginal(fallbackAttachment) }
            return
        }
        imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
            guard let self, self.currentURLString == urlString else { return }
            if let image {
                self.activityIndicator.stopAnimating()
                self.imageView.image = image
                self.onImageLoaded?(image)
            } else if let fallbackAttachment {
                self.loadOriginal(fallbackAttachment)
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func loadVideoThumbnail(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            activityIndicator.stopAnimating()
            return
        }
        VideoThumbnailLoader.thumbnailAndDuration(for: url) { [weak self] image, duration in
            guard let self, self.currentURLString == urlString else { return }
            self.activityIndicator.stopAnimating()
            if let image {
                self.imageView.image = image
                self.onImageLoaded?(image)
            }
            if let duration = duration, self.overflowOverlay.isHidden {
                self.durationLabel.text = duration
                self.durationPill.isHidden = false
            }
        }
    }

    @objc private func handleTap() {
        onTap?()
    }

    deinit {
        imageRequest?.cancel()
    }
}

// MARK: - Files section (connected card stack + expand/collapse)

final class GalleryFileListView: UIView {

    var style = GalleryBubbleStyle()
    var isOutgoing: Bool = false
    var widthConstant: CGFloat = 240
    var onSelectFile: ((_ index: Int, _ attachment: Attachment) -> Void)?
    weak var controller: UIViewController?

    private let collapsedLimit = 3
    private var attachments: [Attachment] = []
    private var expanded = false

    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = style.fileCardSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var expandButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        // Full-width row styled like a file card: centered "+N more" with the chevron
        // sitting right after the text (image placed on the trailing side).
        button.contentHorizontalAlignment = .center
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(toggleExpanded), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with attachments: [Attachment]) {
        self.attachments = attachments
        stack.spacing = style.fileCardSpacing
        rebuild()
    }

    private func rebuild() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let showAll = expanded || attachments.count <= collapsedLimit
        let visibleCount = showAll ? attachments.count : collapsedLimit

        // The toggle row is part of the connected stack, so it takes the last slot in
        // the corner arithmetic (large bottom corners) when present.
        let hasToggle = attachments.count > collapsedLimit
        let totalRows = visibleCount + (hasToggle ? 1 : 0)

        // A single file renders flat on the bubble (no card background), like the
        // classic file bubble; multiple files keep the connected card stack.
        let showCard = attachments.count > 1

        for index in 0..<visibleCount {
            let card = GalleryFileCardView()
            card.style = style
            card.isOutgoing = isOutgoing
            card.controller = controller
            let corners = cornerStyle(for: index, total: totalRows)
            card.configure(attachment: attachments[index], corners: corners, showCard: showCard)
            card.onTap = { [weak self] in
                guard let self else { return }
                self.onSelectFile?(index, self.attachments[index])
            }
            stack.addArrangedSubview(card)
        }

        if hasToggle {
            let remaining = attachments.count - collapsedLimit
            let title = expanded
                ? "file_list_show_less".localize()
                : String(format: "file_list_show_more".localize(), "\(remaining)")
            let tint = isOutgoing ? UIColor.white : style.expandButtonColor
            expandButton.setTitle(title, for: .normal)
            expandButton.setTitleColor(tint, for: .normal)
            expandButton.titleLabel?.font = style.expandButtonFont
            let chevronConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            expandButton.setImage(UIImage(systemName: expanded ? "chevron.up" : "chevron.down",
                                          withConfiguration: chevronConfig), for: .normal)
            expandButton.tintColor = tint
            expandButton.backgroundColor = isOutgoing
                ? UIColor.white.withAlphaComponent(0.15)
                : style.fileCardBackgroundColor
            expandButton.roundViewCorners(corner: cornerStyle(for: totalRows - 1, total: totalRows))
            stack.addArrangedSubview(expandButton)
        }
    }

    private func cornerStyle(for index: Int, total: Int) -> CometChatCornerStyle {
        let large = CGFloat(style.containerCornerRadius)
        let small = style.fileCardCornerSmall
        // Connected-stack look: first card has large top corners, last card has large
        // bottom corners, inner cards are lightly rounded; a single card is fully rounded.
        if total == 1 {
            return CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: true, bottomRight: true, cornerRadius: large)
        }
        if index == 0 {
            return CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: false, bottomRight: false, cornerRadius: large)
        }
        if index == total - 1 {
            return CometChatCornerStyle(topLeft: false, topRight: false, bottomLeft: true, bottomRight: true, cornerRadius: large)
        }
        return CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: true, bottomRight: true, cornerRadius: small)
    }

    @objc private func toggleExpanded() {
        expanded.toggle()
        rebuild()

        // The bubble lives in a self-sizing table row: after the stack grows or
        // shrinks, the table MUST re-measure the row, or the expanded cards overflow
        // the bubble (and collapsing leaves a hole). Re-measure without animation —
        // animated height changes fight the inverted table and cause visible jumps.
        var ancestor = superview
        while ancestor != nil && !(ancestor is UITableView) { ancestor = ancestor?.superview }
        if let tableView = ancestor as? UITableView {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
}

// MARK: - Single file card

final class GalleryFileCardView: UIView {

    var style = GalleryBubbleStyle()
    var isOutgoing: Bool = false
    var onTap: (() -> Void)?
    weak var controller: UIViewController?

    private var normalMeta = ""

    private lazy var iconView: FileTypeIconView = {
        let view = FileTypeIconView(showsBackground: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingMiddle
        label.numberOfLines = 1
        return label
    }()

    private lazy var metaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    private lazy var downloadControl = FileDownloadControl()
    /// Fixed row height, kept in sync with `style.fileCardHeight` in `configure`. A file
    /// card is more compact than an audio row (name + meta only, no slider/time).
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: style.fileCardHeight)

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildUI() {
        let textStack = UIStackView(arrangedSubviews: [nameLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconView)
        addSubview(textStack)
        addSubview(downloadControl)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 32),
            iconView.heightAnchor.constraint(equalToConstant: 32),

            textStack.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: downloadControl.leadingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            downloadControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            downloadControl.centerYAnchor.constraint(equalTo: centerYAnchor),

            heightConstraint
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.delegate = self
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    /// `showCard: false` renders the row flat on the bubble (no card background) — used
    /// when the message carries a single file, matching the classic file bubble.
    /// `unsupported: true` marks an attachment a typed bubble can't render (e.g. a jpg
    /// sent in an audio message): the "unsupported" glyph replaces the type icon and the
    /// meta line reads just "FILE" (no size/extension); download still works.
    func configure(attachment: Attachment, corners: CometChatCornerStyle, showCard: Bool = true, unsupported: Bool = false) {
        heightConstraint.constant = style.fileCardHeight
        backgroundColor = showCard
            ? (isOutgoing ? UIColor.white.withAlphaComponent(0.15) : style.fileCardBackgroundColor)
            : .clear
        roundViewCorners(corner: corners)

        if unsupported {
            iconView.showUnsupported()
        } else {
            // MIME + URL classification (either signal), same precedence as Android.
            iconView.configure(mimeType: attachment.fileMimeType, fileUrl: attachment.fileUrl)
        }

        nameLabel.font = style.fileNameFont
        nameLabel.textColor = isOutgoing ? .white : style.fileNameColor
        nameLabel.text = attachment.fileName.isEmpty
            ? (URL(string: attachment.fileUrl)?.lastPathComponent ?? "File")
            : attachment.fileName

        metaLabel.font = style.fileMetaFont
        metaLabel.textColor = isOutgoing
            ? UIColor.white.withAlphaComponent(0.7)
            : style.fileMetaColor
        normalMeta = unsupported
            ? "MESSAGE_FILE".localize().uppercased()
            : metaText(for: attachment)
        metaLabel.text = normalMeta

        downloadControl.controller = controller
        downloadControl.configure(fileUrl: attachment.fileUrl,
                                  fileName: attachment.fileName,
                                  tint: isOutgoing ? .white : CometChatTheme.primaryColor)
        downloadControl.onStateChange = { [weak self] downloading in
            guard let self = self else { return }
            self.metaLabel.text = downloading ? "attachment_downloading".localize() : self.normalMeta
        }
    }

    private func metaText(for attachment: Attachment) -> String {
        var parts: [String] = []
        if attachment.fileSize > 0 {
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            parts.append(formatter.string(fromByteCount: Int64(attachment.fileSize)))
        }
        let ext = attachment.fileExtension.trimmingCharacters(in: CharacterSet(charactersIn: ".")).uppercased()
        if !ext.isEmpty { parts.append(ext) }
        return parts.joined(separator: " • ")
    }

    @objc private func handleTap() {
        onTap?()
    }
}

extension GalleryFileCardView: UIGestureRecognizerDelegate {
    // Don't let the card's open/share tap fire when the download control was tapped.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.isDescendant(of: downloadControl) ?? false)
    }
}

// MARK: - File-type classification (parity with Android's FileTypeUtils / MultiAttachmentUtils)

/// Cross-platform file-type taxonomy. Classification matches Android's
/// `UIKitConstants.FileTypeMatchers`: for each type a file matches if EITHER signal
/// hits — MIME (`contains` for document types, `startsWith` for media prefixes) or the
/// lowercased URL/filename ending with a known extension. Evaluated in the same fixed
/// precedence: PDF → DOC → XLS → PPT → ZIP → AUDIO → VIDEO → IMAGE → TEXT → LINK → UNKNOWN.
enum GalleryFileType {
    case pdf, doc, xls, ppt, zip, audio, video, image, text, link, unknown

    static func of(mimeType: String, fileUrl: String) -> GalleryFileType {
        let mime = mimeType.lowercased()
        let url = fileUrl.lowercased()
        func hasExt(_ exts: [String]) -> Bool { exts.contains { url.hasSuffix($0) } }

        if mime.contains("pdf") || hasExt([".pdf"]) { return .pdf }
        if mime.contains("msword") || mime.contains("wordprocessingml") || hasExt([".doc", ".docx", ".rtf"]) { return .doc }
        if mime.contains("excel") || mime.contains("spreadsheetml") || hasExt([".xls", ".xlsx", ".csv"]) { return .xls }
        if mime.contains("powerpoint") || mime.contains("presentationml") || hasExt([".ppt", ".pptx"]) { return .ppt }
        if mime.contains("zip") || mime.contains("compressed") || mime.contains("archive") || hasExt([".zip", ".rar", ".7z", ".tar", ".gz"]) { return .zip }
        if mime.hasPrefix("audio/") || hasExt([".mp3", ".wav", ".aac", ".m4a", ".ogg", ".flac"]) { return .audio }
        if mime.hasPrefix("video/") || hasExt([".mp4", ".mov", ".avi", ".mkv", ".webm"]) { return .video }
        if mime.hasPrefix("image/") || hasExt([".jpg", ".jpeg", ".png", ".gif", ".webp", ".heic", ".bmp"]) { return .image }
        if mime.hasPrefix("text/") || hasExt([".txt", ".md", ".log"]) { return .text }
        // LINK: Android matches any remaining http(s) URL. Our attachments ALWAYS have
        // https URLs, so gate it on an empty MIME to keep UNKNOWN reachable for real
        // files the server typed as octet-stream etc.
        if mime.isEmpty && (url.hasPrefix("http://") || url.hasPrefix("https://")) { return .link }
        return .unknown
    }

    /// The bundled `file-type-*` vector icon for this type.
    var iconAssetName: String {
        switch self {
        case .pdf: return "file-type-pdf"
        case .doc: return "file-type-word"
        case .xls: return "file-type-xlsx"
        case .ppt: return "file-type-ppt"
        case .zip: return "file-type-zip"
        case .audio: return "file-type-audio"
        case .video: return "file-type-video"
        case .image: return "file-type-image"
        case .text: return "file-type-text"
        case .link: return "file-type-link"
        case .unknown: return "file-type-generic"
        }
    }

    var icon: UIImage? {
        UIImage(named: iconAssetName, in: CometChatUIKit.bundle, compatibleWith: nil)?
            .withRenderingMode(.alwaysOriginal)
    }
}

// MARK: - File-type icon (designed SVG glyphs in a white rounded container)

final class FileTypeIconView: UIView {

    /// Single source of truth for the icon's curve — the tray's dim overlay uses the
    /// SAME constant so the two shapes always match exactly.
    static var cornerRadius: CGFloat { CometChatSpacing.Radius.r3 }

    /// Bubble file cards show the colored glyph as-is (no container); the composer
    /// tray keeps the white rounded square so icons read over media thumbnails.
    private let showsBackground: Bool

    private lazy var glyph: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    init(showsBackground: Bool) {
        self.showsBackground = showsBackground
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        self.showsBackground = true
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        if showsBackground {
            backgroundColor = .white
            layer.cornerRadius = FileTypeIconView.cornerRadius
            clipsToBounds = true
        }
        addSubview(glyph)
        NSLayoutConstraint.activate([
            glyph.centerXAnchor.constraint(equalTo: centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: centerYAnchor),
            glyph.widthAnchor.constraint(equalTo: widthAnchor, multiplier: showsBackground ? 0.55 : 1.0),
            glyph.heightAnchor.constraint(equalTo: heightAnchor, multiplier: showsBackground ? 0.68 : 1.0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// MIME + extension classification (either signal), matching Android's precedence.
    func configure(mimeType: String, fileUrl: String) {
        glyph.image = GalleryFileType.of(mimeType: mimeType, fileUrl: fileUrl).icon
            ?? UIImage(systemName: "questionmark.circle")?
                .withTintColor(.systemGray, renderingMode: .alwaysOriginal)
    }

    /// Filename-only fallback (no MIME available) — the extension check still runs
    /// through the shared classifier so precedence stays identical.
    func configure(fileName: String) {
        configure(mimeType: "", fileUrl: fileName.lowercased())
    }

    /// The "can't render this here" glyph — used when a typed bubble (e.g. audio)
    /// receives an attachment the OS can't play, instead of a type-classified icon.
    func showUnsupported() {
        glyph.image = UIImage(named: "unsupported", in: CometChatUIKit.bundle, compatibleWith: nil)?
            .withRenderingMode(.alwaysOriginal)
            ?? UIImage(systemName: "questionmark.circle")?
                .withTintColor(.systemGray, renderingMode: .alwaysOriginal)
    }

}

// MARK: - Per-type multi-attachment bubbles (batch rendering)
//
// A single send is split by type into separate messages sharing a `batchId`; each
// renders with its own bubble below. Order: Images → Videos → Audios → VoiceNote →
// Files. Caption (present only on the last message of a batch) renders in that bubble.

/// Shared base: a vertical bubble with an optional caption row (1px divider) pinned at
/// the bottom. Subclasses insert their content above the caption.
public class CometChatMultiAttachmentBubble: UIStackView {

    public var style = GalleryBubbleStyle()
    public var isOutgoing = false
    weak var controller: UIViewController?

    /// Captions render through the SAME view as text messages (`CometChatTextBubble`)
    /// so code blocks, quote blocks and inline code look identical to text bubbles —
    /// including after a caption-only edit.
    private let captionBubble = CometChatTextBubble()
    private lazy var captionContainer: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [captionBubble])
        stack.axis = .vertical
        stack.spacing = 6
        stack.isHidden = true
        return stack
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        axis = .vertical
        spacing = style.sectionSpacing
        alignment = .fill
        distribution = .fill
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: CometChatSpacing.Padding.p1,
                                     left: CometChatSpacing.Padding.p1,
                                     bottom: CometChatSpacing.Padding.p1,
                                     right: CometChatSpacing.Padding.p1)
        addArrangedSubview(captionContainer)
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    public func set(controller: UIViewController?) { self.controller = controller }

    /// Insert content above the caption row.
    func insertContent(_ view: UIView) {
        insertArrangedSubview(view, at: max(0, arrangedSubviews.count - 1))
    }

    func applyCaption(_ caption: String?) {
        let text = caption?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        captionContainer.isHidden = text.isEmpty
        guard !text.isEmpty else { return }

        // Mirror getTextMessageBubble's configuration exactly so the caption's code
        // blocks / quote blocks / inline code match text bubbles in both directions.
        captionBubble.controller = controller
        captionBubble.style = TextBubbleStyle(styleType: isOutgoing ? .outgoing : .incoming)
        captionBubble.style.textFont = style.captionFont
        let codeBackgroundColor: UIColor
        let codeTextColor: UIColor
        let baseTextColor: UIColor
        if isOutgoing {
            codeBackgroundColor = CometChatTheme.white.withAlphaComponent(0.1)
            codeTextColor = CometChatTheme.white
            baseTextColor = CometChatTheme.white
        } else {
            codeBackgroundColor = CometChatTheme.neutralColor200
            codeTextColor = CometChatTheme.neutralColor900
            baseTextColor = style.captionColor
        }
        captionBubble.style.textColor = baseTextColor
        captionBubble.codeBlockBackgroundColor = codeBackgroundColor
        captionBubble.inlineCodeBackgroundColor = codeBackgroundColor

        if RichTextFormatterManager.shared.containsMarkdownFormatting(text) {
            let inlineCodeTextColor: UIColor? = isOutgoing
                ? CometChatTheme.white
                : CometChatTheme.extendedPrimaryColor700
            captionBubble.setMarkdownText(text,
                                          baseFont: style.captionFont,
                                          baseColor: baseTextColor,
                                          codeTextColor: codeTextColor,
                                          inlineCodeTextColor: inlineCodeTextColor)
        } else {
            captionBubble.set(text: text)
        }
    }
}

/// Image / video grid bubble (1/2/3/4/5+ with "+N" overflow). Tapping a tile opens the
/// fullscreen viewer. `ImagesBubble` and `VideoBubble` are thin named subclasses.
public class CometChatMediaGridBubble: CometChatMultiAttachmentBubble {

    public var onMediaTap: ((_ index: Int, _ attachment: Attachment) -> Void)?
    public private(set) var mediaAttachments: [Attachment] = []

    private let gridView = GalleryGridView()
    private var gridWidthConstraint: NSLayoutConstraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        insertContent(gridView)
        let width = gridView.widthAnchor.constraint(equalToConstant: style.bubbleWidth)
        width.priority = .required
        width.isActive = true
        gridWidthConstraint = width
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            gridView.style = style
            gridView.applyContainerStyle()
            gridWidthConstraint?.constant = style.bubbleWidth
        }
    }

    public func set(attachments: [Attachment], caption: String?, thumbnails: [Int: String] = [:]) {
        // The full list, no kind filter: attachments the grid can't render (e.g. an
        // mp3 sent in an image message) stay IN the grid as broken tiles (placeholder
        // + unsupported glyph). Indices therefore always match the message's own
        // attachment order — including the server-thumbnail dictionary's keys.
        mediaAttachments = attachments

        gridView.isHidden = attachments.isEmpty
        gridView.style = style
        gridWidthConstraint?.constant = style.bubbleWidth
        gridView.onTileTap = { [weak self] index in
            guard let self = self, index < self.mediaAttachments.count else { return }
            self.onMediaTap?(index, self.mediaAttachments[index])
        }
        gridView.configure(with: mediaAttachments, thumbnails: thumbnails)

        applyCaption(caption)
    }
}

public final class ImagesBubble: CometChatMediaGridBubble {}
public final class VideoBubble: CometChatMediaGridBubble {}

/// Files bubble — connected card stack; 4+ collapses to first 3 + "+N more".
public final class FilesBubble: CometChatMultiAttachmentBubble {

    public var onSelectFile: ((_ index: Int, _ attachment: Attachment) -> Void)?

    private let fileListView = GalleryFileListView()
    private var fileWidthConstraint: NSLayoutConstraint?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        insertContent(fileListView)
        let width = fileListView.widthAnchor.constraint(equalToConstant: style.bubbleWidth)
        width.priority = .required
        width.isActive = true
        fileWidthConstraint = width
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    public func set(attachments: [Attachment], caption: String?) {
        fileListView.style = style
        fileListView.isOutgoing = isOutgoing
        fileListView.controller = controller
        fileListView.widthConstant = style.bubbleWidth
        fileWidthConstraint?.constant = style.bubbleWidth
        fileListView.onSelectFile = { [weak self] index, attachment in
            guard let self = self else { return }
            if let handler = self.onSelectFile {
                handler(index, attachment)
            } else {
                self.openFile(attachment)
            }
        }
        fileListView.configure(with: attachments)
        applyCaption(caption)
    }

    private func openFile(_ attachment: Attachment) {
        GalleryFileOpener.open(attachment, from: controller)
    }
}

/// Audios bubble — one inline audio-file player per attachment (play circle, name,
/// flat slider, time, download). A single audio renders flat on the bubble; multiple
/// audios each get their own lighter rounded card. Voice notes are NOT rendered here —
/// they keep the classic bubble.
public final class AudiosBubble: CometChatMultiAttachmentBubble {

    private let audioStack = UIStackView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        audioStack.axis = .vertical
        audioStack.spacing = 5
        insertContent(audioStack)
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    public func set(attachments: [Attachment], caption: String?) {
        audioStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let showCard = attachments.count > 1
        for attachment in attachments {
            // Cross-platform audio messages can carry formats iOS can't decode
            // (ogg/opus/wma…); those render as a downloadable file card instead
            // of a player row that can never play.
            let ext = attachment.fileExtension.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))
            guard isAVPlayableAudio(mime: attachment.fileMimeType.lowercased(), ext: ext) else {
                let card = GalleryFileCardView()
                card.style = style
                card.isOutgoing = isOutgoing
                card.controller = controller
                card.widthAnchor.constraint(equalToConstant: style.bubbleWidth).isActive = true
                card.configure(
                    attachment: attachment,
                    corners: CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: true, bottomRight: true,
                                                  cornerRadius: CGFloat(style.containerCornerRadius)),
                    showCard: showCard,
                    unsupported: true
                )
                card.onTap = { [weak self] in
                    GalleryFileOpener.open(attachment, from: self?.controller)
                }
                audioStack.addArrangedSubview(card)
                continue
            }
            let row = AudioFileRowView()
            row.widthAnchor.constraint(equalToConstant: style.bubbleWidth).isActive = true
            row.configure(fileUrl: attachment.fileUrl,
                          fileName: attachment.fileName,
                          isOutgoing: isOutgoing,
                          controller: controller,
                          showCard: showCard,
                          cardHeight: style.audioCardHeight)
            audioStack.addArrangedSubview(row)
        }
        applyCaption(caption)
    }
}

/// An audio-file player row matching the composer's audio chip:
/// [purple play circle] [file name / flat slider / 00:00/00:32]  [download]
/// Functional AVPlayer playback with seek; only one row plays at a time.
final class AudioFileRowView: UIView {

    // Only one audio row plays at a time.
    private static weak var currentlyPlaying: AudioFileRowView?

    private var fileUrl: String?
    private weak var controller: UIViewController?
    private var player: AVPlayer?
    private var timeObserver: Any?
    private var totalSeconds: Double = 0
    private var isSeeking = false
    private var didActivateAudioSession = false
    private var isOutgoing = false

    private let circleView = UIView()
    private let playIconView = UIImageView()
    private let fileNameLabel = UILabel()
    private let slider = UISlider()
    private let timeLabel = UILabel()
    private let downloadControl = FileDownloadControl()
    /// Groups name/slider/time and centers the whole block on the circle's centerY, with
    /// REQUIRED minimum top/bottom insets — so spacing to the card edges stays consistent
    /// no matter what stretches the row's overall height (e.g. a taller sibling row).
    private let textStack = UIStackView()
    /// Fixed row height, set from `style.audioCardHeight` in `configure`. An audio row is
    /// taller than a file card (it stacks name + slider + time). Defaults to the style default.
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: GalleryBubbleStyle().audioCardHeight)

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let token = timeObserver { player?.removeTimeObserver(token) }
        // Hand audio control back so background music/podcasts resume — but only if THIS
        // row owned the session (never yank it out from under another row that's playing).
        if didActivateAudioSession,
           AudioFileRowView.currentlyPlaying == nil || AudioFileRowView.currentlyPlaying === self {
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        }
    }

    private func buildUI() {
        translatesAutoresizingMaskIntoConstraints = false

        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.cornerRadius = 22
        circleView.clipsToBounds = true
        circleView.isUserInteractionEnabled = true
        circleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(togglePlay)))

        playIconView.translatesAutoresizingMaskIntoConstraints = false
        playIconView.contentMode = .scaleAspectFit
        playIconView.image = UIImage(systemName: "play.fill")
        circleView.addSubview(playIconView)

        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        fileNameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        fileNameLabel.lineBreakMode = .byTruncatingTail

        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.value = 0
        slider.setThumbImage(AudioFileRowView.thumbImage(), for: .normal)
        slider.setThumbImage(AudioFileRowView.thumbImage(), for: .highlighted)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: [.touchDown])
        slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.text = "00:00/00:00"

        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.addArrangedSubview(fileNameLabel)
        textStack.addArrangedSubview(slider)
        textStack.addArrangedSubview(timeLabel)
        textStack.setCustomSpacing(5, after: fileNameLabel)

        addSubview(circleView)
        addSubview(textStack)
        addSubview(downloadControl)

        // Each row is its own rounded CARD inside the bubble (lighter grey incoming,
        // lighter purple outgoing) — single and multiple audios use the same card.
        layer.cornerRadius = CometChatSpacing.Radius.r3
        clipsToBounds = true

        // A fixed track height keeps the name/slider/time block compact so it centers
        // nicely inside the fixed row height (a bare UISlider's ~31pt intrinsic height is
        // mostly empty touch padding that would otherwise crowd the name and time).
        slider.heightAnchor.constraint(equalToConstant: 16).isActive = true

        NSLayoutConstraint.activate([
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 44),
            circleView.heightAnchor.constraint(equalToConstant: 44),
            heightConstraint,

            playIconView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            playIconView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            playIconView.widthAnchor.constraint(equalToConstant: 20),
            playIconView.heightAnchor.constraint(equalToConstant: 20),

            // The name/slider/time block is centered on the row (matching the circle's
            // centerY). The fixed row height gives even breathing room above the name and
            // below the time, so neither crowds the card edge.
            textStack.leadingAnchor.constraint(equalTo: circleView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: downloadControl.leadingAnchor, constant: -12),
            textStack.centerYAnchor.constraint(equalTo: centerYAnchor),

            downloadControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            downloadControl.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    /// A small filled-circle thumb for the flat slider.
    private static func thumbImage() -> UIImage {
        let size = CGSize(width: 12, height: 12)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            ctx.cgContext.setStrokeColor(UIColor.black.withAlphaComponent(0.12).cgColor)
            ctx.cgContext.setLineWidth(0.5)
            ctx.cgContext.strokeEllipse(in: CGRect(x: 0.25, y: 0.25, width: 11.5, height: 11.5))
        }
    }

    func configure(fileUrl: String, fileName: String, isOutgoing: Bool, controller: UIViewController?, showCard: Bool = false, cardHeight: CGFloat) {
        self.fileUrl = fileUrl
        self.controller = controller
        self.isOutgoing = isOutgoing
        fileNameLabel.text = fileName
        heightConstraint.constant = cardHeight

        // Multiple audios in one message: each row gets its own lighter card (grey on
        // incoming, white-tinted purple on outgoing). A single audio stays flat — the
        // bubble itself is the card.
        backgroundColor = showCard
            ? (isOutgoing ? UIColor.white.withAlphaComponent(0.18) : CometChatTheme.backgroundColor02)
            : .clear

        // Incoming bubble: primary play circle + theme text (same as the composer chip).
        // Outgoing bubble is already primary-tinted, so the circle flips to white with a
        // primary icon, and text/controls go white for contrast.
        circleView.backgroundColor = isOutgoing ? .white : CometChatTheme.primaryColor
        playIconView.tintColor = isOutgoing ? CometChatTheme.primaryColor : .white
        fileNameLabel.textColor = isOutgoing ? .white : CometChatTheme.textColorPrimary
        timeLabel.textColor = isOutgoing
            ? UIColor.white.withAlphaComponent(0.7)
            : CometChatTheme.textColorSecondary
        slider.minimumTrackTintColor = isOutgoing ? .white : CometChatTheme.primaryColor
        // The unplayed track needs enough contrast to read on the grey incoming bubble.
        slider.maximumTrackTintColor = isOutgoing
            ? UIColor.white.withAlphaComponent(0.4)
            : CometChatTheme.neutralColor400

        downloadControl.controller = controller
        downloadControl.configure(fileUrl: fileUrl, fileName: fileName,
                                  tint: isOutgoing ? .white : CometChatTheme.primaryColor)

        loadDuration()
    }

    private func loadDuration() {
        guard let fileUrl = fileUrl, let url = URL(string: fileUrl) else { return }
        let asset = AVURLAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            let seconds = CMTimeGetSeconds(asset.duration)
            guard seconds.isFinite, seconds > 0 else { return }
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.totalSeconds = seconds
                self.slider.maximumValue = Float(seconds)
                if self.player?.rate == 0 || self.player == nil {
                    self.updateTime(current: 0)
                }
            }
        }
    }

    private func updateTime(current: Double) {
        timeLabel.text = "\(AudioFileRowView.format(current))/\(AudioFileRowView.format(totalSeconds))"
    }

    @objc private func togglePlay() {
        guard let fileUrl = fileUrl, let url = URL(string: fileUrl) else { return }
        if player == nil {
            player = AVPlayer(url: url)
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            didActivateAudioSession = true
            let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                guard let self = self, !self.isSeeking else { return }
                let current = CMTimeGetSeconds(time)
                if current.isFinite {
                    self.slider.value = Float(current)
                    self.updateTime(current: current)
                }
            }
            NotificationCenter.default.addObserver(self, selector: #selector(didFinish),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: player?.currentItem)
        }

        if player?.rate != 0 {
            pausePlayback()
        } else {
            AudioFileRowView.currentlyPlaying?.pausePlayback()
            AudioFileRowView.currentlyPlaying = self
            player?.play()
            playIconView.image = UIImage(systemName: "pause.fill")
        }
    }

    private func pausePlayback() {
        player?.pause()
        playIconView.image = UIImage(systemName: "play.fill")
    }

    @objc private func didFinish() {
        player?.seek(to: .zero)
        slider.value = 0
        updateTime(current: 0)
        playIconView.image = UIImage(systemName: "play.fill")
    }

    @objc private func sliderTouchDown() { isSeeking = true }

    @objc private func sliderChanged() {
        updateTime(current: Double(slider.value))
    }

    @objc private func sliderTouchUp() {
        let target = CMTime(seconds: Double(slider.value), preferredTimescale: 600)
        player?.seek(to: target) { [weak self] _ in self?.isSeeking = false }
        if player == nil { isSeeking = false }
    }

    private static func format(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

// MARK: - Download control (download icon → progress ring → save)

/// A tappable download affordance for file/audio cards. Idle shows a download icon;
/// tapping downloads the remote file with a progress ring into the app's Documents
/// (persistent), then presents a share/save sheet with the LOCAL file. Once a file is
/// downloaded, the control hides itself — on this and every future render (the local
/// copy is detected by `localCopy(for:)`). `onStateChange` lets the host swap its
/// subtitle to "Downloading…".
/// Opens a tapped file attachment: a downloaded local copy previews in-app with
/// QuickLook; otherwise the remote URL goes to the share sheet.
enum GalleryFileOpener {
    // Retains the in-flight downloader while a not-yet-cached file is fetched for preview.
    private static var pendingDownloader: FileDownloader?

    static func open(_ attachment: Attachment, from controller: UIViewController?) {
        let local = FileDownloadControl.localCopy(for: attachment.fileUrl, fileName: attachment.fileName)
        if FileManager.default.fileExists(atPath: local.path) {
            preview(local, from: controller)
            return
        }
        // Not cached yet: download the bytes first (brief loading HUD), then preview —
        // NOT the share sheet. Tapping a file always leads to a preview, downloaded or not.
        guard let url = URL(string: attachment.fileUrl) else { return }
        guard let controller = controller else { return }

        let hud = FilePreviewLoadingHUD()
        hud.present(over: controller)

        let downloader = FileDownloader()
        pendingDownloader = downloader
        downloader.onFinished = { savedURL in
            pendingDownloader = nil
            hud.dismiss {
                // Fall back to the cache path the file WAS downloaded to; if the download
                // failed, there's nothing to preview.
                let target = savedURL ?? (FileManager.default.fileExists(atPath: local.path) ? local : nil)
                guard let target else { return }
                preview(target, from: controller)
            }
        }
        downloader.download(from: url, to: local)
    }

    private static func preview(_ url: URL, from controller: UIViewController?) {
        if QLPreviewController.canPreview(url as NSURL) {
            QuickLookFilePreviewer.shared.present(url: url, from: controller)
        } else {
            // QuickLook genuinely can't render this type — the share sheet is the only
            // remaining way to hand the (now-local) file to another app.
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            controller?.present(activity, animated: true)
        }
    }
}

/// A minimal centered spinner shown over the presenting controller while a tapped file
/// is downloaded for preview.
final class FilePreviewLoadingHUD: UIViewController {
    private let spinner = UIActivityIndicatorView(style: .large)

    func present(over controller: UIViewController) {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        controller.present(self, animated: false)
    }

    func dismiss(then completion: @escaping () -> Void) {
        dismiss(animated: false, completion: completion)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

/// Retained QuickLook host — QLPreviewController holds its dataSource weakly, so the
/// previewed URL must live somewhere for the duration of the presentation.
final class QuickLookFilePreviewer: NSObject, QLPreviewControllerDataSource {
    static let shared = QuickLookFilePreviewer()
    private var url: URL?

    func present(url: URL, from controller: UIViewController?) {
        self.url = url
        let preview = QLPreviewController()
        preview.dataSource = self
        controller?.present(preview, animated: true)
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { url == nil ? 0 : 1 }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        (url ?? URL(fileURLWithPath: "")) as NSURL
    }
}

final class FileDownloadControl: UIView {

    weak var controller: UIViewController?
    var onStateChange: ((Bool) -> Void)?

    private var remoteURL: URL?
    private var fileName = "file"
    private var isDownloading = false
    private let downloader = FileDownloader()

    /// Persistent destination for a remote file: Documents/cc_downloads/<urlHash>_<name>.
    /// Keyed by a STABLE hash of host+path (Swift's Hasher is randomly seeded per app
    /// launch, so it must NOT be used for on-disk keys). The query string is excluded so
    /// signed URLs with rotating signatures still map to the same local file.
    static func localCopy(for remoteUrl: String, fileName: String) -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("cc_downloads", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let stableSource: String
        if let url = URL(string: remoteUrl) {
            stableSource = (url.host ?? "") + url.path
        } else {
            stableSource = remoteUrl
        }
        // djb2 — deterministic across launches.
        var hash: UInt64 = 5381
        for byte in stableSource.utf8 { hash = (hash &* 33) &+ UInt64(byte) }
        let key = String(hash, radix: 36)
        let safeName = fileName.isEmpty ? "file" : fileName
        return dir.appendingPathComponent("\(key)_\(safeName)")
    }

    static func isDownloaded(remoteUrl: String, fileName: String) -> Bool {
        FileManager.default.fileExists(atPath: localCopy(for: remoteUrl, fileName: fileName).path)
    }

    private let iconView: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "arrow.down.to.line"))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let ringLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 28),
            heightAnchor.constraint(equalToConstant: 28),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20)
        ])
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 2
        ringLayer.lineCap = .round
        ringLayer.strokeEnd = 0
        ringLayer.isHidden = true
        layer.addSublayer(ringLayer)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        isUserInteractionEnabled = true

        downloader.onProgress = { [weak self] progress in self?.ringLayer.strokeEnd = CGFloat(progress) }
        downloader.onFinished = { [weak self] url in self?.finish(localURL: url) }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = min(bounds.width, bounds.height) / 2 - ringLayer.lineWidth
        ringLayer.frame = bounds
        ringLayer.path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                      radius: max(0, radius),
                                      startAngle: -.pi / 2, endAngle: 1.5 * .pi,
                                      clockwise: true).cgPath
    }

    func configure(fileUrl: String, fileName: String, tint: UIColor) {
        remoteURL = URL(string: fileUrl)
        self.fileName = fileName.isEmpty ? "file" : fileName
        iconView.tintColor = tint
        ringLayer.strokeColor = tint.cgColor
        resetIdle()
        // The control ALWAYS stays available for a remote file — we can't know whether
        // the user actually saved/kept the file after an earlier tap (they may have
        // cancelled the Save-to-Files sheet, or want a fresh copy elsewhere), so the
        // download affordance never disappears. It's hidden only for a local composer
        // preview, where there's genuinely nothing to fetch.
        isHidden = (remoteURL?.isFileURL ?? true)
    }

    @objc private func tapped() {
        guard !isDownloading, let url = remoteURL, !url.isFileURL else { return }
        // Already fetched once → skip the network round-trip and re-export the cached
        // copy straight to the Save-to-Files sheet.
        let cached = FileDownloadControl.localCopy(for: url.absoluteString, fileName: fileName)
        if FileManager.default.fileExists(atPath: cached.path) {
            present(cached)
            return
        }
        isDownloading = true
        onStateChange?(true)
        iconView.isHidden = true
        ringLayer.isHidden = false
        ringLayer.strokeEnd = 0
        downloader.download(from: url, to: cached)
    }

    private func finish(localURL: URL?) {
        resetIdle()
        // Only present if the file is verifiably on disk; otherwise leave the download
        // option as-is so the user can retry. The control stays visible either way.
        guard let localURL = localURL,
              FileManager.default.fileExists(atPath: localURL.path) else { return }
        present(localURL)
    }

    private func resetIdle() {
        isDownloading = false
        onStateChange?(false)
        iconView.isHidden = false
        ringLayer.isHidden = true
        ringLayer.strokeEnd = 0
    }

    private func present(_ url: URL) {
        // Native iOS "Save to Files" experience: the document export picker lets the
        // user choose a folder (On My iPhone / iCloud Drive). `asCopy: true` exports a
        // copy while our Documents copy stays, so the downloaded state persists.
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(forExporting: [url], asCopy: true)
        } else {
            picker = UIDocumentPickerViewController(url: url, in: .exportToService)
        }
        controller?.present(picker, animated: true)
    }
}

/// URLSession download with progress + completion, moving the result to a caller-chosen
/// persistent destination and reporting the final local URL (nil on failure).
final class FileDownloader: NSObject, URLSessionDownloadDelegate {

    var onProgress: ((Double) -> Void)?
    var onFinished: ((URL?) -> Void)?

    private var session: URLSession?
    private var destination: URL?

    func download(from url: URL, to destination: URL) {
        self.destination = destination
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        session?.downloadTask(with: url).resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async { self.onProgress?(progress) }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        // A signed-URL failure (403/404) still "finishes" — with an error body instead of
        // the file. Only accept 2xx so we never persist junk as a downloaded file.
        if let http = downloadTask.response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            DispatchQueue.main.async { self.onFinished?(nil) }
            return
        }
        guard let dest = destination else {
            DispatchQueue.main.async { self.onFinished?(nil) }
            return
        }
        try? FileManager.default.createDirectory(at: dest.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
        try? FileManager.default.removeItem(at: dest)
        var ok = (try? FileManager.default.moveItem(at: location, to: dest)) != nil
        if !ok {
            // Move can fail across volumes/sandbox edges — fall back to a byte copy.
            ok = (try? FileManager.default.copyItem(at: location, to: dest)) != nil
        }
        let result: URL? = (ok && FileManager.default.fileExists(atPath: dest.path)) ? dest : nil
        DispatchQueue.main.async { self.onFinished?(result) }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil { DispatchQueue.main.async { self.onFinished?(nil) } }
    }
}
