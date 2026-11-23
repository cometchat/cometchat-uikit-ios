//
//  OfflineMediaSource.swift
//  CometChatUIKitSwift
//
//  Where the bytes of a video, audio or file bubble come from on the offline (ON) path. The kit keeps
//  no media cache of its own (README 3.8): it asks the SDK for the on-device copy (an own un-acked
//  send's `attachment.localPath`, the cached copy of a hosted URL) before the network. No UIKit.
//

import Foundation
import UIKit
import CometChatSDK

internal enum OfflineMediaSource {

    enum Source: Equatable {
        /// Play / open this file on the device.
        case local(String)
        /// No on-device copy, but the network can serve it: today's remote URL.
        case remote
        /// No on-device copy and no connection: show "available when online".
        case unavailableOffline
    }

    /// `ownPaths` are the paths the message itself carries (own un-acked send: `attachment.localPath`,
    /// the composer's `metaData["fileURL"]`), `cachedPath` the SDK's copy of the hosted URL. The
    /// first one that exists wins. Offline OFF never reaches here.
    static func resolve(ownPaths: [String?],
                        cachedPath: String?,
                        connected: Bool,
                        fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }) -> Source {
        for candidate in ownPaths + [cachedPath] {
            guard let raw = candidate, !raw.isEmpty else { continue }
            let path = normalize(raw)
            if fileExists(path) { return .local(path) }
        }
        return connected ? .remote : .unavailableOffline
    }

    /// `file:///a/b` and `/a/b` are the same file.
    static func normalize(_ path: String) -> String {
        var p = path
        while p.hasPrefix("file://") { p = String(p.dropFirst(7)) }
        return p.removingPercentEncoding ?? p
    }

    /// A path AVFoundation's player can open for `path` (iOS-VOICE-1). The SDK keeps its cached copy
    /// of a hosted file under a hashed name with no extension, and `AVPlayerItem` / `AVURLAsset`
    /// refuse such a file ("Cannot Open"), so a voice note showed `00:00/00:00` and never advanced.
    /// For a file with no extension this returns a symbolic link to it, named with `fileExtension`,
    /// in the app's temporary folder; any other path, or a failure, returns `path` unchanged.
    static func playablePath(_ path: String,
                             fileExtension: String?,
                             linkDirectory: URL = FileManager.default.temporaryDirectory
                                 .appendingPathComponent("cometchat-media", isDirectory: true)) -> String {
        let ext = (fileExtension ?? "").trimmingCharacters(in: CharacterSet(charactersIn: ". ")).lowercased()
        let file = URL(fileURLWithPath: path)
        guard file.pathExtension.isEmpty, !ext.isEmpty,
              ext.unicodeScalars.allSatisfy({ CharacterSet.alphanumerics.contains($0) }) else { return path }
        let link = linkDirectory.appendingPathComponent(file.lastPathComponent).appendingPathExtension(ext)
        let manager = FileManager.default
        if (try? manager.destinationOfSymbolicLink(atPath: link.path)) == file.path { return link.path }
        try? manager.removeItem(at: link)   // a stale link (the copy moved)
        do {
            try manager.createDirectory(at: linkDirectory, withIntermediateDirectories: true)
            try manager.createSymbolicLink(at: link, withDestinationURL: file)
            return link.path
        } catch {
            return path
        }
    }

    /// The extension a media message's file has: the attachment's, else its hosted URL's.
    static func fileExtension(of message: MediaMessage?) -> String? {
        if let ext = message?.attachment?.fileExtension, !ext.isEmpty { return ext }
        let urlExt = URL(string: message?.attachment?.fileUrl ?? "")?.pathExtension ?? ""
        return urlExt.isEmpty ? nil : urlExt
    }

    /// Resolve for a message, reading the SDK (only called with the gate read ON for this bubble).
    /// `extraPaths`: other files a bubble can show, such as an image's thumbnail or today's copy.
    static func resolve(for message: MediaMessage?, extraPaths: [String?] = []) -> Source {
        // `localPath` is written by the SDK on this device; `metaData["fileURL"]` comes from the sender.
        let own: [String?] = [message?.attachment?.localPath,
                              MessageMediaTrust.link(message?.metaData?["fileURL"] as? String, in: message)] + extraPaths
        let url = message?.attachment?.fileUrl ?? ""
        let cached = url.isEmpty ? nil : CometChat.getCachedMediaPath(url)
        return resolve(ownPaths: own, cachedPath: cached, connected: CometChat.getConnectionStatus == .connected)
    }
}

/// Which media links in a message the kit may follow to a file on THIS device (iOS-SEC-1).
///
/// A message's links come from its sender. Only the logged-in user's own messages legitimately
/// carry a local file (the composer's pick, an un-acked send). Another user's message can carry
/// any string, and a `file://` link or an absolute path from them made the kit show, open, copy
/// and share the reader's own private file as that user's media. Such a link is dropped; the
/// bubble then shows what it shows for media with no link. Hosted (https) links are unchanged.
/// The Android UI Kit gets the same fix.
internal enum MessageMediaTrust {

    /// True when `link` names a file on the device: a `file:` URL (any case) or an absolute path.
    static func namesDeviceFile(_ link: String?) -> Bool {
        guard let raw = link?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else { return false }
        if raw.hasPrefix("/") || raw.hasPrefix("~") { return true }
        if let scheme = URL(string: raw)?.scheme { return scheme.lowercased() == "file" }
        return raw.lowercased().hasPrefix("file:")
    }

    /// True when the logged-in user sent `message`.
    static func isOwn(_ message: BaseMessage?) -> Bool {
        LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
    }

    /// `link` as the kit may use it for `message`: unchanged, except nil when it names a file on the
    /// device and someone else sent the message.
    static func link(_ link: String?, in message: BaseMessage?,
                     isOwn: (BaseMessage?) -> Bool = MessageMediaTrust.isOwn) -> String? {
        guard namesDeviceFile(link) else { return link }
        return isOwn(message) ? link : nil
    }

    /// `message.attachments`, where an attachment from someone else whose link names a file on the
    /// device keeps its name and type but loses the link.
    static func attachments(of message: MediaMessage,
                            isOwn: (BaseMessage?) -> Bool = MessageMediaTrust.isOwn) -> [Attachment] {
        let list = message.attachments ?? []
        guard !isOwn(message) else { return list }
        return list.map { trusted($0, isOwn: false) }
    }

    /// `attachment` (of `message`), or a copy without its link when the link names a file on the
    /// device and someone else sent the message.
    static func attachment(_ attachment: Attachment, of message: BaseMessage?,
                           isOwn: (BaseMessage?) -> Bool = MessageMediaTrust.isOwn) -> Attachment {
        trusted(attachment, isOwn: isOwn(message))
    }

    /// The thumbnail links of `message` (index → link), without device-file links from someone else.
    static func thumbnails(_ thumbnails: [Int: String], of message: BaseMessage?,
                           isOwn: (BaseMessage?) -> Bool = MessageMediaTrust.isOwn) -> [Int: String] {
        guard !isOwn(message) else { return thumbnails }
        return thumbnails.filter { !namesDeviceFile($0.value) }
    }

    private static func trusted(_ attachment: Attachment, isOwn: Bool) -> Attachment {
        guard !isOwn, namesDeviceFile(attachment.fileUrl) else { return attachment }
        return Attachment(fileName: attachment.fileName, fileExtension: attachment.fileExtension,
                          fileMimeType: attachment.fileMimeType, fileUrl: "")
    }
}

/// A user's tap on a media placeholder while connected (AC-12.3): the SDK downloads and caches the
/// file, and the rows that show it redraw from the on-device copy. One download per URL at a time.
internal final class OfflineMediaDownload {

    internal static let shared = OfflineMediaDownload()

    typealias Download = (_ url: String, _ messageId: Int,
                          _ onSuccess: @escaping (String) -> Void,
                          _ onError: @escaping (CometChatException) -> Void) -> Void

    private let lock = NSLock()
    private var inFlight: Set<String> = []
    private let download: Download
    private let isConnected: () -> Bool
    private let ready: (_ url: String, _ path: String) -> Void

    init(download: @escaping Download = { url, id, onSuccess, onError in
            CometChat.downloadMedia(url: url, messageServerId: id, onSuccess: onSuccess, onError: onError)
         },
         isConnected: @escaping () -> Bool = { CometChat.getConnectionStatus == .connected },
         ready: @escaping (String, String) -> Void = { OfflineHub.shared.mediaDownloaded(url: $0, localPath: $1) }) {
        self.download = download
        self.isConnected = isConnected
        self.ready = ready
    }

    /// Asks the SDK for `message`'s file. Offline, or with a download already running, does nothing.
    func request(for message: MediaMessage?) {
        // Another user's link to a file on this device is never downloaded (iOS-SEC-1).
        request(url: MessageMediaTrust.link(message?.attachment?.fileUrl, in: message), messageId: message?.id ?? 0)
    }

    /// Same, for one attachment of a multi-attachment message (`messageId` is the message's id).
    func request(url: String?, messageId: Int) {
        guard let url = url, !url.isEmpty, isConnected() else { return }
        lock.lock()
        let isNew = inFlight.insert(url).inserted
        lock.unlock()
        guard isNew else { return }
        download(url, max(messageId, 0), { [weak self] path in
            self?.finish(url)
            self?.ready(url, path)
        }, { [weak self] error in
            self?.finish(url)
            CometChatLogger.error("media download failed: \(error.errorDescription)")
        })
    }

    private func finish(_ url: String) {
        lock.lock()
        inFlight.remove(url)
        lock.unlock()
    }
}

/// Where the bytes of ONE attachment of a gallery (photo/video grid tile, full-screen viewer page,
/// Share / Download) come from on the offline (ON) path. Every answer is `nil` with offline OFF, so
/// the caller keeps today's remote-URL code unchanged. The on-device copy is the attachment's own
/// `localPath` (own queued or sent file), a `file://` URL, the SDK's cached copy of the hosted URL,
/// then the kit's earlier Documents download; it is never fetched again (BEH-MEDIA-18).
internal enum GalleryMedia {

    /// A way to resolve an attachment (the real lookup below; tests hand a stub to the tile, page and
    /// share helpers so no global state is shared between parallel tests).
    typealias SourceProvider = (_ attachment: Attachment, _ thumbnailUrl: String?) -> OfflineMediaSource.Source?

    /// `thumbnailUrl`: a tile's server thumbnail; its SDK copy also counts as "on the device".
    static func source(for attachment: Attachment, thumbnailUrl: String? = nil) -> OfflineMediaSource.Source? {
        defaultSource(for: attachment, thumbnailUrl: thumbnailUrl,
                      gateOn: { OfflineGate.isOn() },
                      cachedPath: { CometChat.getCachedMediaPath($0) },
                      connected: { CometChat.getConnectionStatus == .connected })
    }

    static func defaultSource(for attachment: Attachment,
                              thumbnailUrl: String? = nil,
                              gateOn: () -> Bool,
                              cachedPath: (String) -> String?,
                              connected: () -> Bool,
                              kitCopy: (Attachment) -> String? = { kitDownloadPath(for: $0) },
                              fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }) -> OfflineMediaSource.Source? {
        guard gateOn() else { return nil }
        let url = attachment.fileUrl
        let thumb = (thumbnailUrl?.isEmpty == false) ? cachedPath(thumbnailUrl!) : nil
        let own: [String?] = [attachment.localPath, url.hasPrefix("file://") ? url : nil, thumb]
        let sdk = url.isEmpty || url.hasPrefix("file://") ? nil : cachedPath(url)
        let cached = sdk ?? (url.isEmpty ? nil : kitCopy(attachment))
        return OfflineMediaSource.resolve(ownPaths: own, cachedPath: cached, connected: connected(), fileExists: fileExists)
    }

    /// The kit's own earlier Documents download of this attachment (Download control / file share).
    private static func kitDownloadPath(for attachment: Attachment) -> String? {
        let name = attachment.fileName.isEmpty ? (URL(string: attachment.fileUrl)?.lastPathComponent ?? "") : attachment.fileName
        return FileDownloadControl.localCopy(for: attachment.fileUrl, fileName: name).path
    }

    /// The on-device file when there is one (`.local`), else nil.
    static func localFileURL(for attachment: Attachment) -> URL? {
        if case .local(let path)? = source(for: attachment) { return URL(fileURLWithPath: path) }
        return nil
    }

    /// What Share / Download hands over for an attachment.
    enum ShareItem: Equatable {
        /// A file on the device, named like the attachment, ready for the share sheet.
        case local(URL)
        /// Not on the device: fetch it, as today.
        case remote(URL)
        /// Not on the device and offline.
        case unavailableOffline
    }

    /// Offline OFF: `.remote(url)` for a parseable `fileUrl`, else nil: exactly what the callers did.
    static func shareItem(for attachment: Attachment,
                          source provider: SourceProvider = { source(for: $0, thumbnailUrl: $1) },
                          tempDirectory: URL = FileManager.default.temporaryDirectory) -> ShareItem? {
        switch provider(attachment, nil) {
        case nil:
            return URL(string: attachment.fileUrl).map { .remote($0) }
        case .local(let path)?:
            return exportCopy(of: URL(fileURLWithPath: path), named: attachment.fileName, in: tempDirectory).map { .local($0) }
        case .remote?:
            return URL(string: attachment.fileUrl).map { .remote($0) }
        case .unavailableOffline?:
            return .unavailableOffline
        }
    }

    /// The SDK's cache file names are not the attachment's, so share a copy that is.
    static func exportCopy(of file: URL, named name: String, in tempDirectory: URL) -> URL? {
        let fileName = safeFileName(name, fallback: file.lastPathComponent)
        let dir = tempDirectory.appendingPathComponent(UUID().uuidString)
        let dest = dir.appendingPathComponent(fileName)
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try FileManager.default.copyItem(at: file, to: dest)
            return dest
        } catch {
            return file
        }
    }

    /// The name the shared copy gets: the attachment name's last component only, so a name such as
    /// "../../x.jpg" cannot place the copy outside its folder (the Android kit: `File(name).name`).
    /// An empty name, ".", ".." or a name made only of "/" gets `fallback`.
    static func safeFileName(_ name: String, fallback: String) -> String {
        let base = (name as NSString).lastPathComponent
        if base.isEmpty || base == "." || base == ".." || base.contains("/") { return fallback }
        return base
    }

    /// The kit's existing offline notice for media that is neither on the device nor reachable.
    static func showUnavailableNotice(on controller: UIViewController?) {
        CometChatToast.show(message: "MEDIA_AVAILABLE_WHEN_ONLINE".localize(), on: controller)
    }
}
