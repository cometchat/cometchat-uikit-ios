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

    // MARK: - Public API

    func image(for url: URL, completion: @escaping (UIImage?) -> Void) -> Cancellable {
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            // Helper
            var image: UIImage?

            defer {
                // Execute Handler on Main Thread
                DispatchQueue.main.async {
                    // Execute Handler
                    completion(image)
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
