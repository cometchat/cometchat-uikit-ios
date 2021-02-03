



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


#if canImport(WatchKit)

import WatchKit

extension CometChatKingfisherWrapper where Base: WKInterfaceImage {

    // MARK: Setting Image

    /// Sets an image to the image view with a source.
    ///
    /// - Parameters:
    ///   - source: The `Source` object contains information about the image.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `CometChatKingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    ///
    /// Internally, this method will use `CometChatKingfisherManager` to get the requested source
    /// Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
     func setImage(
        with source: Source?,
        placeholder: CFCrossPlatformImage? = nil,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        var mutatingSelf = self
        guard let source = source else {
            base.setImage(placeholder)
            mutatingSelf.taskIdentifier = nil
            completionHandler?(.failure(CometChatKingfisherError.imageSettingError(reason: .emptySource)))
            return nil
        }
        
        var options = CometChatKingfisherParsedOptionsInfo(CometChatKingfisherManager.shared.defaultOptions + (options ?? .empty))
        if !options.keepCurrentImageWhileLoading {
            base.setImage(placeholder)
        }
        
        let issuedIdentifier = Source.Identifier.next()
        mutatingSelf.taskIdentifier = issuedIdentifier
        
        if let block = progressBlock {
            options.onDataReceived = (options.onDataReceived ?? []) + [ImageLoadingProgressSideEffect(block)]
        }
        
        if let provider = ImageProgressiveProvider(options, refresh: { image in
            self.base.setImage(image)
        }) {
            options.onDataReceived = (options.onDataReceived ?? []) + [provider]
        }
        
        options.onDataReceived?.forEach {
            $0.onShouldApply = { issuedIdentifier == self.taskIdentifier }
        }
        
        let task = CometChatKingfisherManager.shared.retrieveImage(
            with: source,
            options: options,
            downloadTaskUpdated: { mutatingSelf.imageTask = $0 },
            completionHandler: { result in
                CallbackQueue.mainCurrentOrAsync.execute {
                    guard issuedIdentifier == self.taskIdentifier else {
                        let reason: CometChatKingfisherError.ImageSettingErrorReason
                        do {
                            let value = try result.get()
                            reason = .notCurrentSourceTask(result: value, error: nil, source: source)
                        } catch {
                            reason = .notCurrentSourceTask(result: nil, error: error, source: source)
                        }
                        let error = CometChatKingfisherError.imageSettingError(reason: reason)
                        completionHandler?(.failure(error))
                        return
                    }
                    
                    mutatingSelf.imageTask = nil
                    mutatingSelf.taskIdentifier = nil
                    
                    switch result {
                    case .success(let value):
                        self.base.setImage(value.image)
                        completionHandler?(result)
                        
                    case .failure:
                        if let image = options.onFailureImage {
                            self.base.setImage(image)
                        }
                        completionHandler?(result)
                    }
                }
            }
        )
        
        mutatingSelf.imageTask = task
        return task
    }
    
    /// Sets an image to the image view with a requested resource.
    ///
    /// - Parameters:
    ///   - resource: The `Resource` object contains information about the image.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `CometChatKingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    ///
    /// Internally, this method will use `CometChatKingfisherManager` to get the requested resource, from either cache
    /// or network. Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
     func setImage(
        with resource: Resource?,
        placeholder: CFCrossPlatformImage? = nil,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        return setImage(
            with: resource.map { .network($0) },
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler)
    }

    // MARK: Cancelling Image

    /// Cancel the image download task bounded to the image view if it is running.
    /// Nothing will happen if the downloading has already finished.
     func cancelDownloadTask() {
        imageTask?.cancel()
    }
}

private var taskIdentifierKey: Void?
private var imageTaskKey: Void?

// MARK: Properties
extension CometChatKingfisherWrapper where Base: WKInterfaceImage {
    
     private(set) var taskIdentifier: Source.Identifier.Value? {
        get {
            let box: Box<Source.Identifier.Value>? = getAssociatedObject(base, &taskIdentifierKey)
            return box?.value
        }
        set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(base, &taskIdentifierKey, box)
        }
    }

    private var imageTask: DownloadTask? {
        get { return getAssociatedObject(base, &imageTaskKey) }
        set { setRetainedAssociatedObject(base, &imageTaskKey, newValue)}
    }
}

extension CometChatKingfisherWrapper where Base: WKInterfaceImage {
    /// Gets the image URL bound to this image view.
    @available(*, deprecated, message: "Use `taskIdentifier` instead to identify a setting task.")
     private(set) var webURL: URL? {
        get { return nil }
        set { }
    }
}

#endif
