//
//  ImageService.swift
//  CometChatSwift
//
//  Created by Abdullah Ansari on 25/04/22.
//  Copyright © 2022 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import AVKit

final class ImageService {
    static var imageCache = NSCache<AnyObject, AnyObject>()

    // MARK: - Public API
    func image(for url: URL, completion: @escaping (UIImage?) -> Void) -> Cancellable {
      
            if let cacheImage = ImageService.imageCache.object(forKey: url as AnyObject) as? UIImage {
                debugPrint("image downloaded from cache...")
                DispatchQueue.main.async {
                completion(cacheImage)
                }
            }
      
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, result, error in
            // Helper
            var image: UIImage?

            defer {
                // Execute Handler on Main Thread
                DispatchQueue.main.async {
                    // Execute Handler
                    if let image = image {
                        ImageService.imageCache.setObject(image, forKey: url as AnyObject)
                        completion(image)
                    }
                }
            }

            if let data = data {
                // Create Image from Data
                image = UIImage(data: data)
            }
        }

        // Resume Data Task
        dataTask.resume()

        return dataTask
    }
    
}
