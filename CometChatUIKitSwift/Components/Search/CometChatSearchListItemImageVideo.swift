//
//  CometChatSearchListItemImageVideo.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 18/08/25.
//

import Foundation
import UIKit
import AVFoundation

final class CometChatSearchListItemImageVideo: UITableViewCell {
    
    static let identifier = "CometChatSearchListItemImageVideo"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let playIconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold)
        let imageView = UIImageView(image: UIImage(systemName: "play.circle.fill", withConfiguration: config))
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
    // MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(playIconView)
        
        NSLayoutConstraint.activate([
            // Thumbnail on the right
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            playIconView.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            playIconView.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),
            
            // Labels aligned relative to thumbnail, not contentView
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor),   // 👈 fixed
            
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: thumbnailImageView.bottomAnchor) // 👈 fixed
        ])
    }
    
    // MARK: Configure
    func configure(senderName: String, fileName: String, thumbnailURL: URL?, isVideo: Bool) {
        titleLabel.text = senderName
        subtitleLabel.text = fileName
        
        if let url = thumbnailURL {
            if isVideo {
                DispatchQueue.global().async {
                    let asset = AVAsset(url: url)
                    let imageGenerator = AVAssetImageGenerator(asset: asset)
                    imageGenerator.appliesPreferredTrackTransform = true
                    let time = CMTime(seconds: 1, preferredTimescale: 600)

                    do {
                        let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                        let thumbnail = UIImage(cgImage: cgImage)
                        DispatchQueue.main.async { [weak self] in
                            self?.thumbnailImageView.image = thumbnail
                        }
                    } catch {
                        DispatchQueue.main.async { [weak self] in
                            self?.thumbnailImageView.image = UIImage(systemName: "video") // fallback
                        }
                    }
                }
            } else {
                imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
                    guard let self else { return }
                    if let image = image {
                        self.thumbnailImageView.image = image
                    } else {
                        self.thumbnailImageView.image = UIImage(systemName: "photo")
                    }
                }
            }
        } else {
            thumbnailImageView.image = UIImage(systemName: "photo")
        }
        
        playIconView.isHidden = !isVideo
    }
    
    @discardableResult
    public func set(customView: UIView) -> Self {
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        self.contentView.embed(customView)
        return self
    }
}
