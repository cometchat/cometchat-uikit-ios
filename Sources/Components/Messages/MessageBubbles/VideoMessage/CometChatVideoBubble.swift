//
//  CometChatVideoBubbleView.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 13/05/22.
//

import UIKit
import CometChatPro
import AVKit


public class CometChatVideoBubble: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var playButton: UIImageView!
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    // MARK: - Initializers
    var controller: UIViewController?
    var mediaMessage: MediaMessage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    convenience init(frame: CGRect, message: MediaMessage, isStandard: Bool) {
        self.init(frame: frame)
        set(message: message)
        setup(isStandard: isStandard)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Helper Methods
    
    private func setup(isStandard: Bool) {
        let videoBubbleStyle = VideoBubbleStyle(playColor:
                                                    isStandard ? CometChatTheme.palatte?.background : CometChatTheme.palatte?.primary)
        
        set(style: videoBubbleStyle)
    }
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatVideoBubble", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onVideoClick))
        videoThumbnail.addGestureRecognizer(tap)
        videoThumbnail.isUserInteractionEnabled = true
        
    }
    
    @objc  func onVideoClick() {
        var player = AVPlayer()
        if let videoURL = mediaMessage?.attachment?.fileUrl,
           let url = URL(string: videoURL) {
            player = AVPlayer(url: url)
        }
        DispatchQueue.main.async{[weak self] in
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self?.controller?.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    private func parseThumbnailForImage(message: MediaMessage) {
        videoThumbnail.image = nil
        
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let dict = cometChatExtension[ExtensionConstants.thumbnailGeneration] as? [String : Any] {
            if let url = URL(string: dict["url_medium"] as? String ?? "") {
                // videoThumbnail.cf.setImage(with: url)
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        strongSelf.videoThumbnail.image = image
                    }else{
                        strongSelf.videoThumbnail.image = nil
                    }
                }
            }
        }else{
            if let url = URL(string: message.attachment?.fileUrl ?? "") {
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        strongSelf.videoThumbnail.image = image
                    }else{
                        strongSelf.videoThumbnail.image = nil
                    }
                }
            }
        }
    }
    
    @discardableResult
    public func set(style: VideoBubbleStyle) -> Self {
        self.set(playColor: style.playColor!)
    }
    
    @discardableResult
    @objc public func set(message: MediaMessage) -> Self {
        self.mediaMessage = message
        parseThumbnailForImage(message: message)
        return self
    }
    
    @discardableResult
    @objc public func set(playColor: UIColor) -> Self {
        self.playButton.image = UIImage(named: "messages-media-play.png", in: CometChatUIKit.bundle, compatibleWith: nil)
        self.playButton.tintColor = playColor
        return self
    }
    
    
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    
    deinit {
        imageRequest?.cancel()
    }
}
