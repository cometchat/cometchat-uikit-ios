//
//  CometChatAttachmentTileCell.swift
//  CometChatUIKitSwift
//
//  One attachment preview in the composer tray, styled to the design system:
//    • image / video → 72×72 thumbnail (video has a play badge + duration pill)
//    • file          → 200×72 card: colored type icon + name + TYPE
//    • audio         → 200×72 card: purple play circle + name + slider + time
//  States (DEFAULT / LOADING / ERROR):
//    • LOADING → the thumbnail (media) or the icon (chip) is dimmed with a white ring.
//    • ERROR   → red border + red badge (↻ retryable / ! rejected); chips add "Tap to
//      retry" / "Upload failed" text. Tapping a failed tile retries. ✕ always removes.
//

import UIKit
import AVFoundation

final class CometChatAttachmentTileCell: UICollectionViewCell {

    static let reuseId = "CometChatAttachmentTileCell"

    static let mediaSize = CGSize(width: 72, height: 72)
    static let chipSize = CGSize(width: 200, height: 72)

    var onClose: (() -> Void)?
    var onRetry: (() -> Void)?
    /// Tapped the tile body (not the ✕) on a non-failed tile — used to open the viewer.
    var onTileTap: (() -> Void)?

    private var status: AttachmentTileStatus = .uploading
    private var isMedia = false

    // Overlay position toggles: centered for media, over the left icon for chips.
    private var overlayMediaX: NSLayoutConstraint!
    private var overlayChipFileX: NSLayoutConstraint!
    private var overlayChipAudioX: NSLayoutConstraint!
    private var iconDimFileX: NSLayoutConstraint!
    private var iconDimAudioX: NSLayoutConstraint!
    private var stateIconCenterY: NSLayoutConstraint!

    // MARK: container

    private lazy var container: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CometChatSpacing.Radius.r2
        view.layer.borderWidth = 1
        view.clipsToBounds = true
        return view
    }()

    // MARK: media (image / video)

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var playOverlay: UIView = {
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        circle.layer.cornerRadius = 14
        circle.isHidden = true
        let icon = UIImageView(image: UIImage(systemName: "play.fill"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        circle.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 12),
            icon.heightAnchor.constraint(equalToConstant: 12)
        ])
        return circle
    }()

    private lazy var videoDurationLabel: UILabel = {
        let label = PaddingLabel(insets: UIEdgeInsets(top: 1, left: 5, bottom: 1, right: 5))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()

    // MARK: file chip

    private lazy var fileIconView: FileTypeIconView = {
        let view = FileTypeIconView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }()

    private lazy var fileNameLabel = Self.makeNameLabel()
    private lazy var fileTypeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = CometChatTheme.textColorSecondary
        return label
    }()

    private lazy var fileChip: UIStackView = {
        let text = UIStackView(arrangedSubviews: [fileNameLabel, fileTypeLabel])
        text.axis = .vertical
        text.spacing = 2
        let stack = UIStackView(arrangedSubviews: [fileIconView, text])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isHidden = true
        return stack
    }()

    // MARK: audio chip

    private lazy var audioIconView: UIImageView = {
        let icon = UIImageView(image: UIImage(systemName: "play.fill"))
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()

    private lazy var audioCircle: UIView = {
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = CometChatTheme.primaryColor
        circle.layer.cornerRadius = 22
        circle.isUserInteractionEnabled = true
        circle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleAudio)))
        circle.widthAnchor.constraint(equalToConstant: 44).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 44).isActive = true
        circle.addSubview(audioIconView)
        NSLayoutConstraint.activate([
            audioIconView.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            audioIconView.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            audioIconView.widthAnchor.constraint(equalToConstant: 15),
            audioIconView.heightAnchor.constraint(equalToConstant: 15)
        ])
        return circle
    }()

    private lazy var audioNameLabel = Self.makeNameLabel()

    private lazy var audioSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.minimumTrackTintColor = CometChatTheme.primaryColor
        slider.maximumTrackTintColor = CometChatTheme.neutralColor300
        slider.setThumbImage(Self.sliderThumb(), for: .normal)
        slider.addTarget(self, action: #selector(audioSeek), for: .valueChanged)
        return slider
    }()

    // Audio playback (tray preview). Only one cell plays at a time.
    private static weak var playingCell: CometChatAttachmentTileCell?
    private var audioPlayer: AVAudioPlayer?
    private var audioTimer: Timer?
    private var audioData: Data?
    private var audioTotal: Double = 0

    private lazy var audioTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = CometChatTheme.textColorSecondary
        return label
    }()

    private lazy var chipErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = CometChatTheme.errorColor
        label.text = "attachment_upload_failed_retry".localize()
        label.isHidden = true
        return label
    }()

    private lazy var audioChip: UIStackView = {
        let text = UIStackView(arrangedSubviews: [audioNameLabel, audioSlider, audioTimeLabel])
        text.axis = .vertical
        text.spacing = 2
        text.alignment = .fill
        let stack = UIStackView(arrangedSubviews: [audioCircle, text])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        stack.isHidden = true
        return stack
    }()

    // MARK: state overlays

    /// Full-tile dim for MEDIA loading/error.
    private lazy var mediaDim: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()

    /// Dim over the CHIP icon (rounded square for file, circle for audio).
    private lazy var iconDim: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    private var iconDimWidth: NSLayoutConstraint!
    private var iconDimHeight: NSLayoutConstraint!

    private lazy var ringView: CircularProgressView = {
        let view = CircularProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var stateIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "exclamationmark.circle",
                                                   withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    // MARK: corner remove/cancel

    private lazy var closeBadge: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.backgroundColor = CometChatTheme.neutralColor900
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeTapped)))
        return view
    }()

    private lazy var closeIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        // Badge bg is neutralColor900 (dark in light mode, white in dark), so tint the ✕
        // with its inverse (neutralColor50) to stay visible in both.
        imageView.tintColor = CometChatTheme.neutralColor50
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildUI() {
        contentView.clipsToBounds = false
        clipsToBounds = false

        contentView.addSubview(container)
        container.addSubview(imageView)
        container.addSubview(playOverlay)
        container.addSubview(videoDurationLabel)
        container.addSubview(fileChip)
        container.addSubview(audioChip)
        container.addSubview(mediaDim)
        container.addSubview(iconDim)
        container.addSubview(ringView)
        container.addSubview(stateIcon)

        // audioChip's error line sits under the name, replacing slider/time on error.
        if let text = audioChip.arrangedSubviews.last as? UIStackView {
            text.addArrangedSubview(chipErrorLabel)
        }

        contentView.addSubview(closeBadge)
        closeBadge.addSubview(closeIcon)

        // A single tap anywhere on a failed tile retries.
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tileTapped)))

        iconDimWidth = iconDim.widthAnchor.constraint(equalToConstant: 40)
        iconDimHeight = iconDim.heightAnchor.constraint(equalToConstant: 40)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: container.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            playOverlay.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            playOverlay.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            playOverlay.widthAnchor.constraint(equalToConstant: 28),
            playOverlay.heightAnchor.constraint(equalToConstant: 28),

            videoDurationLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 6),
            videoDurationLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),

            fileChip.topAnchor.constraint(equalTo: container.topAnchor),
            fileChip.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            fileChip.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            fileChip.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            audioChip.topAnchor.constraint(equalTo: container.topAnchor),
            audioChip.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            audioChip.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            audioChip.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            mediaDim.topAnchor.constraint(equalTo: container.topAnchor),
            mediaDim.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            mediaDim.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            mediaDim.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            iconDim.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconDimWidth, iconDimHeight,

            ringView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ringView.widthAnchor.constraint(equalToConstant: 26),
            ringView.heightAnchor.constraint(equalToConstant: 26),

            stateIcon.centerXAnchor.constraint(equalTo: ringView.centerXAnchor),
            stateIcon.widthAnchor.constraint(equalToConstant: 24),
            stateIcon.heightAnchor.constraint(equalToConstant: 24),


            closeBadge.widthAnchor.constraint(equalToConstant: 20),
            closeBadge.heightAnchor.constraint(equalToConstant: 20),
            closeBadge.centerXAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            closeBadge.centerYAnchor.constraint(equalTo: container.topAnchor, constant: 4),

            closeIcon.centerXAnchor.constraint(equalTo: closeBadge.centerXAnchor),
            closeIcon.centerYAnchor.constraint(equalTo: closeBadge.centerYAnchor),
            closeIcon.widthAnchor.constraint(equalToConstant: 11),
            closeIcon.heightAnchor.constraint(equalToConstant: 11)
        ])

        // Overlays are pinned to the ACTUAL icon views so the dim/ring/! always sit
        // exactly over the file icon (40pt square) or the audio play circle (44pt).
        overlayMediaX = ringView.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        overlayChipFileX = ringView.centerXAnchor.constraint(equalTo: fileIconView.centerXAnchor)
        overlayChipAudioX = ringView.centerXAnchor.constraint(equalTo: audioCircle.centerXAnchor)
        iconDimFileX = iconDim.centerXAnchor.constraint(equalTo: fileIconView.centerXAnchor)
        iconDimAudioX = iconDim.centerXAnchor.constraint(equalTo: audioCircle.centerXAnchor)
        // Shifts up when the "Retry" caption shows so the !+Retry group is centered.
        stateIconCenterY = stateIcon.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        stateIconCenterY.isActive = true
        overlayMediaX.isActive = true
        iconDimFileX.isActive = true
    }

    func configure(with tile: AttachmentTile) {
        status = tile.status
        let kind = tile.kind
        isMedia = (kind == .image || kind == .video)
        let isAudio = (kind == .audio)

        imageView.isHidden = !isMedia
        playOverlay.isHidden = (kind != .video)
        fileChip.isHidden = !(kind == .file)
        audioChip.isHidden = !isAudio

        // Overlay position: centered for media; pinned exactly to the icon for chips.
        [overlayMediaX, overlayChipFileX, overlayChipAudioX, iconDimFileX, iconDimAudioX].forEach { $0?.isActive = false }
        if isMedia {
            overlayMediaX.isActive = true
            iconDimFileX.isActive = true    // unused (iconDim hidden), but keeps layout resolvable
        } else if isAudio {
            overlayChipAudioX.isActive = true
            iconDimAudioX.isActive = true
        } else {
            overlayChipFileX.isActive = true
            iconDimFileX.isActive = true
        }

        // Shape the chip icon-dim to mirror the covered icon EXACTLY — same size, same
        // curve (circle over the audio circle; the file icon's own radius over files).
        iconDimWidth.constant = isAudio ? 44 : 40
        iconDimHeight.constant = isAudio ? 44 : 40
        iconDim.layer.cornerRadius = isAudio ? 22 : FileTypeIconView.cornerRadius

        if isMedia {
            container.backgroundColor = CometChatTheme.backgroundColor04
            imageView.image = tile.previewImage
            if kind == .video {
                let duration = CometChatAttachmentTileCell.timeString(for: tile.file.data)
                videoDurationLabel.text = duration
                videoDurationLabel.isHidden = duration.isEmpty
            } else {
                videoDurationLabel.isHidden = true
            }
        } else {
            container.backgroundColor = CometChatTheme.backgroundColor02
            videoDurationLabel.isHidden = true
            if isAudio {
                // Reset any playback carried over from a reused cell.
                stopAudio()
                audioIconView.image = UIImage(systemName: "play.fill")
                audioData = tile.file.data
                audioTotal = CometChatAttachmentTileCell.duration(for: tile.file.data)
                audioNameLabel.text = tile.fileName
                audioSlider.value = 0
                audioTimeLabel.text = "00:00/\(CometChatAttachmentTileCell.clock(audioTotal))"
            } else {
                // MIME + filename classification (either signal), Android-parity.
                fileIconView.configure(mimeType: tile.mimeType, fileUrl: tile.fileName)
                fileNameLabel.text = tile.fileName
                let ext = (tile.fileName as NSString).pathExtension.uppercased()
                fileTypeLabel.text = ext.isEmpty ? "FILE" : ext
            }
        }

        applyState(tile.status, percent: tile.percent, isAudio: isAudio)
    }

    private func applyState(_ status: AttachmentTileStatus, percent: Int, isAudio: Bool) {
        let isError = (status == .failed || status == .rejected)

        // Red border on error, subtle default border otherwise.
        container.layer.borderWidth = isError ? 1.5 : (isMedia ? 0 : 1)
        container.layer.borderColor = isError
            ? CometChatTheme.errorColor.cgColor
            : CometChatTheme.borderColorDefault.cgColor

        // ✕ is ALWAYS available (uploading → cancels, otherwise removes) so the user can
        // drop a file at any point; only a cancelled tile (about to disappear) hides it.
        closeBadge.isHidden = false

        // Dim: whole tile for media, just the icon for chips.
        let showDim = (status == .uploading) || isError
        mediaDim.isHidden = !(isMedia && showDim)
        iconDim.isHidden = !(!isMedia && showDim)

        // While dimmed, the ring/!/Retry own the center — hide the video play badge and
        // duration pill so they don't overlap.
        if showDim {
            playOverlay.isHidden = true
            videoDurationLabel.isHidden = true
        }

        // Audio preview must not be playable while uploading or in error — the dimmed
        // circle would swallow the tap anyway; on error the tile tap means "retry".
        audioCircle.isUserInteractionEnabled = !showDim

        // Chip error text ("Upload failed · Retry").
        if !isMedia {
            if isAudio {
                let hideNormal = isError
                audioSlider.isHidden = hideNormal
                audioTimeLabel.isHidden = hideNormal
                chipErrorLabel.isHidden = !isError
                chipErrorLabel.text = (status == .rejected)
                    ? "attachment_upload_failed".localize()
                    : "attachment_upload_failed_retry".localize()
            } else {
                if isError {
                    fileTypeLabel.text = (status == .rejected)
                        ? "attachment_upload_failed".localize()
                        : "attachment_upload_failed_retry".localize()
                    fileTypeLabel.textColor = CometChatTheme.errorColor
                } else {
                    fileTypeLabel.textColor = CometChatTheme.textColorSecondary
                }
            }
        }

        switch status {
        case .uploading:
            ringView.isHidden = false
            ringView.progress = CGFloat(max(0, min(100, percent))) / 100.0
            stateIcon.isHidden = true

        case .done:
            ringView.isHidden = true
            stateIcon.isHidden = true

        case .failed, .rejected:
            ringView.isHidden = true
            stateIcon.isHidden = false
            // Same treatment everywhere (media tiles AND chips): a red circular badge —
            // ↻ when retryable (network/S3 failure, tap the tile to retry), ! when
            // rejected (mime/size validation, nothing to retry).
            let retryable = (status == .failed)
            stateIcon.backgroundColor = CometChatTheme.errorColor
            stateIcon.layer.cornerRadius = 12
            stateIcon.clipsToBounds = true
            stateIcon.contentMode = .center
            let config = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
            stateIcon.image = UIImage(systemName: retryable ? "arrow.clockwise" : "exclamationmark",
                                      withConfiguration: config)

        case .cancelled:
            ringView.isHidden = true
            stateIcon.isHidden = true
            closeBadge.isHidden = true
        }
    }

    @objc private func tileTapped() {
        // A failed tile retries; any other tile opens the viewer (media) / no-op (chip).
        if status == .failed { onRetry?() } else { onTileTap?() }
    }

    @objc private func closeTapped() {
        onClose?()
    }

    // MARK: audio playback

    @objc private func toggleAudio() {
        guard let data = audioData else { return }
        if audioPlayer == nil {
            audioPlayer = try? AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            if audioTotal <= 0 { audioTotal = audioPlayer?.duration ?? 0 }
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
        }
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            pauseAudio()
        } else {
            CometChatAttachmentTileCell.playingCell?.pauseAudio()
            CometChatAttachmentTileCell.playingCell = self
            player.play()
            audioIconView.image = UIImage(systemName: "pause.fill")
            startAudioTimer()
        }
    }

    private func pauseAudio() {
        audioPlayer?.pause()
        audioIconView.image = UIImage(systemName: "play.fill")
        audioTimer?.invalidate()
        audioTimer = nil
    }

    private func stopAudio() {
        audioTimer?.invalidate(); audioTimer = nil
        audioPlayer?.stop(); audioPlayer = nil
        if CometChatAttachmentTileCell.playingCell === self { CometChatAttachmentTileCell.playingCell = nil }
    }

    private func startAudioTimer() {
        audioTimer?.invalidate()
        audioTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer, self.audioTotal > 0 else { return }
            self.audioSlider.value = Float(player.currentTime / self.audioTotal)
            self.audioTimeLabel.text = "\(Self.clock(player.currentTime))/\(Self.clock(self.audioTotal))"
        }
    }

    @objc private func audioSeek() {
        guard audioTotal > 0 else { return }
        let target = Double(audioSlider.value) * audioTotal
        audioPlayer?.currentTime = target
        audioTimeLabel.text = "\(Self.clock(target))/\(Self.clock(audioTotal))"
    }

    // MARK: helpers

    private static func makeNameLabel() -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = CometChatTheme.textColorPrimary
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }

    private static func sliderThumb() -> UIImage {
        let size = CGSize(width: 12, height: 12)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            ctx.cgContext.setStrokeColor(UIColor.black.withAlphaComponent(0.12).cgColor)
            ctx.cgContext.setLineWidth(0.5)
            ctx.cgContext.strokeEllipse(in: CGRect(x: 0.25, y: 0.25, width: 11.5, height: 11.5))
        }
    }

    private static func timeString(for data: Data?) -> String {
        let d = duration(for: data)
        return d > 0 ? clock(d) : ""
    }

    private static func duration(for data: Data?) -> Double {
        guard let data = data, let player = try? AVAudioPlayer(data: data) else { return 0 }
        return player.duration
    }

    private static func clock(_ seconds: Double) -> String {
        let t = Int(seconds.rounded())
        return String(format: "%02d:%02d", t / 60, t % 60)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        ringView.progress = 0
        ringView.isHidden = true
        stateIcon.isHidden = true
        stateIcon.backgroundColor = .clear
        stateIcon.layer.cornerRadius = 0
        stateIcon.contentMode = .scaleAspectFit
        mediaDim.isHidden = true
        iconDim.isHidden = true
        chipErrorLabel.isHidden = true
        audioSlider.isHidden = false
        audioTimeLabel.isHidden = false
        fileTypeLabel.textColor = CometChatTheme.textColorSecondary
        stopAudio()
        audioIconView.image = UIImage(systemName: "play.fill")
        audioSlider.value = 0
        audioData = nil
        onClose = nil
        onRetry = nil
        onTileTap = nil
    }
}

extension CometChatAttachmentTileCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioIconView.image = UIImage(systemName: "play.fill")
        audioSlider.value = 0
        audioTimer?.invalidate()
        audioTimer = nil
        audioTimeLabel.text = "00:00/\(CometChatAttachmentTileCell.clock(audioTotal))"
    }
}

// MARK: - Padding label (video duration pill)

final class PaddingLabel: UILabel {
    private let insets: UIEdgeInsets
    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func drawText(in rect: CGRect) { super.drawText(in: rect.inset(by: insets)) }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}

// MARK: - Self-centering circular progress ring

final class CircularProgressView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    /// 0...1
    var progress: CGFloat = 0 {
        didSet { progressLayer.strokeEnd = max(0, min(1, progress)) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.white.withAlphaComponent(0.3).cgColor
        trackLayer.lineWidth = 2.5

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = 2.5
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Lay the ring out in THIS view's own bounds, so it's always perfectly centered
        // regardless of when/where the cell is sized.
        trackLayer.frame = bounds
        progressLayer.frame = bounds
        let radius = min(bounds.width, bounds.height) / 2 - progressLayer.lineWidth / 2
        let path = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                radius: max(0, radius),
                                startAngle: -.pi / 2,
                                endAngle: 1.5 * .pi,
                                clockwise: true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }
}
