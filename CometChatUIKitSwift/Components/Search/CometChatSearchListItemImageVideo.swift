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

    /// Dark scrim + bold "+N" over the thumbnail when the message carries more
    /// attachments than the one previewed (same overflow idiom as the media grid).
    private let overflowScrim: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let overflowLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        thumbnailImageView.addSubview(overflowScrim)
        overflowScrim.addSubview(overflowLabel)

        NSLayoutConstraint.activate([
            // Thumbnail on the right — 96×64 landscape per the design.
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 96),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 64),
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            playIconView.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor),
            playIconView.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor),

            overflowScrim.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor),
            overflowScrim.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            overflowScrim.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),
            overflowScrim.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor),
            overflowLabel.centerXAnchor.constraint(equalTo: overflowScrim.centerXAnchor),
            overflowLabel.centerYAnchor.constraint(equalTo: overflowScrim.centerYAnchor),
            
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
    
    /// "<You|Sender>: <glyph> <summary>" — the search-row subtitle anatomy.
    static func subtitleText(prefix: String, glyph: String, summary: String,
                             font: UIFont, color: UIColor) -> NSAttributedString {
        let result = NSMutableAttributedString()
        if !prefix.isEmpty {
            result.append(NSAttributedString(string: "\(prefix): ", attributes: [.font: font, .foregroundColor: color]))
        }
        if let image = UIImage(systemName: glyph)?.withTintColor(color, renderingMode: .alwaysOriginal) {
            let attachment = NSTextAttachment(image: image)
            let side = font.pointSize
            attachment.bounds = CGRect(x: 0, y: (font.capHeight - side) / 2, width: side + 3, height: side)
            result.append(NSAttributedString(attachment: attachment))
            result.append(NSAttributedString(string: " ", attributes: [.font: font]))
        }
        // Captions can carry rich-text markup (**bold**, <u>underline</u>…) —
        // render it instead of showing the raw tags, then flatten to one line.
        let parsedSummary = NSMutableAttributedString(
            attributedString: RichTextFormatterManager.shared.parseMarkdown(
                summary,
                baseFont: font,
                baseColor: color,
                addNewlinesAroundCodeBlocks: false
            )
        )
        parsedSummary.mutableString.replaceOccurrences(
            of: "\n",
            with: " ",
            options: [],
            range: NSRange(location: 0, length: parsedSummary.length)
        )
        result.append(parsedSummary)
        return result
    }

    // MARK: Configure
    /// `title`: the chat (group / peer) name. `senderPrefix`: "You" or the sender's
    /// name. `summary`: caption → "N Images/Videos". `extraCount`: attachments beyond
    /// the previewed one — shown as a "+N" scrim.
    func configure(title: String, senderPrefix: String, summary: String, thumbnailURL: URL?, isVideo: Bool, extraCount: Int = 0) {
        titleLabel.text = title
        subtitleLabel.attributedText = CometChatSearchListItemImageVideo.subtitleText(
            prefix: senderPrefix,
            glyph: isVideo ? "video" : "photo",
            summary: summary,
            font: subtitleLabel.font,
            color: .secondaryLabel
        )

        overflowScrim.isHidden = extraCount <= 0
        overflowLabel.text = "+\(extraCount)"

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
        
        // The "+N" scrim owns the thumbnail when present; the play glyph would clash.
        playIconView.isHidden = !isVideo || extraCount > 0
    }
    
    @discardableResult
    public func set(customView: UIView) -> Self {
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        self.contentView.embed(customView)
        return self
    }
}
