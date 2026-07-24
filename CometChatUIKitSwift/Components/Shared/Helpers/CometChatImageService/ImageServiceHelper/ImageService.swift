//
//  ImageService.swift
//  CometChatSwift
//
//  Created by Abdullah Ansari on 25/04/22.
//  Copyright © 2022 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

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
    func image(for url: URL, cacheType: CacheType, completion: @escaping (UIImage?) -> Void) -> Cancellable {
        
        var task = URLSession.shared.dataTask(with: url)
        if cacheType == .avatar, let cacheImage = ImageService.avatarCache.object(forKey: url as AnyObject) as? UIImage {
            DispatchQueue.main.async { [weak cacheImage] in
                completion(cacheImage)
            }
        } else if cacheType == .normal, let cacheImage = ImageService.imageCache.object(forKey: url as AnyObject) as? UIImage {
            DispatchQueue.main.async {
                completion(cacheImage)
            }
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
