//
//  CCVideoBubble.swift
//
//
//  Created by Abdullah Ansari on 20/12/22.
//

import UIKit
import AVFoundation
import AVKit

public class CometChatVideoBubble: UIStackView {
    
    /// Placeholder image view that displays a thumbnail for the video and overlays the play button.
    public lazy var placeHolderImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.contentMode = .scaleAspectFill
        imageView.addSubview(playView)
        imageView.image = defaultThumbnailImage
        imageView.pin(anchors: [.centerX, .centerY], to: playImageView)
        return imageView
    }()
    
    /// Activity indicator displayed while the video thumbnail is being loaded.
    public lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView().withoutAutoresizingMaskConstraints()
        activityIndicator.backgroundColor = CometChatTheme.neutralColor100
        activityIndicator.style = .medium
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    public lazy var playImageView: UIImageView = {
        let playImageView = UIImageView(image: playImage).withoutAutoresizingMaskConstraints()
        playImageView.pin(anchors: [.height, .width], to: 24)
        playImageView.contentMode = .scaleAspectFit
        return playImageView
    }()
    
    /// View that represents the play button overlay on the video thumbnail.
    public lazy var playView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height, .width], to: 48)
        view.roundViewCorners(corner: .init(cornerRadius: 24))
        view.backgroundColor = .black.withAlphaComponent(0.4)
        
        view.addSubview(playImageView)
        playImageView.pin(anchors: [.centerX, .centerY], to: view)
        
        return view
    }()
    
    /// Style configuration for the video bubble.
    var style = CometChatMessageBubble.style.incoming.videoBubbleStyle
    
    /// Callback triggered when the video bubble is clicked.
    var onClick: (() -> Void)?
    
    /// URL string of the video thumbnail.
    var thumbnailImageUrl: URL?
    
    /// URL string of the video.
    var videoURL: String?
    
    /// Reference to the view controller presenting the video player.
    weak var controller: UIViewController?
    
    /// Image request object used for loading the thumbnail image.
    private var imageRequest: Cancellable?
    
    /// Service responsible for fetching images.
    private lazy var imageService = ImageService()
    
    var thumbnailRetryCount = 0
    
    /// play image for video bubble
    public var playImage = UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate)
    
    public var defaultThumbnailImage = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage() {
        didSet {
            self.placeHolderImageView.image = defaultThumbnailImage
        }
    }
    
    /// Initializes the video bubble with a frame.
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    /// Initializes the video bubble from a coder.
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Called when the video bubble is about to move to a new window, applying the style.
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setUpStyle()
        }
    }
    
    /// Builds the user interface for the video bubble.
    public func buildUI() {
        backgroundColor = .clear
        axis = .vertical
        spacing = 10
        distribution = .fill
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Padding.p1,
            left: CometChatSpacing.Padding.p1,
            bottom: 0,
            right: CometChatSpacing.Padding.p1
        )
        
        addArrangedSubview(placeHolderImageView)
        pin(anchors: [.height], to: 140)
        pin(anchors: [.width], to: 232)
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onVideoPlayClick)))
    }
    
    /// Sets up the style for the video bubble.
    public func setUpStyle() {
        placeHolderImageView.roundViewCorners(corner: style.videoCornerRadius)
        placeHolderImageView.borderWith(width: style.videoBorderWidth)
        placeHolderImageView.borderColor(color: style.videoBorderColor)
        playView.backgroundColor = style.playButtonBackgroundColor
        playImageView.tintColor = style.playButtonTint
        
    }
    
    /// Sets the thumbnail image URL and optionally sets the time the video was sent.
    /// - Parameters:
    ///   - thumnailImageUrl: The URL of the thumbnail image.
    ///   - sentAt: The time the video was sent (optional).
    public func set(thumnailImageUrl: String, sentAt: Double? = nil) {
        if thumbnailRetryCount < 5 {
            if let url = URL(string: thumnailImageUrl) {
                thumbnailImageUrl = url
                imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
                    guard let this = self else { return }
                    if let image = image {
                        this.set(placeholderImage: image)
                    } else {
                        this.thumbnailRetryCount+=1
                        this.set(thumnailImageUrl: thumnailImageUrl, sentAt: sentAt)
                    }
                }
            }
        }
    }
    
    /// Sets the video URL and generates a thumbnail if the placeholder image is not available.
    /// - Parameter videoURL: The URL of the video.
    public func set(videoURL: String) {
        self.videoURL = videoURL
        if thumbnailImageUrl == nil, let url = URL(string: videoURL) {
            generateThumbnail(from: url) { [weak self] image in
                if let image = image {
                    self?.set(placeholderImage: image)
                }
            }
        }
    }
    
    /// Sets the placeholder image for the video thumbnail.
    /// - Parameter placeholderImage: The placeholder image to be set.
    public func set(placeholderImage: UIImage) {
        if #available(iOS 15.0, *) {
            placeholderImage.prepareForDisplay { [weak self] preparedImage in
                guard let this = self else { return }
                DispatchQueue.main.async {
                    this.placeHolderImageView.image = preparedImage
                }
            }
        } else {
            self.placeHolderImageView.image = placeholderImage
        }
    }
    
    /// Sets the callback function to be triggered when the video bubble is clicked.
    /// - Parameter onClick: The callback function.
    public func onClick(onClick: (() -> Void)?) {
        self.onClick = onClick
    }
    
    /// Sets the view controller responsible for presenting the video player.
    /// - Parameter controller: The view controller.
    public func set(controller: UIViewController) {
        self.controller = controller
    }
    
    /// Handles the click event on the video bubble and presents the video player.
    @objc func onVideoPlayClick() {
        guard let videoURL = videoURL, let url = URL(string: videoURL) else { return }
        let player = AVPlayer(url: url)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            let playViewController = AVPlayerViewController()
            playViewController.player = player
            this.controller?.present(playViewController, animated: true) {
                playViewController.player?.play()
            }
        }
    }
    
    /// Generates a thumbnail image from the video URL.
    /// - Parameters:
    ///   - url: The URL of the video.
    ///   - completion: A closure that returns the generated thumbnail image.
    func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            
            if let cacheImage = ImageService.imageCache.object(forKey: url as AnyObject) as? UIImage {
                completion(cacheImage)
                return
            }
            
            let asset = AVURLAsset(url: url)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            assetImgGenerate.requestedTimeToleranceBefore = .zero
            assetImgGenerate.requestedTimeToleranceAfter = .zero
            let time = CMTimeMake(value: 1, timescale: 1)
            
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: img)
                ImageService.imageCache.setObject(thumbnail, forKey: url as AnyObject)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                print("Error generating thumbnail: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

    /// Cancels any ongoing image request when the video bubble is deallocated.
    deinit {
        imageRequest?.cancel()
    }
}

extension UIButton {

    func setImageTintColor(_ color: UIColor) {
        let tintedImage = self.imageView?.image?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = color
    }

}
