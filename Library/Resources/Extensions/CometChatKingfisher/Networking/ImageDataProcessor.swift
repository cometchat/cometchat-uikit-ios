



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation

private let sharedProcessingQueue: CallbackQueue =
    .dispatch(DispatchQueue(label: "com.onevcat.CometChatKingfisher.ImageDownloader.Process"))

// Handles image processing work on an own process queue.
class ImageDataProcessor {
    let data: Data
    let callbacks: [SessionDataTask.TaskCallback]
    let queue: CallbackQueue

    // Note: We have an optimization choice there, to reduce queue dispatch by checking callback
    // queue settings in each option...
    let onImageProcessed = Delegate<(Result<CFCrossPlatformImage, CometChatKingfisherError>, SessionDataTask.TaskCallback), Void>()

    init(data: Data, callbacks: [SessionDataTask.TaskCallback], processingQueue: CallbackQueue?) {
        self.data = data
        self.callbacks = callbacks
        self.queue = processingQueue ?? sharedProcessingQueue
    }

    func process() {
        queue.execute(doProcess)
    }

    private func doProcess() {
        var processedImages = [String: CFCrossPlatformImage]()
        for callback in callbacks {
            let processor = callback.options.processor
            var image = processedImages[processor.identifier]
            if image == nil {
                image = processor.process(item: .data(data), options: callback.options)
                processedImages[processor.identifier] = image
            }

            let result: Result<CFCrossPlatformImage, CometChatKingfisherError>
            if let image = image {
                var finalImage = image
                if let imageModifier = callback.options.imageModifier {
                    finalImage = imageModifier.modify(image)
                }
                if callback.options.backgroundDecode {
                    finalImage = finalImage.cf.decoded
                }
                result = .success(finalImage)
            } else {
                let error = CometChatKingfisherError.processorError(
                    reason: .processingFailed(processor: processor, item: .data(data)))
                result = .failure(error)
            }
            onImageProcessed.call((result, callback))
        }
    }
}
