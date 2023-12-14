//
//  VideoThumbnail.swift
//  CometChatSwift
//
//  Created by admin on 08/12/22.
//  Copyright © 2022 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import AVKit

extension UITableViewCell {
    func createVideoThumbnail( url: URL,  completion: @escaping ((_ image: UIImage?)->Void)) {
     
        DispatchQueue.global().async {
            let request = URLRequest(url: url)
            let cache = URLCache.shared
            
            if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            var time = asset.duration
            time.value = min(time.value, 2)
            
            var image: UIImage?
            
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                image = UIImage(cgImage: cgImage)
            } catch { DispatchQueue.main.async {
                completion(nil)
            } }
            
            if let image = image, let data = image.pngData(), let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedResponse, for: request)
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
