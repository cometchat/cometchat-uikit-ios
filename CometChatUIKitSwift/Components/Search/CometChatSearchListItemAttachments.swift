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
        switch message {
        case let mediaMessage as MediaMessage:
            configureMediaMessage(mediaMessage, localURL: localURL)
            
        case let textMessage as TextMessage:
            configureTextMessage(textMessage)
            
        default:
            break
        }
    }
    
    private func configureTextMessage(_ message: TextMessage) {
        parseLinkPreview(for: message)
    }

    
    private func configureMediaMessage(_ message: MediaMessage, localURL: URL? = nil) {
        guard let attachment = message.attachment else { return }
        
        titleLabel.text = attachment.fileName
        
        let fileSize = formatBytes(Int(attachment.fileSize))
        let fileType = (attachment.fileExtension).uppercased()
        let senderName = message.sender?.name ?? "You"
        subtitleLabel.text = "\(fileSize) · \(fileType) · \(senderName)"
        
        if message.receiverType == .group {
            if let group = group{
                titleLabel.text = message.sender?.name ?? ""
            } else {
                titleLabel.text = (message.receiver as? Group)?.name ?? ""
            }
        } else {
            titleLabel.text = message.sender?.uid == CometChat.getLoggedInUser()?.uid ? "You" : message.sender?.name
        }
        subtitleLabel.text = attachment.fileName
        
        dateLabel.text = formatDate(from: message.sentAt)
        
        iconView.image = CometChatSearchListItemAttachments.getFileIcon(for: message, localURL: localURL)
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
    public static func getFileIcon(for mediaMessage: MediaMessage, localURL: URL? = nil) -> UIImage? {
        let bundle = CometChatUIKit.bundle
        
        let wordFileIcon = UIImage(named: "cometchat_word_file_icon", in: bundle, with: nil)
        let pptFileIcon = UIImage(named: "cometchat_ppt_file_icon", in: bundle, with: nil)
        let xlsxFileIcon = UIImage(named: "cometchat_xlsx_file_icon", in: bundle, with: nil)
        let pdfFileIcon = UIImage(named: "cometchat_pdf_file_icon", in: bundle, with: nil)
        let zipFileIcon = UIImage(named: "cometchat_zip_file_icon", in: bundle, with: nil)
        let textFileIcon = UIImage(named: "cometchat_text_file_icon", in: bundle, with: nil)
        let audioFileIcon = UIImage(named: "cometchat_audio_file_icon", in: bundle, with: nil)
        let imageFileIcon = UIImage(named: "cometchat_image_file_icon", in: bundle, with: nil)
        let videoFileIcon = UIImage(named: "cometchat_video_file_icon", in: bundle, with: nil)
        let linkFileIcon = UIImage(named: "cometchat_link_file_icon", in: bundle, with: nil)
        let unknownFileIcon = UIImage(named: "cometchat_unknown_file_icon", in: bundle, with: nil)
        
        func getFileIcon(for ext: String?) -> UIImage? {
            guard let fileExtension = ext else { return nil }
            switch fileExtension.lowercased() {
            case "doc", "docx": return wordFileIcon
            case "ppt", "pptx": return pptFileIcon
            case "xls", "xlsx": return xlsxFileIcon
            case "pdf": return pdfFileIcon
            case "zip": return zipFileIcon
            case "csv", "txt": return textFileIcon
            case "mp3", "wav", "aac": return audioFileIcon
            case "jpg", "jpeg", "png", "gif": return imageFileIcon
            case "mp4", "mov": return videoFileIcon
            case "html", "url": return linkFileIcon
            default: return nil
            }
        }
        
        // Local URL check
        if let imageFromLocalURL = getFileIcon(for: localURL?.pathExtension) {
            return imageFromLocalURL
        }
        
        if let attachment = mediaMessage.attachment {
            let mimeType = attachment.fileMimeType
            
            if mimeType.contains("video") { return videoFileIcon }
            if mimeType.contains("pdf") { return pdfFileIcon }
            if mimeType.contains("zip") { return zipFileIcon }
            if mimeType.contains("audio") { return audioFileIcon }
            if mimeType.contains("image") { return imageFileIcon }
            if mimeType.contains("text") { return textFileIcon }
            if mimeType.contains("link") { return linkFileIcon }
            
            if mimeType.contains("octet-stream") {
                if attachment.fileUrl.hasSuffix(".doc") { return wordFileIcon }
                if attachment.fileUrl.hasSuffix(".ppt") { return pptFileIcon }
                if attachment.fileUrl.hasSuffix(".xls") { return xlsxFileIcon }
            }
        }
        
        return unknownFileIcon
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
