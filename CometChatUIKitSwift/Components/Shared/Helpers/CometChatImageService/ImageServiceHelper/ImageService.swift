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
            DispatchQueue.main.async { [weak cacheImage] in 
                completion(cacheImage)
            }
        } else {
            
            let dataTask = URLSession.shared.dataTask(with: url) { data, result, error in
                // Helper
                var image: UIImage?
                
                defer {
                    // Execute Handler on Main Thread
                    DispatchQueue.main.async {
                        // Execute Handler
                        if let image = image {
                            if cacheType == .avatar {
                                ImageService.avatarCache.setObject(image, forKey: url as AnyObject)
                            } else if cacheType == .normal {
                                ImageService.imageCache.setObject(image, forKey: url as AnyObject)
                            }
                            completion(image)
                        }else{
                            completion(nil)
                        }
                    }
                }
                
                if let data = data {
                    // Create Image from Data
                    image = UIImage(data: data)
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
    
}
