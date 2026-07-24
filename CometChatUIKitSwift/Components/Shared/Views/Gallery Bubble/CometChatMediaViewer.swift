//
//  CometChatMediaViewer.swift
//  CometChatUIKitSwift
//
//  Fullscreen, swipeable viewer for a message's media attachments (image/* + video/*).
//  Opened when a tile in an `ImagesBubble` / `VideoBubble` is tapped. Pages through every
//  media item starting at the tapped index; images are zoomable, videos play inline.
//

import UIKit
import AVKit
import AVFoundation
import CometChatSDK

public class CometChatMediaViewer: UIViewController {

    private let mediaItems: [Attachment]
    private var currentIndex: Int

    private lazy var pageController: UIPageViewController = {
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: [.interPageSpacing: 16]
        )
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return button
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        return button
    }()

    /// Per-photo download: saves the CURRENTLY displayed photo (progress ring, persisted
    /// to Documents/cc_downloads, then the "Save to Files" export picker). Reuses the same
    /// control as the file cards, so it also auto-hides once the photo is downloaded.
    private lazy var downloadControl: FileDownloadControl = {
        let control = FileDownloadControl()
        control.controller = self
        return control
    }()

    private lazy var muteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleMute), for: .touchUpInside)
        return button
    }()

    /// True when opened from the composer tray (local, not-yet-sent previews): the
    /// chrome is minimal — close + mute on videos, no share/download.
    public var isLocalPreview: Bool = false

    private var isMuted = false

    // MARK: - Init

    public init(mediaItems: [Attachment], startIndex: Int) {
        self.mediaItems = mediaItems
        self.currentIndex = max(0, min(startIndex, max(0, mediaItems.count - 1)))
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        addChild(pageController)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)

        // The top bar owns its own opaque strip (status-bar area included) and the media
        // pages are laid out BELOW it — the controls never sit on top of a photo/video,
        // so they stay visible regardless of how bright the media behind them is.
        let topBarBackground = UIView()
        topBarBackground.backgroundColor = .black
        topBarBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarBackground)

        let topBar = UIView()
        topBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBar)
        topBar.addSubview(closeButton)
        topBar.addSubview(counterLabel)

        // Hairline under the bar delineates the controls area from the media area.
        let separator = UIView()
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        separator.translatesAutoresizingMaskIntoConstraints = false
        topBarBackground.addSubview(separator)

        // Right-side actions live in a stack so hidden buttons collapse with no gaps.
        let actionsStack = UIStackView(arrangedSubviews: [muteButton, downloadControl, shareButton])
        actionsStack.axis = .horizontal
        actionsStack.alignment = .center
        actionsStack.spacing = 12
        actionsStack.translatesAutoresizingMaskIntoConstraints = false
        topBar.addSubview(actionsStack)

        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            topBarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            topBarBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarBackground.bottomAnchor.constraint(equalTo: topBar.bottomAnchor),

            separator.leadingAnchor.constraint(equalTo: topBarBackground.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: topBarBackground.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: topBarBackground.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 44),

            closeButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            closeButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            counterLabel.centerXAnchor.constraint(equalTo: topBar.centerXAnchor),
            counterLabel.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            actionsStack.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            actionsStack.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),

            muteButton.widthAnchor.constraint(equalToConstant: 32),
            muteButton.heightAnchor.constraint(equalToConstant: 32),
            shareButton.widthAnchor.constraint(equalToConstant: 32),
            shareButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        // Swipe down to dismiss.
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleClose))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)

        if let firstPage = page(at: currentIndex) {
            pageController.setViewControllers([firstPage], direction: .forward, animated: false)
        }
        updateCounter()
        updateChromeForCurrentItem()
    }

    // MARK: - Helpers

    private func page(at index: Int) -> MediaPageViewController? {
        guard index >= 0, index < mediaItems.count else { return nil }
        return MediaPageViewController(attachment: mediaItems[index], index: index)
    }

    private func updateCounter() {
        counterLabel.text = "\(currentIndex + 1) / \(mediaItems.count)"
    }

    /// Chrome per context and page:
    ///  • composer preview (isLocalPreview): X always; mute on video pages; no share/download.
    ///  • message list: X always; video pages show mute + share; photo pages show
    ///    share + a download for THIS photo (hidden once it's already downloaded).
    /// The counter only shows for multi-item galleries (no "1/1" for a single item).
    private func updateChromeForCurrentItem() {
        let kind: GalleryMediaKind = currentIndex < mediaItems.count
            ? galleryMediaKind(for: mediaItems[currentIndex])
            : .image
        let isVideo = kind == .video
        // A page the viewer can't render (kind mismatch, e.g. an mp3 swiped to in an
        // image gallery) shows the black no-preview state: no share, but the download
        // control stays — any file can be saved.
        let isUnsupported = kind != .image && kind != .video
        closeButton.isHidden = false
        counterLabel.isHidden = mediaItems.count < 2
        muteButton.isHidden = !isVideo
        shareButton.isHidden = isLocalPreview || isUnsupported
        if currentIndex < mediaItems.count {
            let item = mediaItems[currentIndex]
            // configure() hides the control for local previews and already-downloaded files.
            downloadControl.configure(fileUrl: item.fileUrl, fileName: item.fileName, tint: .white)
        }
        if isLocalPreview || isVideo { downloadControl.isHidden = true }
        applyMuteToCurrentPage()
    }

    @objc private func handleClose() {
        dismiss(animated: true)
    }

    @objc private func handleMute() {
        isMuted.toggle()
        muteButton.setImage(UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"), for: .normal)
        applyMuteToCurrentPage()
    }

    private func applyMuteToCurrentPage() {
        muteButton.setImage(UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"), for: .normal)
        (pageController.viewControllers?.first as? MediaPageViewController)?.setMuted(isMuted)
    }

    private lazy var downloadIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    @objc private func handleShare() {
        guard currentIndex < mediaItems.count else { return }
        downloadAndShare([mediaItems[currentIndex]], from: shareButton)
    }

    /// Downloads each attachment's bytes to a temporary file, then shares those LOCAL
    /// files so the user can actually Save to Photos / Files. Passing remote URLs to
    /// the share sheet would only share the links, not the media.
    private func downloadAndShare(_ attachments: [Attachment], from sourceView: UIView) {
        let remotes = attachments.compactMap { attachment -> (Attachment, URL)? in
            guard let url = URL(string: attachment.fileUrl) else { return nil }
            return (attachment, url)
        }
        guard !remotes.isEmpty else { return }

        setDownloading(true)
        let group = DispatchGroup()
        var localFiles: [URL] = []
        let lock = NSLock()

        for (attachment, remoteURL) in remotes {
            group.enter()
            URLSession.shared.downloadTask(with: remoteURL) { tempURL, response, _ in
                defer { group.leave() }
                guard let tempURL = tempURL else { return }
                // Only share a genuine 2xx payload — an expired/403 signed URL otherwise
                // gets moved and shared as a corrupt file. (Same gate as the other
                // download paths: handleNoPreviewDownload / FileDownloader.)
                let ok = (response as? HTTPURLResponse).map { (200..<300).contains($0.statusCode) } ?? true
                guard ok else { return }
                let preferredName = attachment.fileName.isEmpty ? remoteURL.lastPathComponent : attachment.fileName
                let fileName = preferredName.isEmpty ? "media" : preferredName
                // Unique subdirectory keeps the original filename and avoids collisions.
                let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                let dest = dir.appendingPathComponent(fileName)
                do {
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                    try FileManager.default.moveItem(at: tempURL, to: dest)
                    lock.lock(); localFiles.append(dest); lock.unlock()
                } catch { }
            }.resume()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.setDownloading(false)
            guard !localFiles.isEmpty else { return }
            let activity = UIActivityViewController(activityItems: localFiles, applicationActivities: nil)
            activity.popoverPresentationController?.sourceView = sourceView
            self.present(activity, animated: true)
        }
    }

    private func setDownloading(_ downloading: Bool) {
        if downloading {
            if downloadIndicator.superview == nil {
                view.addSubview(downloadIndicator)
                NSLayoutConstraint.activate([
                    downloadIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    downloadIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
            }
            view.bringSubviewToFront(downloadIndicator)
            downloadIndicator.startAnimating()
        } else {
            downloadIndicator.stopAnimating()
        }
        shareButton.isEnabled = !downloading
    }
}

// MARK: - Paging

extension CometChatMediaViewer: UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? MediaPageViewController else { return nil }
        return self.page(at: page.index - 1)
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let page = viewController as? MediaPageViewController else { return nil }
        return self.page(at: page.index + 1)
    }

    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        guard completed,
              let page = pageViewController.viewControllers?.first as? MediaPageViewController else { return }
        currentIndex = page.index
        updateCounter()
        updateChromeForCurrentItem()
    }
}

// MARK: - Single media page (image = zoomable, video = inline player)

final class MediaPageViewController: UIViewController {

    let attachment: Attachment
    let index: Int

    private let imageService = ImageService()
    private var imageRequest: Cancellable?
    private var videoPlayerView: VideoPlayerView?
    private var pendingMuted: Bool?

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 4
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(attachment: Attachment, index: Int) {
        self.attachment = attachment
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        switch galleryMediaKind(for: attachment) {
        case .video:
            setupVideo()
        case .image:
            setupImage()
        default:
            // Kind mismatch (an mp3/pdf swiped to inside an image/video gallery):
            // the black page just says "no preview available".
            setupNoPreview()
        }
    }

    private func setupNoPreview() {
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        circle.layer.cornerRadius = 48

        let glyph = UIImageView(image: UIImage(named: "unsupported", in: CometChatUIKit.bundle, compatibleWith: nil))
        glyph.translatesAutoresizingMaskIntoConstraints = false
        glyph.contentMode = .scaleAspectFit
        circle.addSubview(glyph)

        let titleLabel = UILabel()
        titleLabel.text = "attachment_no_preview_title".localize()
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "attachment_no_preview_subtitle".localize()
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        // In-page Download button (the top-bar download control also stays visible).
        noPreviewDownloadButton.addSubview(noPreviewDownloadSpinner)

        let stack = UIStackView(arrangedSubviews: [circle, titleLabel, subtitleLabel, noPreviewDownloadButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(20, after: circle)
        stack.setCustomSpacing(24, after: subtitleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            circle.widthAnchor.constraint(equalToConstant: 96),
            circle.heightAnchor.constraint(equalToConstant: 96),
            glyph.centerXAnchor.constraint(equalTo: circle.centerXAnchor),
            glyph.centerYAnchor.constraint(equalTo: circle.centerYAnchor),
            glyph.widthAnchor.constraint(equalToConstant: 40),
            glyph.heightAnchor.constraint(equalToConstant: 40),

            noPreviewDownloadButton.heightAnchor.constraint(equalToConstant: 48),
            noPreviewDownloadButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            noPreviewDownloadSpinner.centerXAnchor.constraint(equalTo: noPreviewDownloadButton.centerXAnchor),
            noPreviewDownloadSpinner.centerYAnchor.constraint(equalTo: noPreviewDownloadButton.centerYAnchor),

            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
    }

    private lazy var noPreviewDownloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = CometChatTheme.primaryColor
        button.layer.cornerRadius = CometChatSpacing.Radius.r3
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.setTitle(" " + "attachment_download".localize(), for: .normal)
        button.setImage(UIImage(systemName: "arrow.down.to.line",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
                        for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        button.addTarget(self, action: #selector(handleNoPreviewDownload), for: .touchUpInside)
        return button
    }()

    private lazy var noPreviewDownloadSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()

    private var isDownloadingNoPreview = false

    /// Downloads the unsupported attachment's bytes to a temp file, then hands the LOCAL
    /// file to the share sheet (Save to Files / Photos). A remote URL alone would only
    /// share the link.
    @objc private func handleNoPreviewDownload() {
        guard !isDownloadingNoPreview, let url = URL(string: attachment.fileUrl) else { return }
        isDownloadingNoPreview = true
        noPreviewDownloadButton.setTitle(nil, for: .normal)
        noPreviewDownloadButton.setImage(nil, for: .normal)
        noPreviewDownloadSpinner.startAnimating()

        let preferredName = attachment.fileName.isEmpty ? url.lastPathComponent : attachment.fileName
        let fileName = preferredName.isEmpty ? "file" : preferredName
        URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, _ in
            var localURL: URL?
            if let tempURL,
               (response as? HTTPURLResponse).map({ (200..<300).contains($0.statusCode) }) ?? true {
                let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                let dest = dir.appendingPathComponent(fileName)
                do {
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                    try FileManager.default.moveItem(at: tempURL, to: dest)
                    localURL = dest
                } catch { }
            }
            DispatchQueue.main.async {
                guard let self else { return }
                self.isDownloadingNoPreview = false
                self.noPreviewDownloadSpinner.stopAnimating()
                self.noPreviewDownloadButton.setTitle(" " + "attachment_download".localize(), for: .normal)
                self.noPreviewDownloadButton.setImage(UIImage(systemName: "arrow.down.to.line",
                                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
                                                      for: .normal)
                guard let localURL else { return }
                let activity = UIActivityViewController(activityItems: [localURL], applicationActivities: nil)
                activity.popoverPresentationController?.sourceView = self.noPreviewDownloadButton
                self.present(activity, animated: true)
            }
        }.resume()
    }

    private func setupImage() {
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        activityIndicator.startAnimating()
        guard let url = URL(string: attachment.fileUrl) else {
            activityIndicator.stopAnimating()
            return
        }
        // Local previews (composer tray) use file:// URLs, which URLSession's dataTask
        // can't load — read the file directly. Remote messages go through the image cache.
        if url.isFileURL {
            activityIndicator.stopAnimating()
            imageView.image = UIImage(contentsOfFile: url.path)
            return
        }
        imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
            self?.activityIndicator.stopAnimating()
            self?.imageView.image = image
        }
    }

    private func setupVideo() {
        guard let url = URL(string: attachment.fileUrl) else { return }
        // A plain AVPlayerLayer-backed view with minimal controls (center play/pause +
        // bottom scrubber). No AirPlay / PiP / route buttons — the viewer's top bar owns
        // close / mute / share, so nothing overlaps.
        let videoView = VideoPlayerView(url: url)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)
        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: view.topAnchor),
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        videoPlayerView = videoView
    }

    /// Applies the viewer's mute state to this page's video (no-op for images).
    func setMuted(_ muted: Bool) {
        pendingMuted = muted
        videoPlayerView?.setMuted(muted)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let muted = pendingMuted { videoPlayerView?.setMuted(muted) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayerView?.pause()
    }

    deinit {
        imageRequest?.cancel()
        videoPlayerView?.stop()
    }
}

extension MediaPageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

// MARK: - Minimal video player (no AirPlay / PiP / native chrome)

/// AVPlayerLayer-backed player with just a center play/pause button and a bottom
/// scrubber (current / remaining time). Tap the video to toggle the controls. Mute is
/// driven externally by the viewer's top-bar speaker button.
final class VideoPlayerView: UIView {

    override class var layerClass: AnyClass { AVPlayerLayer.self }
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    private let player: AVPlayer
    private var timeObserver: Any?
    private var totalSeconds: Double = 0
    private var isScrubbing = false
    private var didEnd = false
    private var didActivateAudioSession = false

    private let loader = UIActivityIndicatorView(style: .large)
    private let playPauseButton = UIButton(type: .system)
    private let currentTimeLabel = UILabel()
    private let remainingTimeLabel = UILabel()
    private let slider = UISlider()
    private let bottomBar = UIStackView()

    init(url: URL) {
        player = AVPlayer(url: url)
        super.init(frame: .zero)
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspect
        backgroundColor = .black
        buildControls()
        addObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit { stop() }

    func setMuted(_ muted: Bool) { player.isMuted = muted }

    func pause() {
        player.pause()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }

    func stop() {
        player.pause()
        if let token = timeObserver { player.removeTimeObserver(token); timeObserver = nil }
        NotificationCenter.default.removeObserver(self)
        deactivateAudioSession()
    }

    private func buildControls() {
        // No upfront spinner — the first frame renders as the poster; the duration is
        // loaded asynchronously below. The loader only appears if playback stalls.
        loader.color = .white
        loader.hidesWhenStopped = true
        loader.translatesAutoresizingMaskIntoConstraints = false
        addSubview(loader)

        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 52, weight: .regular)
        playPauseButton.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        playPauseButton.addTarget(self, action: #selector(togglePlay), for: .touchUpInside)
        addSubview(playPauseButton)

        [currentTimeLabel, remainingTimeLabel].forEach {
            $0.font = .systemFont(ofSize: 12, weight: .medium)
            $0.textColor = .white
        }
        currentTimeLabel.text = "0:00"
        remainingTimeLabel.text = "-0:00"

        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.35)
        slider.setThumbImage(VideoPlayerView.thumbImage(), for: .normal)
        slider.setThumbImage(VideoPlayerView.thumbImage(), for: .highlighted)
        slider.addTarget(self, action: #selector(scrubStart), for: .touchDown)
        slider.addTarget(self, action: #selector(scrubChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(scrubEnd), for: [.touchUpInside, .touchUpOutside])

        bottomBar.axis = .horizontal
        bottomBar.alignment = .center
        bottomBar.spacing = 10
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addArrangedSubview(currentTimeLabel)
        bottomBar.addArrangedSubview(slider)
        bottomBar.addArrangedSubview(remainingTimeLabel)
        addSubview(bottomBar)

        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: centerYAnchor),

            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bottomBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomBar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    private static func thumbImage() -> UIImage {
        let size = CGSize(width: 14, height: 14)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }

    private func addObservers() {
        // NOTE: the audio session is NOT activated here. This runs at page construction,
        // and UIPageViewController(.scroll) pre-builds neighbor pages — activating now
        // would interrupt the user's background audio just by opening/swiping, before
        // they ever hit play. Activation is deferred to togglePlay(); deactivation
        // happens in stop() so background audio resumes on dismiss.

        // Load the duration up front (async) so the scrubber/labels are ready before play.
        if let asset = player.currentItem?.asset {
            asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
                let dur = CMTimeGetSeconds(asset.duration)
                guard dur.isFinite, dur > 0 else { return }
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.totalSeconds = dur
                    self.slider.maximumValue = Float(dur)
                    self.remainingTimeLabel.text = "-" + VideoPlayerView.format(dur)
                }
            }
        }

        let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            if self.totalSeconds == 0, let item = self.player.currentItem {
                let dur = CMTimeGetSeconds(item.duration)
                if dur.isFinite, dur > 0 {
                    self.totalSeconds = dur
                    self.slider.maximumValue = Float(dur)
                    self.remainingTimeLabel.text = "-" + VideoPlayerView.format(dur)
                }
            }
            guard !self.isScrubbing else { return }
            let current = CMTimeGetSeconds(time)
            if current.isFinite {
                self.slider.value = Float(current)
                self.currentTimeLabel.text = VideoPlayerView.format(current)
                self.remainingTimeLabel.text = "-" + VideoPlayerView.format(max(0, self.totalSeconds - current))
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(playerDidEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
    }

    @objc private func togglePlay() {
        if didEnd {
            didEnd = false
            player.seek(to: .zero)
        }
        if player.rate != 0 {
            pause()
        } else {
            activateAudioSession()
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }

    private func activateAudioSession() {
        guard !didActivateAudioSession else { return }
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true)
        didActivateAudioSession = true
    }

    /// Hands audio control back so the user's background music/podcast resumes.
    private func deactivateAudioSession() {
        guard didActivateAudioSession else { return }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        didActivateAudioSession = false
    }

    @objc private func playerDidEnd() {
        didEnd = true
        player.seek(to: .zero)
        slider.value = 0
        currentTimeLabel.text = "0:00"
        remainingTimeLabel.text = "-" + VideoPlayerView.format(totalSeconds)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        setControls(hidden: false)
    }

    @objc private func toggleControls() {
        setControls(hidden: playPauseButton.alpha > 0.5)
    }

    private func setControls(hidden: Bool) {
        playPauseButton.isUserInteractionEnabled = !hidden
        bottomBar.isUserInteractionEnabled = !hidden
        UIView.animate(withDuration: 0.2) {
            let alpha: CGFloat = hidden ? 0 : 1
            self.playPauseButton.alpha = alpha
            self.bottomBar.alpha = alpha
        }
    }

    @objc private func scrubStart() { isScrubbing = true }

    @objc private func scrubChanged() {
        currentTimeLabel.text = VideoPlayerView.format(Double(slider.value))
        remainingTimeLabel.text = "-" + VideoPlayerView.format(max(0, totalSeconds - Double(slider.value)))
    }

    @objc private func scrubEnd() {
        let target = CMTime(seconds: Double(slider.value), preferredTimescale: 600)
        player.seek(to: target) { [weak self] _ in self?.isScrubbing = false }
    }

    private static func format(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

extension VideoPlayerView: UIGestureRecognizerDelegate {
    // Don't let the "toggle controls" tap fire when tapping the play button or scrubber.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
