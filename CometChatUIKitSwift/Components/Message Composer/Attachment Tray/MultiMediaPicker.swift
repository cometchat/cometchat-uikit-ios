//
//  MultiMediaPicker.swift
//  CometChatUIKitSwift
//
//  Multi-select pickers that turn picked assets into `File(name:data:)` + a local
//  preview, for staging in the composer attachment tray. Images/videos come from
//  PHPicker (selectionLimit 0, iOS 14+); arbitrary files from UIDocumentPicker
//  (multiple).
//

import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers
import CometChatSDK

public struct PickedMedia {
    public let fileId: String
    public let file: File
    public let mimeType: String
    public let previewImage: UIImage?
}

public final class MultiMediaPicker: NSObject {

    /// Delivered on the main thread with everything that was picked.
    public var onPicked: (([PickedMedia]) -> Void)?

    private weak var presenter: UIViewController?

    public func presentMediaLibrary(from presenter: UIViewController, selectionLimit: Int = 0) {
        self.presenter = presenter
        guard #available(iOS 14.0, *) else { return }
        var config = PHPickerConfiguration()
        config.selectionLimit = max(0, selectionLimit) // 0 = unlimited
        config.filter = .any(of: [.images, .videos])
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        presenter.present(picker, animated: true)
    }

    public func presentDocuments(from presenter: UIViewController) {
        self.presenter = presenter
        // Copy-in pickers (`.import` / `asCopy: true`) make iOS copy every picked file
        // into the app's Inbox BEFORE calling the delegate — and that copy step races
        // on multi-select with large files (iOS 18 delivers only a subset, seen as
        // "Generation not found" Inbox errors). Open-in-place mode returns ALL selected
        // URLs immediately as security-scoped references; the delegate reads the bytes
        // itself, so there is no system copy to race or drop.
        let picker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
        } else {
            picker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .open)
        }
        picker.allowsMultipleSelection = true
        picker.delegate = self
        presenter.present(picker, animated: true)
    }

    // MARK: - Helpers

    static func mimeType(forExtension ext: String) -> String {
        let map: [String: String] = [
            "jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png", "gif": "image/gif",
            "webp": "image/webp", "heic": "image/heic", "heif": "image/heic", "bmp": "image/bmp", "tiff": "image/tiff",
            "pdf": "application/pdf",
            "doc": "application/msword",
            "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "xls": "application/vnd.ms-excel",
            "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "ppt": "application/vnd.ms-powerpoint",
            "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
            "txt": "text/plain", "csv": "text/csv", "json": "application/json", "zip": "application/zip",
            "mp4": "video/mp4", "mov": "video/quicktime", "m4v": "video/x-m4v", "webm": "video/webm", "3gp": "video/3gpp",
            "mp3": "audio/mpeg", "wav": "audio/wav", "aac": "audio/aac", "m4a": "audio/mp4", "ogg": "audio/ogg"
        ]
        return map[ext.lowercased()] ?? "application/octet-stream"
    }

    static func preview(forData data: Data, url: URL, mimeType: String) -> UIImage? {
        if mimeType.hasPrefix("image/") {
            return UIImage(data: data)
        }
        if mimeType.hasPrefix("video/") {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 200, height: 200)
            let time = CMTime(seconds: 0.5, preferredTimescale: 60)
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}

// MARK: - PHPicker

@available(iOS 14.0, *)
extension MultiMediaPicker: PHPickerViewControllerDelegate {

    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        let group = DispatchGroup()
        var picked: [(Int, PickedMedia)] = []   // keep selection order
        let lock = NSLock()

        for (index, result) in results.enumerated() {
            group.enter()
            MultiMediaPicker.load(provider: result.itemProvider) { media in
                if let media {
                    lock.lock(); picked.append((index, media)); lock.unlock()
                }
                group.leave()
            }
        }

        group.notify(queue: .main) { [weak self] in
            let ordered = picked.sorted { $0.0 < $1.0 }.map { $0.1 }
            guard !ordered.isEmpty else { return }
            self?.onPicked?(ordered)
        }
    }

    private static let movieUTI = "public.movie"
    private static let imageUTI = "public.image"

    /// Robustly turn one picked item into a `PickedMedia`. Uses conforming UTIs (not
    /// `registeredTypeIdentifiers.first`, which fails for HEIC/iCloud assets on device)
    /// and falls back to loading a `UIImage` object for images.
    private static func load(provider: NSItemProvider, completion: @escaping (PickedMedia?) -> Void) {
        if provider.hasItemConformingToTypeIdentifier(movieUTI) {
            provider.loadFileRepresentation(forTypeIdentifier: movieUTI) { url, _ in
                guard let url = url, let data = try? Data(contentsOf: url) else { completion(nil); return }
                let ext = url.pathExtension.isEmpty ? "mov" : url.pathExtension
                let name = (provider.suggestedName ?? "video") + ".\(ext)"
                let mime = mimeType(forExtension: ext)
                let thumb = preview(forData: data, url: url, mimeType: mime)
                completion(PickedMedia(fileId: UUID().uuidString,
                                       file: File(name: name, data: data),
                                       mimeType: mime,
                                       previewImage: thumb))
            }
            return
        }

        if provider.hasItemConformingToTypeIdentifier(imageUTI) {
            provider.loadFileRepresentation(forTypeIdentifier: imageUTI) { url, _ in
                if let url = url, let data = try? Data(contentsOf: url) {
                    let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
                    let name = (provider.suggestedName ?? "image") + ".\(ext)"
                    let mime = mimeType(forExtension: ext)
                    completion(PickedMedia(fileId: UUID().uuidString,
                                           file: File(name: name, data: data),
                                           mimeType: mime,
                                           previewImage: UIImage(data: data)))
                } else {
                    loadImageObject(provider: provider, completion: completion)
                }
            }
            return
        }

        loadImageObject(provider: provider, completion: completion)
    }

    /// Fallback that decodes a `UIImage` (handles HEIC/iCloud) and re-encodes to JPEG.
    private static func loadImageObject(provider: NSItemProvider, completion: @escaping (PickedMedia?) -> Void) {
        guard provider.canLoadObject(ofClass: UIImage.self) else { completion(nil); return }
        provider.loadObject(ofClass: UIImage.self) { object, _ in
            guard let image = object as? UIImage, let data = image.jpegData(compressionQuality: 0.9) else {
                completion(nil); return
            }
            let name = (provider.suggestedName ?? "image") + ".jpg"
            completion(PickedMedia(fileId: UUID().uuidString,
                                   file: File(name: name, data: data),
                                   mimeType: "image/jpeg",
                                   previewImage: image))
        }
    }
}

// MARK: - Documents

extension MultiMediaPicker: UIDocumentPickerDelegate {

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var picked: [PickedMedia] = []
        for url in urls {
            let needsScope = url.startAccessingSecurityScopedResource()
            defer { if needsScope { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url) else {
                continue
            }
            let ext = url.pathExtension
            let mime = MultiMediaPicker.mimeType(forExtension: ext)
            let preview = MultiMediaPicker.preview(forData: data, url: url, mimeType: mime)
            picked.append(PickedMedia(fileId: UUID().uuidString,
                                      file: File(name: url.lastPathComponent, data: data),
                                      mimeType: mime,
                                      previewImage: preview))
        }
        guard !picked.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in self?.onPicked?(picked) }
    }
}
