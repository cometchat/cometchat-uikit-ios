//
//  ImageService.swift
//  CometChatSwift
//
//  Created by Abdullah Ansari on 25/04/22.
//  Copyright © 2022 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatSDK
import CryptoKit

final class ImageService {
    
    
    //Will be having 60 MB limit for caching normal images
    static var imageCache: NSCache<AnyObject, AnyObject> = {
        let imageCache = NSCache<AnyObject, AnyObject>()
        imageCache.totalCostLimit = 60 * 1024 * 1024  //60MB Limit
        return imageCache
    }()
    
    //No Limit for caching avatar images
    static var avatarCache = NSCache<AnyObject, AnyObject>()
    
    // MARK: - Public API
    func image(for url: URL, cacheType: CacheType, allowLocalMedia: Bool = true, completion: @escaping (UIImage?) -> Void) -> Cancellable {
        
        var task = URLSession.shared.dataTask(with: url)
        // Offline ON (read once for this load): avatars are also kept on disk, so a cold start
        // without a connection shows the picture instead of the initials.
        let avatarOnDisk = cacheType == .avatar && OfflineGate.isOn()
        if cacheType == .avatar, let cacheImage = ImageService.avatarCache.object(forKey: url as AnyObject) as? UIImage {
            DispatchQueue.main.async { [weak cacheImage] in
                completion(cacheImage)
            }
        } else if cacheType == .normal, let cacheImage = ImageService.imageCache.object(forKey: url as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                completion(cacheImage)
            }
        } else if avatarOnDisk, !AvatarOfflineRetry.shared.isConnected(),
                  let data = AvatarDiskCache.shared.data(for: url) {
            // Not connected: the saved copy, without trying the network.
            return ImageService.loadFromDevice(read: { data },
                                               cache: { ImageService.avatarCache.setObject($0, forKey: url as AnyObject) },
                                               fallback: nil,
                                               completion: completion)
        } else if cacheType == .normal, allowLocalMedia, OfflineGate.isOn(),
                  let localPath = CometChat.getCachedMediaPath(url.absoluteString) {
            // Offline ON (read once for this load): the SDK's on-device copy of the media, if it has
            // one, before the network. Falls through to the URL when there is none.
            let fileURL = URL(fileURLWithPath: localPath)
            return ImageService.loadFromDevice(read: { try? Data(contentsOf: fileURL) },
                                               cache: { ImageService.imageCache.setObject($0, forKey: url as AnyObject) },
                                               // The file is gone or unreadable: today's network load.
                                               fallback: { ImageService().image(for: url, cacheType: .normal, allowLocalMedia: false, completion: $0) },
                                               completion: completion)
        } else {
            
            var finalURL = url

            if finalURL.scheme == "http" {
                var comps = URLComponents(url: finalURL, resolvingAgainstBaseURL: false)
                comps?.scheme = "https"
                if let httpsURL = comps?.url {
                    finalURL = httpsURL
                }
            }
            
            let dataTask = URLSession.shared.dataTask(with: finalURL) { data, result, error in
                // Decode on THIS background thread, not the main thread. `UIImage(data:)`
                // defers the actual bitmap decode to first draw — which, for a table cell,
                // happens on the main thread mid-scroll and produces the fast-scroll
                // freeze/flicker. Force the decode here so the main thread only assigns an
                // already-drawn image; also cache the decoded copy so cache hits are free.
                var image: UIImage?
                if let data = data {
                    image = ImageService.decodedImage(from: data)
                }
                if avatarOnDisk {
                    if image != nil, let data = data {
                        AvatarDiskCache.shared.store(data, for: url)
                    } else if let saved = AvatarDiskCache.shared.data(for: url) {
                        // The load failed (e.g. still connecting on a cold start): the saved copy.
                        image = ImageService.decodedImage(from: saved)
                    }
                }

                // Execute Handler on Main Thread
                DispatchQueue.main.async {
                    if let image = image {
                        if cacheType == .avatar {
                            ImageService.avatarCache.setObject(image, forKey: url as AnyObject)
                        } else if cacheType == .normal {
                            ImageService.imageCache.setObject(image, forKey: url as AnyObject)
                        }
                        completion(image)
                    } else {
                        completion(nil)
                    }
                }
            }
            
            task = dataTask
            // Resume Data Task
            dataTask.resume()
            return dataTask
        }
        
        return task
    }
    
    enum CacheType {
        case avatar
        case normal
    }

    /// Offline ON: an image read from the device. `read` runs and the bytes are decoded off the
    /// main thread; a decoded image is put in the memory cache and completes on main. Nothing read
    /// or decoded completes with `fallback`'s load (a network load) when there is one, else nil.
    /// The returned load is what the caller cancels: a cancelled load (a reused cell) is not called
    /// back, and its network fallback is cancelled or never started.
    static func loadFromDevice(read: @escaping () -> Data?,
                               cache: @escaping (UIImage) -> Void,
                               fallback: ((@escaping (UIImage?) -> Void) -> Cancellable)?,
                               completion: @escaping (UIImage?) -> Void) -> LocalImageLoad {
        let load = LocalImageLoad()
        DispatchQueue.global(qos: .userInitiated).async {
            let image = read().flatMap { ImageService.decodedImage(from: $0) }
            DispatchQueue.main.async {
                if let image = image {
                    cache(image)
                    load.complete(image, completion)
                } else if let fallback = fallback, !load.isCancelled {
                    load.setFallback(fallback { load.complete($0, completion) })
                } else {
                    load.complete(nil, completion)
                }
            }
        }
        return load
    }

    /// Fully decodes image data into a ready-to-draw bitmap on the CURRENT (background)
    /// thread, so the main thread never pays the decode cost while scrolling.
    /// iOS 15+ has `UIImage.preparingForDisplay()` for exactly this; older OSes fall back
    /// to a manual CoreGraphics redraw. Returns the original lazy image if decoding fails.
    static func decodedImage(from data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        if #available(iOS 15.0, *) {
            return image.preparingForDisplay() ?? image
        }
        guard let cgImage = image.cgImage else { return image }
        let size = CGSize(width: cgImage.width, height: cgImage.height)
        guard size.width > 0, size.height > 0 else { return image }
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = false
        format.scale = image.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let decoded = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return decoded
    }

}

/// Offline ON (ENG-41192): an avatar whose load failed while not connected is not fetched again
/// until the connection returns. Every layout pass re-requests an avatar, so a refused load drew the
/// initials, laid out and asked again: a tight loop (1,013 refused requests in 8 s). On reconnect
/// each such avatar retries once.
internal final class AvatarOfflineRetry: NSObject, CometChatConnectionDelegate {

    static let shared = AvatarOfflineRetry()
    static let reconnected = Notification.Name("cc.avatar.offlineReconnected")
    static let listenerId = "uikit-avatar-offline-retry"

    /// Seams for tests.
    var isConnected: () -> Bool = { CometChat.getConnectionStatus == .connected }
    var listen: (AvatarOfflineRetry) -> Void = { CometChat.addConnectionListener(AvatarOfflineRetry.listenerId, $0) }

    private let lock = NSLock()
    private var failed = Set<String>()
    private var listening = false

    /// Whether a load of `url` must not go to the network now: it failed offline and the
    /// connection has not come back.
    func waitsForConnection(_ url: String) -> Bool {
        lock.lock(); let known = failed.contains(url); lock.unlock()
        return known && !isConnected()
    }

    /// A load of `url` failed. Remembered only when not connected (an online failure is today's).
    func noteFailure(_ url: String) {
        guard !isConnected() else { return }
        lock.lock()
        failed.insert(url)
        let startListening = !listening
        listening = true
        lock.unlock()
        if startListening { listen(self) }
    }

    func connected() {
        lock.lock()
        let hadFailures = !failed.isEmpty
        failed.removeAll()
        lock.unlock()
        guard hadFailures else { return }
        DispatchQueue.main.async { NotificationCenter.default.post(name: Self.reconnected, object: nil) }
    }
}

/// Offline ON: the handle of an image load served from the device (`ImageService.loadFromDevice`).
/// Before, those loads returned a data task that never ran, so `cancel()` did nothing. The closures
/// of the load in flight hold it.
internal final class LocalImageLoad: Cancellable {

    private let lock = NSLock()
    private var cancelled = false
    private var fallback: Cancellable?

    var isCancelled: Bool {
        lock.lock(); defer { lock.unlock() }
        return cancelled
    }

    func cancel() {
        lock.lock()
        cancelled = true
        let started = fallback
        fallback = nil
        lock.unlock()
        started?.cancel()
    }

    /// The network load this one fell back to. Cancelled at once when this load already is.
    func setFallback(_ load: Cancellable) {
        lock.lock()
        guard !cancelled else {
            lock.unlock()
            load.cancel()
            return
        }
        fallback = load
        lock.unlock()
    }

    /// Calls `completion` with `image` unless this load was cancelled. On main.
    func complete(_ image: UIImage?, _ completion: (UIImage?) -> Void) {
        guard !isCancelled else { return }
        completion(image)
    }
}

/// Offline ON: avatar bytes kept in Caches so an offline cold start shows the picture. Written only
/// when offline support is on, read only with offline on, and emptied on logout. Matching the Android
/// kit (Glide's default disk cache): at most 250 MB in all, the least recently used avatar (written or
/// read) removed first, no expiry, and readable once the device has been unlocked since boot.
internal final class AvatarDiskCache {

    static let shared = AvatarDiskCache()
    /// An avatar larger than this is not kept.
    static let maxBytes = 1024 * 1024
    /// The whole store is kept at or under this.
    static let maxTotalBytes = 250 * 1024 * 1024
    static let writeOptions: Data.WritingOptions = [.atomic, .completeFileProtectionUntilFirstUserAuthentication]

    let directory: URL
    let maxTotalBytes: Int
    private let now: () -> Date
    private let fileManager = FileManager.default
    private let lock = NSLock()
    /// Bytes on disk, measured once and then kept up to date by `store`; nil until measured.
    private var totalBytes: Int?

    init(directory: URL? = nil, maxTotalBytes: Int = AvatarDiskCache.maxTotalBytes, now: @escaping () -> Date = Date.init) {
        self.directory = directory ?? FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CometChatUIKit/avatars", isDirectory: true)
        self.maxTotalBytes = maxTotalBytes
        self.now = now
    }

    private func file(for url: URL) -> URL {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return directory.appendingPathComponent(digest.map { String(format: "%02x", $0) }.joined())
    }

    func data(for url: URL) -> Data? {
        let target = file(for: url)
        guard let data = try? Data(contentsOf: target) else { return nil }
        touch(target)
        return data
    }

    func store(_ data: Data, for url: URL) {
        guard !data.isEmpty, data.count <= Self.maxBytes else { return }
        lock.lock()
        defer { lock.unlock() }
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true,
                                         attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication])
        let target = file(for: url)
        let replaced = size(of: target)
        guard (try? data.write(to: target, options: Self.writeOptions)) != nil else { return }
        touch(target)
        if let total = totalBytes { totalBytes = total - replaced + data.count }
        trim()
    }

    /// Keeps the store at or under `maxTotalBytes`, removing the least recently used avatars first
    /// (the one just written is the most recent). Called with `lock` held.
    private func trim() {
        let total = totalBytes ?? measure().reduce(0) { $0 + $1.size }
        totalBytes = total
        guard total > maxTotalBytes else { return }
        var remaining = total
        for entry in measure().sorted(by: { $0.used < $1.used }) where remaining > maxTotalBytes {
            guard (try? fileManager.removeItem(at: entry.file)) != nil else { continue }
            remaining -= entry.size
        }
        totalBytes = remaining
    }

    private func measure() -> [(file: URL, size: Int, used: Date)] {
        let keys: [URLResourceKey] = [.fileSizeKey, .contentModificationDateKey]
        let files = (try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: keys)) ?? []
        return files.compactMap { file in
            guard let values = try? file.resourceValues(forKeys: Set(keys)) else { return nil }
            return (file, values.fileSize ?? 0, values.contentModificationDate ?? .distantPast)
        }
    }

    private func size(of file: URL) -> Int {
        return (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
    }

    /// Marks `file` as just used (written or read).
    private func touch(_ file: URL) {
        try? fileManager.setAttributes([.modificationDate: now()], ofItemAtPath: file.path)
    }

    func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        try? fileManager.removeItem(at: directory)
        totalBytes = nil
    }
}
