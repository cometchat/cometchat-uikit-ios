//
//  CometChatSearchListItemAttachments.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 18/08/25.
//

import Foundation
import UIKit
import CometChatSDK

final class CometChatSearchListItemAttachments: UITableViewCell {
    static let identifier = "CometChatSearchListItemAttachments"
    
    var user: User?
    var group: Group?
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 6
        iv.clipsToBounds = true
        iv.widthAnchor.constraint(equalToConstant: 40).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        // Use high priority instead of required to prevent constraint conflicts during iPad window resizing
        lbl.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return lbl
    }()
    
    private lazy var textStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [iconView, textStack, dateLabel])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var imageRequest: Cancellable?    
    private lazy var imageService = ImageService()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Configure
    func configure(with message: BaseMessage, localURL: URL? = nil) {
        // Reuse-safety: reset the leading icon to its plain style. The audio branch
        // overrides it into a purple play circle; every other row (file / link / image)
        // must start from the plain style so a recycled audio cell doesn't keep the
        // circle.
        applyPlainIconStyle()
        switch message {
        case let mediaMessage as MediaMessage:
            configureMediaMessage(mediaMessage, localURL: localURL)

        case let textMessage as TextMessage:
            configureTextMessage(textMessage)

        default:
            break
        }
    }

    /// Default leading-icon look: transparent, lightly rounded, image scaled to fit.
    private func applyPlainIconStyle() {
        iconView.backgroundColor = .clear
        iconView.layer.cornerRadius = 6
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = nil
    }

    /// Audio rows use a filled purple circle with a centered white play glyph — the same
    /// affordance as the audio bubble/composer, so audio reads as "playable" in search.
    private func applyAudioPlayCircleStyle() {
        iconView.backgroundColor = CometChatTheme.primaryColor
        iconView.layer.cornerRadius = 20   // half of the 40pt icon → a circle
        iconView.contentMode = .center      // show the glyph at its point size, not stretched
        iconView.image = UIImage(systemName: "play.fill",
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold))?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
    private func configureTextMessage(_ message: TextMessage) {
        parseLinkPreview(for: message)
    }

    
    private func configureMediaMessage(_ message: MediaMessage, localURL: URL? = nil) {
        let attachments = message.attachments ?? []
        guard let firstAttachment = attachments.first ?? message.attachment else { return }
        let isLoggedInUser = message.sender?.uid == CometChat.getLoggedInUser()?.uid

        // Title = the CHAT name (group name, or the peer in a 1:1).
        if message.receiverType == .group {
            titleLabel.text = (message.receiver as? Group)?.name ?? ""
        } else {
            titleLabel.text = isLoggedInUser
                ? ((message.receiver as? User)?.name ?? "")
                : (message.sender?.name ?? "")
        }

        // Subtitle = "<You|Sender>: <glyph> <summary>". Summary combines caption and
        // count: "caption · N Audios" when both, "N Audios/Files" when uncaptioned
        // multi, caption alone, filename as last resort.
        let isAudio = message.messageType == .audio
        let caption = (message.caption ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let countKey = isAudio ? "search_audios_count" : "search_files_count"
        let countText = attachments.count > 1 ? String(format: countKey.localize(), "\(attachments.count)") : ""
        let summary: String
        switch (caption.isEmpty, countText.isEmpty) {
        case (false, false): summary = "\(caption) · \(countText)"
        case (true, false):  summary = countText
        case (false, true):  summary = caption
        case (true, true):   summary = firstAttachment.fileName
        }
        subtitleLabel.attributedText = CometChatSearchListItemImageVideo.subtitleText(
            prefix: isLoggedInUser ? "You" : (message.sender?.name ?? ""),
            glyph: isAudio ? "mic" : "doc.text",
            summary: summary,
            font: subtitleLabel.font,
            color: .secondaryLabel
        )

        dateLabel.text = CometChatSearchListItemAttachments.relativeDay(from: message.sentAt)

        // Audio → purple play circle (single or multi). A multi-FILE message shows the
        // generic file badge (a per-type icon would lie about the rest); single files
        // keep their specific type icon.
        if isAudio {
            applyAudioPlayCircleStyle()
        } else if attachments.count > 1 {
            iconView.image = UIImage(named: "file-type-generic", in: CometChatUIKit.bundle, compatibleWith: nil)
        } else {
            iconView.image = CometChatSearchListItemAttachments.getFileIcon(for: message, localURL: localURL)
        }
    }

    
    private func parseLinkPreview(for message: TextMessage) {
        guard
            let metaData = message.metaData,
            let injected = metaData["@injected"] as? [String: Any],
            let cometChatExtension = injected["extensions"] as? [String: Any],
            let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String: Any],
            let linkArray = linkPreviewDictionary["links"] as? [[String: Any]],
            let linkPreview = linkArray.first
        else {
            applyBasicLinkFallback(message)
            return
        }
        
        titleLabel.text = (message.sender)?.name ?? ""
        
        if message.receiverType == .group {
            if let group = group{
                titleLabel.text = message.sender?.name ?? ""
            } else {
                titleLabel.text = (message.receiver as? Group)?.name ?? ""
            }
        } else {
            titleLabel.text = message.sender?.uid == CometChat.getLoggedInUser()?.uid ? "You" : message.sender?.name
        }
        
        if let linkURL = linkPreview["url"] as? String {
            self.subtitleLabel.text = linkURL
        }
        
        self.iconView.image = UIImage(
            named: "default-image",
            in: CometChatUIKit.bundle,
            compatibleWith: nil
        )
        
        if let thumbnail = linkPreview["image"] as? String, let url = URL(string: thumbnail) {
            imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
                guard let strongSelf = self, let image = image else { return }
                if #available(iOS 15.0, *) {
                    image.prepareForDisplay { preparedImage in
                        DispatchQueue.main.async {
                            strongSelf.iconView.image = preparedImage
                        }
                    }
                } else {
                    strongSelf.iconView.image = image
                }
            }
        } else if let favIcon = linkPreview["favicon"] as? String, let url = URL(string: favIcon) {
            imageRequest = imageService.image(for: url, cacheType: .normal) { [weak self] image in
                guard let strongSelf = self, let image = image else { return }
                if #available(iOS 15.0, *) {
                    image.prepareForDisplay { preparedImage in
                        DispatchQueue.main.async {
                            strongSelf.iconView.image = preparedImage
                        }
                    }
                } else {
                    strongSelf.iconView.image = image
                }
            }
        } else {
            self.iconView.image = UIImage(
                named: "default-image",
                in: CometChatUIKit.bundle,
                compatibleWith: nil
            )
        }
    }
    
    private func applyBasicLinkFallback(_ message: TextMessage) {
//        titleLabel.text = message.sender?.name ?? ""
        
        if message.receiverType == .group {
            if let group = group{
                titleLabel.text = message.sender?.name ?? ""
            } else {
                titleLabel.text = (message.receiver as? Group)?.name ?? ""
            }
        } else {
            titleLabel.text = message.sender?.uid == CometChat.getLoggedInUser()?.uid ? "You" : message.sender?.name
        }
        
        // Extract URL from message text
        subtitleLabel.text = extractFirstURL(from: message.text)
        
        iconView.image = UIImage(
            named: "cometchat_link_file_icon",
            in: CometChatUIKit.bundle,
            compatibleWith: nil
        )
    }
    
    private func extractFirstURL(from text: String) -> String? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, range: NSRange(location: 0, length: text.count))
        return matches?.first?.url?.absoluteString
    }


    
    /// "Yesterday", weekday name within a week, else dd/MM/yy — per the search design.
    static func relativeDay(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter(); formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        if calendar.isDateInYesterday(date) { return "YESTERDAY".localize() }
        if let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()), date > weekAgo {
            let formatter = DateFormatter(); formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
        let formatter = DateFormatter(); formatter.dateFormat = "dd/MM/yy"
        return formatter.string(from: date)
    }

    // MARK: - Date formatting
    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy" // you can tweak this
        return formatter.string(from: date)
    }
    
    // MARK: - File size formatting
    private func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    // MARK: - File icon logic
    /// Uses the shared GalleryFileType classifier (MIME + extension, Android-parity
    /// precedence) so search shows the SAME icon as the bubbles and the composer tray.
    public static func getFileIcon(for mediaMessage: MediaMessage, localURL: URL? = nil) -> UIImage? {
        let attachment = mediaMessage.attachments?.first ?? mediaMessage.attachment
        // A local copy's extension is the most reliable signal when present.
        let url = localURL?.absoluteString ?? attachment?.fileUrl ?? ""
        let mime = attachment?.fileMimeType ?? ""
        return GalleryFileType.of(mimeType: mime, fileUrl: url).icon
    }

    @discardableResult
    public func set(customView: UIView) -> Self {
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        self.contentView.embed(customView)
        return self
    }
}



// MARK: - AttachmentType Enum
enum AttachmentType {
    case link
    case file(String)   // extension (pdf, word, jpg...)
    case audio
}
