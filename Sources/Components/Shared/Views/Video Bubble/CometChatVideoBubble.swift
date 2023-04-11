//
//  CCVideoBubble.swift
//
//
//  Created by Abdullah Ansari on 20/12/22.
//

import UIKit
import AVFoundation
import AVKit

class CometChatVideoBubble: UIStackView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var placeholderImage: UIImageView!
    @IBOutlet weak var playIcon: UIImageView!
    
    var onClick: (() -> Void)?
    var thumbnailUrl: String = ""
    var videoURL: String = ""
    var controller: UIViewController?
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatVideoBubble", owner: self, options:  nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 228),
            heightAnchor.constraint(equalToConstant: 168)
        ])
        set(style: VideoBubbleStyle())
    }
    
    public func set(thumbnailImage: UIImage) {
        self.placeholderImage.image = thumbnailImage
    }
    
    public func set(thumnailImageUrl: String, sentAt: Double? = nil) {
        if let time = sentAt {
            let date = Date(timeIntervalSince1970: TimeInterval(time))
            let secondsAgo = Int(Date().timeIntervalSince(date))
            var timeinterval = 0.0
            _ = Timer.scheduledTimer(withTimeInterval: timeinterval, repeats: secondsAgo > 5 ? false : true) { [weak self] (timer) in
                guard let this  = self else { return }
                if let url = URL(string: thumnailImageUrl) {
                    this.imageRequest = this.imageService.image(for: url) { [weak self] image in
                        guard let strongSelf = self else { return }
                        if let image = image {
                            strongSelf.placeholderImage.image = image
                            timer.invalidate()
                        } else {
                            timeinterval = 1.0
                        }
                    }
                }
            }
        } else {
            if let url = URL(string: thumnailImageUrl) {
                self.placeholderImage.image = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let this = self else { return }
                    if let image = image {
                        this.placeholderImage.image = image
                    } else {
                        this.placeholderImage.isHidden = true
                    }
                }
            }
        }
    }
    
    public func set(videoURL: String) {
        self.videoURL = videoURL
    }
    
    public func set(placeholderImage: UIImage) {
        self.placeholderImage.image = placeholderImage
    }
    
    public func set(corner: CometChatCornerStyle)  {
        contentView.roundViewCorners(corner: corner)
    }
    
    public func set(borderWidth: CGFloat) {
        contentView.borderWith(width: borderWidth)
    }
    
    public func set(borderColor: UIColor) {
        contentView.borderColor(color: borderColor)
    }
    
    public func set(backgroundColor: UIColor) {
        contentView.backgroundColor = backgroundColor
    }
    
    public func set(playIconTint: UIColor) {
        playIcon.tintColor = playIconTint
    }
    
    public func set(playIconBackgroundColor: UIColor) {
        // TODO(Abdullah):- How to provide background to the view.
//        playIcon.image = UIImage(systemName: "play.fill")
//        playIcon.backgroundColor = playIconBackgroundColor
    }
    
    public func set(style: VideoBubbleStyle = VideoBubbleStyle()) {
        set(playIconTint: style.playIconTint)
        set(playIconBackgroundColor: style.playIconBackgroundColor)
        set(backgroundColor: style.background)
        set(corner: style.cornerRadius)
        set(borderColor: style.borderColor)
        set(borderWidth: style.borderWidth)
    }
    
    public func onClick(onClick: (() -> Void)?) {
        self.onClick = onClick
    }
    
    public func set(controller: UIViewController) {
        self.controller = controller
    }
    
    @IBAction func onVideoPlayClick(_ sender: UIButton) {
        guard let url = URL(string: videoURL) else { return }
        let player = AVPlayer(url: url)
        DispatchQueue.main.async {
        let playViewController = AVPlayerViewController()
        playViewController.player = player
            self.controller?.present(playViewController, animated: true) {
                playViewController.player?.play()
            }
        }
    }
    
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
