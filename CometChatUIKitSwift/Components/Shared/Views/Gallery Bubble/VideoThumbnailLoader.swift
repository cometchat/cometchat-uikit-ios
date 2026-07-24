//
//  VideoThumbnailLoader.swift
//  CometChatUIKitSwift
//
//  Best-effort first-frame thumbnail generation for video attachments shown in
//  the gallery bubble. Generated frames are cached in memory keyed by URL.
//

import UIKit
import AVFoundation

enum VideoThumbnailLoader {

    private static let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100
        return cache
    }()

    /// Generates (or returns a cached) thumbnail for the given video URL.
    /// The completion is always invoked on the main thread.
    static func thumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cached = cache.object(forKey: url as NSURL) {
            DispatchQueue.main.async { completion(cached) }
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVURLAsset(url: url)
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 600, height: 600)

            let time = CMTime(seconds: 1, preferredTimescale: 60)
            var image: UIImage?
            if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                image = UIImage(cgImage: cgImage)
            }

            if let image {
                cache.setObject(image, forKey: url as NSURL)
            }

            DispatchQueue.main.async { completion(image) }
        }
    }

    /// Like `thumbnail(for:)` but also returns a formatted duration string ("m:ss")
    /// when the asset's duration can be read. Completion runs on the main thread.
    static func thumbnailAndDuration(for url: URL, completion: @escaping (UIImage?, String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVURLAsset(url: url)

            var image: UIImage? = cache.object(forKey: url as NSURL)
            if image == nil {
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.maximumSize = CGSize(width: 600, height: 600)
                let time = CMTime(seconds: 1, preferredTimescale: 60)
                if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
                    let made = UIImage(cgImage: cgImage)
                    cache.setObject(made, forKey: url as NSURL)
                    image = made
                }
            }

            let seconds = CMTimeGetSeconds(asset.duration)
            let duration: String? = (seconds.isFinite && seconds > 0) ? formatDuration(seconds) : nil

            DispatchQueue.main.async { completion(image, duration) }
        }
    }

    private static func formatDuration(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
