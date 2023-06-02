//
//  CometChatAudioBubble.swift
//
//
//  Created by Abdullah Ansari on 21/12/22.
//

import Foundation
import UIKit
import AVKit

public class CometChatAudioBubble: UIStackView {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var contentView: UIView!
    private var fileURL: String?
    var controller: UIViewController?
    
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
        CometChatUIKit.bundle.loadNibNamed("CometChatAudioBubble", owner: self, options:  nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 228),
            heightAnchor.constraint(equalToConstant: 56)
        ])
        set(style: AudioBubbleStyle())
    }
    
    public func set(fileURL: String) {
        self.fileURL = fileURL
    }
    
    public func set(title: String) {
        self.title.text = title
    }
    
    public func set(titleColor: UIColor) {
        title.textColor = titleColor
    }
    
    public func set(titleFont: UIFont) {
        title.font = titleFont
    }
    
    public func set(subTitle: String) {
        self.subTitle.text = subTitle
    }
    
    public func set(subTitleFont: UIFont) {
        subTitle.font = subTitleFont
    }
    
    public func set(subTitleColor: UIColor) {
        subTitle.textColor = subTitleColor
    }
    
    public func set(playIcon: UIImage) {
        self.playIcon.image = playIcon
    }
    
    public func set(iconTint: UIColor) {
        playIcon.tintColor = iconTint
    }
    
    public func set(backgroundColor: UIColor) {
        contentView.backgroundColor(color: backgroundColor)
    }
    
    public func set(cornerRadius: CometChatCornerStyle) {
        contentView.roundViewCorners(corner: cornerRadius)
    }
    
    public func set(borderWidth: CGFloat) {
        contentView.borderWith(width: borderWidth)
    }
    
    public func set(borderColor: UIColor) {
        contentView.borderColor(color: borderColor)
    }
    
    public func set(controller: UIViewController) {
        self.controller = controller
    }
    
    public func set(style: AudioBubbleStyle) {
        set(iconTint: style.iconTint)
        set(titleColor: style.titleColor)
        set(titleFont: style.titleFont)
        set(subTitleFont: style.subtitleFont)
        set(subTitleColor: style.subtitleColor)
        set(backgroundColor: style.background)
        set(cornerRadius: style.cornerRadius)
        set(borderWidth: style.borderWidth)
        set(borderColor: style.borderColor)
    }
    
    @IBAction func onClick(_ sender: UIButton) {
        guard let fileURL = fileURL else { return }
        guard let url = URL(string: fileURL) else { return }
        let player = AVPlayer(url: url)
        DispatchQueue.main.async{[weak self] in
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            playerViewController.setLargeTitleDisplayMode(.automatic)
            let imageView = UIImageView(image: UIImage(systemName: "waveform"))
            imageView.tintColor = .white
            playerViewController.contentOverlayView?.addSubview(imageView)
            self?.controller?.present(playerViewController, animated: true) {
                playerViewController.player!.play()
                imageView.translatesAutoresizingMaskIntoConstraints  = false
                imageView.centerXAnchor.constraint(equalTo: playerViewController.contentOverlayView!.centerXAnchor).isActive = true
                imageView.centerYAnchor.constraint(equalTo: playerViewController.contentOverlayView!.centerYAnchor).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
            }
        }
    }
    
}
