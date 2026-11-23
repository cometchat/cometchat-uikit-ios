//
//  OfflineMediaPlaceholder.swift
//  CometChatUIKitSwift
//
//  The bubble content shown for media that has no on-device copy while there is no connection.
//

import UIKit
import CometChatSDK

internal enum OfflineMediaPlaceholder {

    /// The file's name and size (when known) over "Available when online", in the secondary text
    /// style. A tap while connected asks the SDK for the file (AC-12.3). Carries a contract
    /// identifier, never text.
    static func make(for message: MediaMessage?, downloader: OfflineMediaDownload = .shared) -> UIView {
        // Another user's link to a file on this device is never downloaded (iOS-SEC-1).
        let attachment = message?.attachment.map { MessageMediaTrust.attachment($0, of: message) }
        return make(attachment: attachment, messageId: message?.id ?? 0, downloader: downloader)
    }

    /// One attachment of a gallery message. `compact` drops the minimum size so it fits a grid tile;
    /// `textColor` overrides the style colour (the full-screen viewer is black).
    static func make(attachment: Attachment?, messageId: Int, downloader: OfflineMediaDownload = .shared,
                     compact: Bool = false, textColor: UIColor? = nil) -> UIView {
        let view = TappablePlaceholder(url: attachment?.fileUrl, messageId: messageId, downloader: downloader)
        let lines = [detail(forAttachment: attachment), "MEDIA_AVAILABLE_WHEN_ONLINE".localize()].compactMap { $0 }
        let stack = UIStackView(arrangedSubviews: lines.map { text in
            let label = UILabel()
            label.text = text
            label.font = CometChatMessageList.offlineStyle.mediaPlaceholderTextFont
            label.textColor = textColor ?? CometChatMessageList.offlineStyle.mediaPlaceholderTextColor
            label.numberOfLines = 0
            label.textAlignment = .center
            return label
        })
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
        view.isAccessibilityElement = true
        view.accessibilityLabel = lines.joined(separator: ", ")
        view.accessibilityIdentifier = StateContract.mediaAvailableWhenOnline
        view.translatesAutoresizingMaskIntoConstraints = false
        if !compact {
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 160).isActive = true
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        }
        return view
    }

    /// `name · size`, or whichever of the two the message has.
    static func detail(for message: MediaMessage?) -> String? {
        return detail(forAttachment: message?.attachment)
    }

    static func detail(forAttachment attachment: Attachment?) -> String? {
        let name = attachment?.fileName ?? ""
        let bytes = attachment?.fileSize ?? 0
        let size = bytes > 0 ? ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file) : ""
        let parts = [name, size].filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private final class TappablePlaceholder: UIView {
        private let url: String?
        private let messageId: Int
        private let downloader: OfflineMediaDownload

        init(url: String?, messageId: Int, downloader: OfflineMediaDownload) {
            self.url = url
            self.messageId = messageId
            self.downloader = downloader
            super.init(frame: .zero)
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        @objc private func tapped() { downloader.request(url: url, messageId: messageId) }
    }
}
