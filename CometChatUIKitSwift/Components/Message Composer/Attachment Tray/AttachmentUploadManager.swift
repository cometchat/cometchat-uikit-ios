//
//  AttachmentUploadManager.swift
//  CometChatUIKitSwift
//
//  Bridges the composer attachment tray to the SDK's presigned upload API. Owns the
//  ordered list of tiles, drives an `UploadFileRequest` (one request = one batch,
//  scoped to the composer's receiver), and surfaces per-file progress + aggregate
//  "ready to send" state.
//
//  NOTE: this file depends on the request-object upload API
//  (`CometChat.createUploadFileRequest`, `UploadFileRequest`, `UploadFileListener`)
//  which ships in the updated CometChatSDK. It will not compile against an SDK
//  build that predates that API.
//

import Foundation
import CometChatSDK

public final class AttachmentUploadManager: NSObject, UploadFileListener {

    /// Structural change (tiles added/removed) — reload the tray and re-evaluate send.
    public var onChange: (() -> Void)?
    /// A single tile changed (progress/status) — update just that cell.
    public var onTileUpdated: ((AttachmentTile) -> Void)?
    /// Fired when a pick would exceed the per-message attachment limit; passes the max.
    public var onLimitReached: ((Int) -> Void)?

    /// The conversation these uploads belong to. The SDK scopes an upload request
    /// (and its presign calls) to a receiver, so the composer must set these
    /// (alongside its own user/group) before the first pick. Changing the receiver
    /// discards any batch staged for the previous one.
    public var receiverId: String = "" {
        didSet { if oldValue != receiverId { resetBatch() } }
    }
    public var receiverType: CometChat.ReceiverType = .user {
        didSet { if oldValue != receiverType { resetBatch() } }
    }

    /// Thread parent for a thread composer (nil for a top-level composer). Sent with
    /// receiverId/receiverType in every presign call (design doc §5.2/§7). Set it
    /// before the first pick; changing it discards any staged batch.
    public var parentMessageId: Int? {
        didSet { if oldValue != parentMessageId { resetBatch() } }
    }

    /// The SDK request that owns the current batch. Created lazily on first upload,
    /// released on clear()/receiver change so every compose starts a fresh batch.
    private var uploadRequest: UploadFileRequest?

    public private(set) var tiles: [AttachmentTile] = []

    public var hasAttachments: Bool { !tiles.isEmpty }

    /// The batch id of the current upload request (nil before the first upload).
    /// The send path carries this as `metadata.batchId` on every fanned-out message.
    public var batchId: String? { uploadRequest?.getBatchId() }

    /// Nothing is still uploading, nothing sits in a rejected (error) state, and at
    /// least one file uploaded successfully. A rejected tile (e.g. over the size limit)
    /// blocks sending until the user removes it from the tray.
    public var canSend: Bool {
        guard !tiles.isEmpty else { return false }
        let anyUploading = tiles.contains { $0.status == .uploading }
        let anyRejected = tiles.contains { $0.status == .rejected }
        let anyDone = tiles.contains { $0.status == .done }
        return !anyUploading && !anyRejected && anyDone
    }

    /// The uploaded attachments, in pick order, ready to attach to a message.
    public var readyAttachments: [Attachment] {
        tiles.filter { $0.status == .done }.compactMap { $0.attachment }
    }

    // MARK: - Limits

    /// Sensible fallback when `file.count.max` is missing or misconfigured.
    private static let defaultMaxCount = 10
    /// Above this, the setting is clearly a byte-size (some apps set file.count.max ==
    /// file.size.max), not a real per-message attachment count.
    private static let saneMaxCount = 1000

    /// The SDK's `file.count.max`, guarded against missing/bogus values.
    private var sdkMaxCount: Int {
        let raw = CometChat.getMaxFileCount()
        return (raw > 0 && raw <= AttachmentUploadManager.saneMaxCount) ? raw : AttachmentUploadManager.defaultMaxCount
    }

    /// The per-message attachment cap, straight from the app's server settings.
    public var maxCount: Int { sdkMaxCount }

    /// The per-file size cap in bytes, from the SDK's `file.size.max` setting.
    /// Guarded like `maxCount`: a bogus settings value (zero/negative/sub-1KB) would
    /// reject every pick, so it falls back to 100 MB instead.
    private var maxIndividualFileSize: Int {
        let sdk = CometChat.getMaxFileSize()
        return sdk >= 1024 ? sdk : 100 * 1024 * 1024
    }

    /// The effective per-file size cap in whole megabytes, for user-facing messages.
    public var maxFileSizeInMB: Int {
        max(1, maxIndividualFileSize / (1024 * 1024))
    }

    // MARK: - Mutations

    public func add(_ picked: [PickedMedia]) {
        guard !picked.isEmpty else { return }

        // Per-file size limit (from server settings). Oversized picks are NOT dropped
        // and show no alert at add time — they are staged below in a rejected (error)
        // state so the user sees them in the tray, cannot send until removing them,
        // and tapping the red tile is what surfaces the reason. Mime types are the
        // server's call: a disallowed type comes back through onFileError and
        // lands in the same rejected state.
        let maxSize = maxIndividualFileSize

        // Per-message count limit. When a pick can't fit ENTIRELY in the remaining
        // slots we add NONE of it and show the limit snackbar — never a partial add.
        // Silently dropping "the extra ones" is arbitrary (which of the 2 docs the user
        // picked with 1 slot left do we keep?), so it's all-or-nothing.
        //
        // This guard is the version/device-independent backstop: the photo picker caps
        // its own selection to `remaining` via PHPickerConfiguration.selectionLimit, but
        // the document picker's multi-selection can't be count-capped, so a doc pick is
        // exactly where overflow reaches here — on every iOS version, iOS 26 included.
        let limit = maxCount
        let remaining = max(0, limit - tiles.count)
        guard remaining > 0 else {
            onLimitReached?(limit)
            return
        }
        guard picked.count <= remaining else {
            onLimitReached?(limit)
            return
        }
        let allowed = picked

        var itemsToUpload: [UploadFileItem] = []
        for media in allowed {
            let tile = AttachmentTile(fileId: media.fileId,
                                      file: media.file,
                                      mimeType: media.mimeType,
                                      previewImage: media.previewImage)
            if (media.file.data?.count ?? 0) > maxSize {
                // Over the limit: rejected up front, never uploaded. Blocks send until removed.
                tile.status = .rejected
                tile.error = CometChatException(
                    errorCode: "ERR_FILE_SIZE_EXCEEDED",  // matches the SDK's cross-platform code
                    errorDescription: "The file must not be greater than \(maxFileSizeInMB) MB.")
            } else {
                itemsToUpload.append(UploadFileItem(fileId: media.fileId, file: media.file))
            }
            tiles.append(tile)
        }
        onChange?()
        guard !itemsToUpload.isEmpty else { return }
        request().uploadAttachments(itemsToUpload, listener: self)
    }

    public func cancel(fileId: String) {
        uploadRequest?.removeAttachment(fileId: fileId)
        tiles.removeAll { $0.fileId == fileId }
        onChange?()
    }

    public func retry(fileId: String) {
        guard let tile = tiles.first(where: { $0.fileId == fileId }) else { return }
        tile.status = .uploading
        tile.percent = 0
        tile.bytesUploaded = 0
        tile.error = nil
        onChange?()
        // The SDK retained the FAILED file's bytes; retryAttachment re-presigns and
        // re-uploads just that file (and preserves the batch's attachment order).
        request().retryAttachment(fileId: fileId)
    }

    public func clear() {
        // Releases the whole batch: aborts anything in flight and frees the SDK's
        // per-file state + listeners. Called after a successful send (release) and
        // when abandoning the composer (abort), per the design doc.
        uploadRequest?.clearAll()
        uploadRequest = nil
        tiles.removeAll()
        onChange?()
    }

    // MARK: - Request lifecycle

    private func request() -> UploadFileRequest {
        if let existing = uploadRequest { return existing }
        let created = CometChat.createUploadFileRequest(receiverId: receiverId, receiverType: receiverType)
        if let parentMessageId = parentMessageId {
            created.setParentMessageId(parentMessageId)
        }
        uploadRequest = created
        return created
    }

    /// Receiver changed: any staged batch belongs to the previous conversation —
    /// abort and drop it so uploads can't land on the wrong destination.
    private func resetBatch() {
        guard uploadRequest != nil || !tiles.isEmpty else { return }
        uploadRequest?.clearAll()
        uploadRequest = nil
        tiles.removeAll()
        onChange?()
    }

    private func tile(for fileId: String) -> AttachmentTile? {
        tiles.first { $0.fileId == fileId }
    }

    // MARK: - UploadFileListener

    public func onFileUploaded(fileId: String, attachment: Attachment) {
        guard let tile = tile(for: fileId) else { return }
        tile.status = .done
        tile.attachment = attachment
        tile.percent = 100
        onTileUpdated?(tile)
        onChange?()  // re-evaluate canSend
    }

    public func onFileProgress(fileId: String, loaded: Int64, total: Int64, percent: Int) {
        guard let tile = tile(for: fileId) else { return }
        tile.bytesUploaded = loaded
        tile.totalBytes = total
        tile.percent = percent
        onTileUpdated?(tile)
    }

    /// Rejected (validation / presign authorization) — not retryable. No proactive
    /// alert: the tile turns red, and tapping it surfaces the explanation.
    public func onFileError(fileId: String, error: CometChatException) {
        mark(fileId: fileId, status: .rejected, error: error)
    }

    /// Transfer failed — retryable (network/S3/stall/expired presign). A validation
    /// error that slips down the failure path can never succeed on retry —
    /// reclassify it as rejected so the tile shows the red !, blocks send, and
    /// explains its reason on tap instead of offering a futile retry.
    public func onFileFailure(fileId: String, error: CometChatException) {
        mark(fileId: fileId, status: isValidationError(error) ? .rejected : .failed, error: error)
    }

    private func isValidationError(_ error: CometChatException) -> Bool {
        let haystack = (error.errorCode + " " + error.errorDescription).lowercased()
        return haystack.contains("too large") || haystack.contains("file size")
            || haystack.contains("size_exceeded") || haystack.contains("count_exceeded")
            || haystack.contains("mime") || haystack.contains("file type")
            || (haystack.contains("type") && haystack.contains("allow"))
    }

    private func mark(fileId: String, status: AttachmentTileStatus, error: CometChatException) {
        guard let tile = tile(for: fileId) else { return }
        tile.status = status
        tile.error = error
        onTileUpdated?(tile)
        onChange?()
    }
}
