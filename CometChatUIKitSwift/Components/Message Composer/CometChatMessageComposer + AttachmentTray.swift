//
//  CometChatMessageComposer + AttachmentTray.swift
//  CometChatUIKitSwift
//
//  Wires the multi-attachment preview tray + uploader into the composer: pick → stage
//  → upload (with progress/cancel/retry) → send one message with all attachments and
//  the composer text as the caption.
//

import UIKit
import CometChatSDK

extension CometChatMessageComposer {

    func setupAttachmentTray() {
        // Tray sits just below the input box.
        let inputIndex = composerBoxContainerStackView.arrangedSubviews.firstIndex(of: topContainerView) ?? 0
        composerBoxContainerStackView.insertArrangedSubview(attachmentTray, at: inputIndex + 1)
        NSLayoutConstraint.activate([
            attachmentTray.leadingAnchor.constraint(equalTo: composerBoxContainerStackView.leadingAnchor),
            attachmentTray.trailingAnchor.constraint(equalTo: composerBoxContainerStackView.trailingAnchor)
        ])

        mediaPicker.onPicked = { [weak self] picked in
            self?.uploadManager.add(picked)
        }

        uploadManager.onChange = { [weak self] in
            guard let self = self else { return }
            self.attachmentTray.set(tiles: self.uploadManager.tiles)
            self.attachmentTray.isHidden = self.uploadManager.tiles.isEmpty
            // Voice notes are standalone — hide the mic while attachments are staged.
            self.microphoneButton.isHidden = self.uploadManager.hasAttachments || self.hideVoiceRecordingButton
            self.updateSendButtonState()
        }

        uploadManager.onTileUpdated = { [weak self] tile in
            guard let self = self else { return }
            self.attachmentTray.update(tile: tile)
            self.updateSendButtonState()
        }

        attachmentTray.onRemove = { [weak self] tile in
            self?.uploadManager.cancel(fileId: tile.fileId)
        }

        attachmentTray.onRetry = { [weak self] tile in
            self?.uploadManager.retry(fileId: tile.fileId)
        }

        uploadManager.onLimitReached = { [weak self] maxCount in
            self?.showAttachmentLimitMessage(maxCount)
        }

        attachmentTray.onTileTapped = { [weak self] tile in
            guard let self = self else { return }
            // A rejected tile explains its reason on tap instead of opening the viewer.
            // (.failed taps never arrive here — the tray cell turns them into retries.)
            if tile.status == .rejected {
                self.showAttachmentErrorMessage(for: tile)
                return
            }
            self.openStagedMediaViewer(for: tile)
        }

        // Clipboard paste: images and files on the pasteboard stage into the tray.
        // Not while editing — an edit can't add attachments.
        textView.onImagePaste = { [weak self] images in
            guard let self, self.enableMultipleAttachments, self.messageComposerMode != .edit else { return }
            self.stagePastedImages(images)
        }
        textView.onFilePaste = { [weak self] files in
            guard let self, self.enableMultipleAttachments, self.messageComposerMode != .edit else { return }
            self.stagePastedFiles(files)
        }
    }

    /// Stages clipboard images as JPEG attachments (same path as picked media).
    func stagePastedImages(_ images: [UIImage]) {
        let picked: [PickedMedia] = images.compactMap { image in
            guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
            let name = "pasted-image-\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
            return PickedMedia(fileId: UUID().uuidString,
                               file: File(name: name, data: data),
                               mimeType: "image/jpeg",
                               previewImage: image)
        }
        guard !picked.isEmpty else { return }
        uploadManager.add(picked)
        attachmentTray.isHidden = false
        updateSendButtonState()
    }

    /// Stages clipboard files (videos, PDFs, documents, audio, …) as attachments
    /// (same path as files picked through the document picker).
    func stagePastedFiles(_ files: [GrowingTextView.PastedFileItem]) {
        let picked: [PickedMedia] = files.map { item in
            // Videos/images get a real thumbnail on their tray tile; other types
            // render as chips and need no preview.
            var preview: UIImage? = nil
            if item.mimeType.hasPrefix("video/") || item.mimeType.hasPrefix("image/"),
               let tempURL = MessageComposerTrayPreview.tempURL(fileName: item.name, data: item.data) {
                preview = MultiMediaPicker.preview(forData: item.data, url: tempURL, mimeType: item.mimeType)
            }
            return PickedMedia(fileId: UUID().uuidString,
                               file: File(name: item.name, data: item.data),
                               mimeType: item.mimeType,
                               previewImage: preview)
        }
        guard !picked.isEmpty else { return }
        uploadManager.add(picked)
        attachmentTray.isHidden = false
        updateSendButtonState()
    }

    /// Tapping a staged image/video tile opens the same fullscreen `CometChatMediaViewer`
    /// used by sent messages, paging over every staged media item.
    func openStagedMediaViewer(for tappedTile: AttachmentTile) {
        guard let controller = controller,
              tappedTile.kind == .image || tappedTile.kind == .video else { return }
        let mediaTiles = uploadManager.tiles.filter { $0.kind == .image || $0.kind == .video }
        guard !mediaTiles.isEmpty else { return }

        // Always preview from the LOCAL bytes — the upload-response URL is often an S3
        // object URL that isn't directly viewable, so using it shows a black screen.
        let attachments: [Attachment] = mediaTiles.map { tile in
            let ext = (tile.fileName as NSString).pathExtension
            let localURL = MessageComposerTrayPreview.tempURL(fileName: tile.fileName, data: tile.file.data)
            return Attachment(fileName: tile.fileName, fileExtension: ext,
                              fileMimeType: tile.mimeType, fileUrl: localURL?.absoluteString ?? "")
        }
        let startIndex = mediaTiles.firstIndex(where: { $0.fileId == tappedTile.fileId }) ?? 0
        let viewer = CometChatMediaViewer(mediaItems: attachments, startIndex: startIndex)
        viewer.isLocalPreview = true   // composer context: minimal chrome (close + mute)
        controller.present(viewer, animated: true)
    }

    /// Present the multi-select media library (images + videos) and stage the picks,
    /// capped to the remaining attachment slots.
    func presentMultiMediaLibrary() {
        guard let controller = controller else { return }
        let remaining = uploadManager.maxCount - uploadManager.tiles.count
        guard remaining > 0 else {
            showAttachmentLimitMessage(uploadManager.maxCount)
            return
        }
        mediaPicker.presentMediaLibrary(from: controller, selectionLimit: remaining)
    }

    /// Present the multi-select document picker and stage the picks.
    func presentMultiDocumentPicker() {
        guard let controller = controller else { return }
        guard uploadManager.tiles.count < uploadManager.maxCount else {
            showAttachmentLimitMessage(uploadManager.maxCount)
            return
        }
        mediaPicker.presentDocuments(from: controller)
    }

    /// Snack bar above the composer when the user tries to exceed the per-message
    /// attachment limit.
    func showAttachmentLimitMessage(_ maxCount: Int) {
        let message = String(format: "attachment_count_exceeded".localize(), "\(maxCount)")
        CometChatErrorState.show(message: message, above: self, in: controller?.view ?? superview ?? self)
    }

    /// Snack bar above the composer with the tile's ACTUAL error reason: size-limit
    /// text for oversize rejections, "file type isn't allowed" for mime rejections,
    /// otherwise the error's own description.
    func showAttachmentErrorMessage(for tile: AttachmentTile) {
        let code = tile.error?.errorCode.uppercased() ?? ""
        let description = tile.error?.errorDescription ?? ""
        let haystack = (code + " " + description).lowercased()

        let message: String
        if code == "ERR_FILE_TOO_LARGE" || haystack.contains("too large") || haystack.contains("file size") {
            message = String(format: "attachment_size_exceeded".localize(), "\(uploadManager.maxFileSizeInMB)")
        } else if code == "ERR_FILE_TYPE_NOT_ALLOWED" || haystack.contains("mime")
                    || haystack.contains("file type")
                    || (haystack.contains("type") && haystack.contains("allow")) {
            message = "attachment_type_not_allowed".localize()
        } else if !description.isEmpty {
            message = description
        } else {
            message = String(format: "attachment_size_exceeded".localize(), "\(uploadManager.maxFileSizeInMB)")
        }
        CometChatErrorState.show(message: message, above: self, in: controller?.view ?? superview ?? self)
    }

    /// Stage a local file (camera capture, recorded voice note, audio-library pick)
    /// into the tray as an attachment and start its upload.
    func stageLocalMedia(urlString: String) {
        guard let url = URL(string: urlString), let data = try? Data(contentsOf: url) else { return }
        let mime = MultiMediaPicker.mimeType(forExtension: url.pathExtension)
        let preview = MultiMediaPicker.preview(forData: data, url: url, mimeType: mime)
        let media = PickedMedia(fileId: UUID().uuidString,
                                file: File(name: url.lastPathComponent, data: data),
                                mimeType: mime,
                                previewImage: preview)
        uploadManager.add([media])
    }

    /// Build and send one message carrying every uploaded attachment + the caption.
    func sendStagedAttachments() {
        guard uploadManager.canSend else { return } // still uploading — ignore
        let caption = textView.text ?? ""
        let attachments = uploadManager.readyAttachments
        guard !attachments.isEmpty else { return }

        viewModel.sendMultiAttachmentMessage(attachments: attachments, caption: caption,
                                             batchId: uploadManager.batchId)

        uploadManager.clear()
        attachmentTray.isHidden = true
        viewModel.reset?(true)
        updateSendButtonState()
    }
}

/// Writes a staged media tile's local bytes to a temp file so the media viewer can page
/// through not-yet-uploaded items. Shared by both composers.
enum MessageComposerTrayPreview {
    static func tempURL(fileName: String, data: Data?) -> URL? {
        guard let data = data else { return nil }
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent("cc_staged_preview", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let safeName = fileName.isEmpty ? "file" : fileName
        let url = dir.appendingPathComponent(safeName)
        do { try data.write(to: url); return url } catch { return nil }
    }
}
