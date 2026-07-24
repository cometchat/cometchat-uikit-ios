//
//  AttachmentTile.swift
//  CometChatUIKitSwift
//
//  Staging model for one attachment in the composer's preview tray (before send).
//  One tile per picked file; the upload manager mutates it in place as the file
//  uploads, and the tray cell renders its current state.
//

import UIKit
import CometChatSDK

public enum AttachmentTileStatus {
    case uploading   // bytes in flight
    case done        // uploaded; `attachment` is set and ready to send
    case failed      // upload failed for a transient reason — offer retry
    case rejected    // API validation error (size/mime) — NOT retryable
    case cancelled   // user cancelled
}

public final class AttachmentTile {

    public let fileId: String
    public let file: File
    public let mimeType: String

    /// Local preview (image thumbnail / video frame). Files show a type icon instead.
    public var previewImage: UIImage?

    public var status: AttachmentTileStatus = .uploading
    public var bytesUploaded: Int64 = 0
    public var totalBytes: Int64 = 0
    public var percent: Int = 0

    /// Set once the file finishes uploading — this is what gets sent.
    public var attachment: Attachment?
    public var error: CometChatException?

    public init(fileId: String, file: File, mimeType: String, previewImage: UIImage? = nil) {
        self.fileId = fileId
        self.file = file
        self.mimeType = mimeType
        self.previewImage = previewImage
        self.totalBytes = Int64(file.data?.count ?? 0)
    }

    public var fileName: String {
        let name = file.name ?? ""
        return name.isEmpty ? "file" : name
    }

    public var kind: AttachmentTileKind {
        AttachmentTileKind.of(mimeType: mimeType, fileName: fileName)
    }
}

public enum AttachmentTileKind {
    case image
    case video
    case audio
    case file

    static func of(mimeType: String, fileName: String) -> AttachmentTileKind {
        let mime = mimeType.lowercased()
        if mime.hasPrefix("image/") { return .image }
        if mime.hasPrefix("video/") { return .video }
        if mime.hasPrefix("audio/") { return .audio }

        let ext = (fileName as NSString).pathExtension.lowercased()
        let imageExts: Set<String> = ["jpg", "jpeg", "png", "gif", "webp", "heic", "heif", "bmp", "tiff"]
        let videoExts: Set<String> = ["mp4", "mov", "m4v", "avi", "mkv", "webm", "3gp"]
        let audioExts: Set<String> = ["mp3", "wav", "aac", "m4a", "ogg", "flac"]
        if imageExts.contains(ext) { return .image }
        if videoExts.contains(ext) { return .video }
        if audioExts.contains(ext) { return .audio }
        return .file
    }
}
