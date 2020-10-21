



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation

/// The downloading progress block type.
/// The parameter value is the `receivedSize` of current response.
/// The second parameter is the total expected data length from response's "Content-Length" header.
/// If the expected length is not available, this block will not be called.
 typealias DownloadProgressBlock = ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)

/// Represents the result of a CometChatKingfisher retrieving image task.
 struct RetrieveImageResult {

    /// Gets the image object of this result.
     let image: CFCrossPlatformImage

    /// Gets the cache source of the image. It indicates from which layer of cache this image is retrieved.
    /// If the image is just downloaded from network, `.none` will be returned.
     let cacheType: CacheType

    /// The `Source` which this result is related to. This indicated where the `image` of `self` is referring.
     let source: Source

    /// The original `Source` from which the retrieve task begins. It can be different from the `source` property.
    /// When an alternative source loading happened, the `source` will be the replacing loading target, while the
    /// `originalSource` will be kept as the initial `source` which issued the image loading process.
     let originalSource: Source
}

/// A struct that stores some related information of an `CometChatKingfisherError`. It provides some context information for
/// a pure error so you can identify the error easier.
 struct PropagationError {

    /// The `Source` to which current `error` is bound.
     let source: Source

    /// The actual error happens in framework.
     let error: CometChatKingfisherError
}


/// The downloading task updated block type. The parameter `newTask` is the updated new task of image setting process.
/// It is a `nil` if the image loading does not require an image downloading process. If an image downloading is issued,
/// this value will contain the actual `DownloadTask` for you to keep and cancel it later if you need.
 typealias DownloadTaskUpdatedBlock = ((_ newTask: DownloadTask?) -> Void)

/// Main manager class of CometChatKingfisher. It connects CometChatKingfisher downloader and cache,
/// to provide a set of convenience methods to use CometChatKingfisher for tasks.
/// You can use this class to retrieve an image via a specified URL from web or cache.
@objc   class CometChatKingfisherManager: NSObject {

    /// Represents a shared manager used across CometChatKingfisher.
    /// Use this instance for getting or storing images with CometChatKingfisher.
     static let shared = CometChatKingfisherManager()

    // Mark:  Properties
    /// The `ImageCache` used by this manager. It is `ImageCache.default` by default.
    /// If a cache is specified in `CometChatKingfisherManager.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
     var cache: ImageCache
    
    /// The `ImageDownloader` used by this manager. It is `ImageDownloader.default` by default.
    /// If a downloader is specified in `CometChatKingfisherManager.defaultOptions`, the value in `defaultOptions` will be
    /// used instead.
     var downloader: ImageDownloader
    
    /// Default options used by the manager. This option will be used in
    /// CometChatKingfisher manager related methods, as well as all view extension methods.
    /// You can also passing other options for each image task by sending an `options` parameter
    /// to CometChatKingfisher's APIs. The per image options will overwrite the default ones,
    /// if the option exists in both.
     var defaultOptions = CometChatKingfisherOptionsInfo.empty
    
    // Use `defaultOptions` to overwrite the `downloader` and `cache`.
    private var currentDefaultOptions: CometChatKingfisherOptionsInfo {
        return [.downloader(downloader), .targetCache(cache)] + defaultOptions
    }

    private let processingQueue: CallbackQueue
    
    private convenience override init() {
        self.init(downloader: .default1, cache: .default1)
    }

    /// Creates an image setting manager with specified downloader and cache.
    ///
    /// - Parameters:
    ///   - downloader: The image downloader used to download images.
    ///   - cache: The image cache which stores memory and disk images.
     init(downloader: ImageDownloader, cache: ImageCache) {
        self.downloader = downloader
        self.cache = cache

        let processQueueName = "com.onevcat.CometChatKingfisher.CometChatKingfisherManager.processQueue.\(UUID().uuidString)"
        processingQueue = .dispatch(DispatchQueue(label: processQueueName))
    }

    // MARK: - Getting Images

    /// Gets an image from a given resource.
    /// - Parameters:
    ///   - resource: The `Resource` object defines data information like key or URL.
    ///   - options: Options to use when creating the animated image.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called. `progressBlock` is always called in
    ///                    main queue.
    ///   - downloadTaskUpdated: Called when a new image downloading task is created for current image retrieving. This
    ///                          usually happens when an alternative source is used to replace the original (failed)
    ///                          task. You can update your reference of `DownloadTask` if you want to manually `cancel`
    ///                          the new task.
    ///   - completionHandler: Called when the image retrieved and set finished. This completion handler will be invoked
    ///                        from the `options.callbackQueue`. If not specified, the main queue will be used.
    /// - Returns: A task represents the image downloading. If there is a download task starts for `.network` resource,
    ///            the started `DownloadTask` is returned. Otherwise, `nil` is returned.
    ///
    /// - Note:
    ///    This method will first check whether the requested `resource` is already in cache or not. If cached,
    ///    it returns `nil` and invoke the `completionHandler` after the cached image retrieved. Otherwise, it
    ///    will download the `resource`, store it in cache, then call `completionHandler`.
    @discardableResult
     func retrieveImage(
        with resource: Resource,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        downloadTaskUpdated: DownloadTaskUpdatedBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)?) -> DownloadTask?
    {
        let source = Source.network(resource)
        return retrieveImage(
            with: source,
            options: options,
            progressBlock: progressBlock,
            downloadTaskUpdated: downloadTaskUpdated,
            completionHandler: completionHandler
        )
    }

    /// Gets an image from a given resource.
    ///
    /// - Parameters:
    ///   - source: The `Source` object defines data information from network or a data provider.
    ///   - options: Options to use when creating the animated image.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called. `progressBlock` is always called in
    ///                    main queue.
    ///   - downloadTaskUpdated: Called when a new image downloading task is created for current image retrieving. This
    ///                          usually happens when an alternative source is used to replace the original (failed)
    ///                          task. You can update your reference of `DownloadTask` if you want to manually `cancel`
    ///                          the new task.
    ///   - completionHandler: Called when the image retrieved and set finished. This completion handler will be invoked
    ///                        from the `options.callbackQueue`. If not specified, the main queue will be used.
    /// - Returns: A task represents the image downloading. If there is a download task starts for `.network` resource,
    ///            the started `DownloadTask` is returned. Otherwise, `nil` is returned.
    ///
    /// - Note:
    ///    This method will first check whether the requested `source` is already in cache or not. If cached,
    ///    it returns `nil` and invoke the `completionHandler` after the cached image retrieved. Otherwise, it
    ///    will try to load the `source`, store it in cache, then call `completionHandler`.
    ///
     func retrieveImage(
        with source: Source,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        downloadTaskUpdated: DownloadTaskUpdatedBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)?) -> DownloadTask?
    {
        let options = currentDefaultOptions + (options ?? .empty)
        var info = CometChatKingfisherParsedOptionsInfo(options)
        if let block = progressBlock {
            info.onDataReceived = (info.onDataReceived ?? []) + [ImageLoadingProgressSideEffect(block)]
        }
        return retrieveImage(
            with: source,
            options: info,
            downloadTaskUpdated: downloadTaskUpdated,
            completionHandler: completionHandler)
    }

    func retrieveImage(
        with source: Source,
        options: CometChatKingfisherParsedOptionsInfo,
        downloadTaskUpdated: DownloadTaskUpdatedBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)?) -> DownloadTask?
    {
        var context = RetrievingContext(options: options, originalSource: source)

        func handler(currentSource: Source, result: (Result<RetrieveImageResult, CometChatKingfisherError>)) -> Void {
            switch result {
            case .success:
                completionHandler?(result)
            case .failure(let error):
                // Skip alternative sources if the user cancelled it.
                guard !error.isTaskCancelled else {
                    completionHandler?(.failure(error))
                    return
                }
                if let nextSource = context.popAlternativeSource() {
                    context.appendError(error, to: currentSource)
                    let newTask = self.retrieveImage(with: nextSource, context: context) { result in
                        handler(currentSource: nextSource, result: result)
                    }
                    downloadTaskUpdated?(newTask)
                } else {
                    // No other alternative source. Finish with error.
                    if context.propagationErrors.isEmpty {
                        completionHandler?(.failure(error))
                    } else {
                        context.appendError(error, to: currentSource)
                        let finalError = CometChatKingfisherError.imageSettingError(
                            reason: .alternativeSourcesExhausted(context.propagationErrors)
                        )
                        completionHandler?(.failure(finalError))
                    }
                }
            }
        }

        return retrieveImage(
            with: source,
            context: context)
        {
            result in
            handler(currentSource: source, result: result)
        }

    }
    
    private func retrieveImage(
        with source: Source,
        context: RetrievingContext,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)?) -> DownloadTask?
    {
        let options = context.options
        if options.forceRefresh {
            return loadAndCacheImage(
                source: source,
                context: context,
                completionHandler: completionHandler)?.value
            
        } else {
            let loadedFromCache = retrieveImageFromCache(
                source: source,
                context: context,
                completionHandler: completionHandler)
            
            if loadedFromCache {
                return nil
            }
            
            if options.onlyFromCache {
                let error = CometChatKingfisherError.cacheError(reason: .imageNotExisting(key: source.cacheKey))
                completionHandler?(.failure(error))
                return nil
            }
            
            return loadAndCacheImage(
                source: source,
                context: context,
                completionHandler: completionHandler)?.value
        }
    }

    func provideImage(
        provider: ImageDataProvider,
        options: CometChatKingfisherParsedOptionsInfo,
        completionHandler: ((Result<ImageLoadingResult, CometChatKingfisherError>) -> Void)?)
    {
        guard let  completionHandler = completionHandler else { return }
        provider.data { result in
            switch result {
            case .success(let data):
                (options.processingQueue ?? self.processingQueue).execute {
                    let processor = options.processor
                    let processingItem = ImageProcessItem.data(data)
                    guard let image = processor.process(item: processingItem, options: options) else {
                        options.callbackQueue.execute {
                            let error = CometChatKingfisherError.processorError(
                                reason: .processingFailed(processor: processor, item: processingItem))
                            completionHandler(.failure(error))
                        }
                        return
                    }

                    options.callbackQueue.execute {
                        let result = ImageLoadingResult(image: image, url: nil, originalData: data)
                        completionHandler(.success(result))
                    }
                }
            case .failure(let error):
                options.callbackQueue.execute {
                    let error = CometChatKingfisherError.imageSettingError(
                        reason: .dataProviderError(provider: provider, error: error))
                    completionHandler(.failure(error))
                }

            }
        }
    }

    private func cacheImage(
        source: Source,
        options: CometChatKingfisherParsedOptionsInfo,
        context: RetrievingContext,
        result: Result<ImageLoadingResult, CometChatKingfisherError>,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)?
    )
    {
        switch result {
        case .success(let value):
            let needToCacheOriginalImage = options.cacheOriginalImage &&
                                           options.processor != DefaultImageProcessor.default1
            let coordinator = CacheCallbackCoordinator(
                shouldWaitForCache: options.waitForCache, shouldCacheOriginal: needToCacheOriginalImage)
            // Add image to cache.
            let targetCache = options.targetCache ?? self.cache
            targetCache.store(
                value.image,
                original: value.originalData,
                forKey: source.cacheKey,
                options: options,
                toDisk: !options.cacheMemoryOnly)
            {
                _ in
                coordinator.apply(.cachingImage) {
                    let result = RetrieveImageResult(
                        image: value.image,
                        cacheType: .none,
                        source: source,
                        originalSource: context.originalSource
                    )
                    completionHandler?(.success(result))
                }
            }

            // Add original image to cache if necessary.

            if needToCacheOriginalImage {
                let originalCache = options.originalCache ?? targetCache
                originalCache.storeToDisk(
                    value.originalData,
                    forKey: source.cacheKey,
                    processorIdentifier: DefaultImageProcessor.default1.identifier,
                    expiration: options.diskCacheExpiration)
                {
                    _ in
                    coordinator.apply(.cachingOriginalImage) {
                        let result = RetrieveImageResult(
                            image: value.image,
                            cacheType: .none,
                            source: source,
                            originalSource: context.originalSource
                        )
                        completionHandler?(.success(result))
                    }
                }
            }

            coordinator.apply(.cacheInitiated) {
                let result = RetrieveImageResult(
                    image: value.image,
                    cacheType: .none,
                    source: source,
                    originalSource: context.originalSource
                )
                completionHandler?(.success(result))
            }

        case .failure(let error):
            completionHandler?(.failure(error))
        }
    }

    @discardableResult
    func loadAndCacheImage(
        source: Source,
        context: RetrievingContext,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)?) -> DownloadTask.WrappedTask?
    {
        let options = context.options
        func _cacheImage(_ result: Result<ImageLoadingResult, CometChatKingfisherError>) {
            cacheImage(
                source: source,
                options: options,
                context: context,
                result: result,
                completionHandler: completionHandler
            )
        }

        switch source {
        case .network(let resource):
            let downloader = options.downloader ?? self.downloader
            let task = downloader.downloadImage(
                with: resource.downloadURL, options: options, completionHandler: _cacheImage
            )
            return task.map(DownloadTask.WrappedTask.download)

        case .provider(let provider):
            provideImage(provider: provider, options: options, completionHandler: _cacheImage)
            return .dataProviding
        }
    }
    
    /// Retrieves image from memory or disk cache.
    ///
    /// - Parameters:
    ///   - source: The target source from which to get image.
    ///   - key: The key to use when caching the image.
    ///   - url: Image request URL. This is not used when retrieving image from cache. It is just used for
    ///          `RetrieveImageResult` callback compatibility.
    ///   - options: Options on how to get the image from image cache.
    ///   - completionHandler: Called when the image retrieving finishes, either with succeeded
    ///                        `RetrieveImageResult` or an error.
    /// - Returns: `true` if the requested image or the original image before being processed is existing in cache.
    ///            Otherwise, this method returns `false`.
    ///
    /// - Note:
    ///    The image retrieving could happen in either memory cache or disk cache. The `.processor` option in
    ///    `options` will be considered when searching in the cache. If no processed image is found, CometChatKingfisher
    ///    will try to check whether an original version of that image is existing or not. If there is already an
    ///    original, CometChatKingfisher retrieves it from cache and processes it. Then, the processed image will be store
    ///    back to cache for later use.
    func retrieveImageFromCache(
        source: Source,
        context: RetrievingContext,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)?) -> Bool
    {
        let options = context.options
        // 1. Check whether the image was already in target cache. If so, just get it.
        let targetCache = options.targetCache ?? cache
        let key = source.cacheKey
        let targetImageCached = targetCache.imageCachedType(
            forKey: key, processorIdentifier: options.processor.identifier)
        
        let validCache = targetImageCached.cached &&
            (options.fromMemoryCacheOrRefresh == false || targetImageCached == .memory)
        if validCache {
            targetCache.retrieveImage(forKey: key, options: options) { result in
                guard let completionHandler = completionHandler else { return }
                options.callbackQueue.execute {
                    result.match(
                        onSuccess: { cacheResult in
                            let value: Result<RetrieveImageResult, CometChatKingfisherError>
                            if let image = cacheResult.image {
                                value = result.map {
                                    RetrieveImageResult(
                                        image: image,
                                        cacheType: $0.cacheType,
                                        source: source,
                                        originalSource: context.originalSource
                                    )
                                }
                            } else {
                                value = .failure(CometChatKingfisherError.cacheError(reason: .imageNotExisting(key: key)))
                            }
                            completionHandler(value)
                        },
                        onFailure: { _ in
                            completionHandler(.failure(CometChatKingfisherError.cacheError(reason: .imageNotExisting(key: key))))
                        }
                    )
                }
            }
            return true
        }

        // 2. Check whether the original image exists. If so, get it, process it, save to storage and return.
        let originalCache = options.originalCache ?? targetCache
        // No need to store the same file in the same cache again.
        if originalCache === targetCache && options.processor == DefaultImageProcessor.default1 {
            return false
        }

        // Check whether the unprocessed image existing or not.
        let originalImageCacheType = originalCache.imageCachedType(
            forKey: key, processorIdentifier: DefaultImageProcessor.default1.identifier)
        let canAcceptDiskCache = !options.fromMemoryCacheOrRefresh
        
        let canUseOriginalImageCache =
            (canAcceptDiskCache && originalImageCacheType.cached) ||
            (!canAcceptDiskCache && originalImageCacheType == .memory)
        
        if canUseOriginalImageCache {
            // Now we are ready to get found the original image from cache. We need the unprocessed image, so remove
            // any processor from options first.
            var optionsWithoutProcessor = options
            optionsWithoutProcessor.processor = DefaultImageProcessor.default1
            originalCache.retrieveImage(forKey: key, options: optionsWithoutProcessor) { result in

                result.match(
                    onSuccess: { cacheResult in
                        guard let image = cacheResult.image else {
                            assertionFailure("The image (under key: \(key) should be existing in the original cache.")
                            return
                        }

                        let processor = options.processor
                        (options.processingQueue ?? self.processingQueue).execute {
                            let item = ImageProcessItem.image(image)
                            guard let processedImage = processor.process(item: item, options: options) else {
                                let error = CometChatKingfisherError.processorError(
                                    reason: .processingFailed(processor: processor, item: item))
                                options.callbackQueue.execute { completionHandler?(.failure(error)) }
                                return
                            }

                            var cacheOptions = options
                            cacheOptions.callbackQueue = .untouch

                            let coordinator = CacheCallbackCoordinator(
                                shouldWaitForCache: options.waitForCache, shouldCacheOriginal: false)

                            targetCache.store(
                                processedImage,
                                forKey: key,
                                options: cacheOptions,
                                toDisk: !options.cacheMemoryOnly)
                            {
                                _ in
                                coordinator.apply(.cachingImage) {
                                    let value = RetrieveImageResult(
                                        image: processedImage,
                                        cacheType: .none,
                                        source: source,
                                        originalSource: context.originalSource
                                    )
                                    options.callbackQueue.execute { completionHandler?(.success(value)) }
                                }
                            }

                            coordinator.apply(.cacheInitiated) {
                                let value = RetrieveImageResult(
                                    image: processedImage,
                                    cacheType: .none,
                                    source: source,
                                    originalSource: context.originalSource
                                )
                                options.callbackQueue.execute { completionHandler?(.success(value)) }
                            }
                        }
                    },
                    onFailure: { _ in
                        // This should not happen actually, since we already confirmed `originalImageCached` is `true`.
                        // Just in case...
                        options.callbackQueue.execute {
                            completionHandler?(
                                .failure(CometChatKingfisherError.cacheError(reason: .imageNotExisting(key: key)))
                            )
                        }
                    }
                )
            }
            return true
        }

        return false
    }
}

struct RetrievingContext {

    var options: CometChatKingfisherParsedOptionsInfo

    let originalSource: Source
    var propagationErrors: [PropagationError] = []

    init(options: CometChatKingfisherParsedOptionsInfo, originalSource: Source) {
        self.originalSource = originalSource
        self.options = options
    }

    mutating func popAlternativeSource() -> Source? {
        guard var alternativeSources = options.alternativeSources, !alternativeSources.isEmpty else {
            return nil
        }
        let nextSource = alternativeSources.removeFirst()
        options.alternativeSources = alternativeSources
        return nextSource
    }

    @discardableResult
    mutating func appendError(_ error: CometChatKingfisherError, to source: Source) -> [PropagationError] {
        let item = PropagationError(source: source, error: error)
        propagationErrors.append(item)
        return propagationErrors
    }
}

class CacheCallbackCoordinator {

    enum State {
        case idle
        case imageCached
        case originalImageCached
        case done
    }

    enum Action {
        case cacheInitiated
        case cachingImage
        case cachingOriginalImage
    }

    private let shouldWaitForCache: Bool
    private let shouldCacheOriginal: Bool

    private (set) var state: State = .idle

    init(shouldWaitForCache: Bool, shouldCacheOriginal: Bool) {
        self.shouldWaitForCache = shouldWaitForCache
        self.shouldCacheOriginal = shouldCacheOriginal
    }

    func apply(_ action: Action, trigger: () -> Void) {
        switch (state, action) {
        case (.done, _):
            break

        // From .idle
        case (.idle, .cacheInitiated):
            if !shouldWaitForCache {
                state = .done
                trigger()
            }
        case (.idle, .cachingImage):
            if shouldCacheOriginal {
                state = .imageCached
            } else {
                state = .done
                trigger()
            }
        case (.idle, .cachingOriginalImage):
            state = .originalImageCached

        // From .imageCached
        case (.imageCached, .cachingOriginalImage):
            state = .done
            trigger()

        // From .originalImageCached
        case (.originalImageCached, .cachingImage):
            state = .done
            trigger()

        default:
            assertionFailure("This case should not happen in CacheCallbackCoordinator: \(state) - \(action)")
        }
    }
}
