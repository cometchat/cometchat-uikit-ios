



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

// MARK: - Deprecated
extension CometChatKingfisherWrapper where Base: CFCrossPlatformImage {
    @available(*, deprecated, message:
    "Will be removed soon. Pass parameters with `ImageCreatingOptions`, use `image(with:options:)` instead.")
     static func image(
        data: Data,
        scale: CGFloat,
        preloadAllAnimationData: Bool,
        onlyFirstFrame: Bool) -> CFCrossPlatformImage?
    {
        let options = ImageCreatingOptions(
            scale: scale,
            duration: 0.0,
            preloadAll: preloadAllAnimationData,
            onlyFirstFrame: onlyFirstFrame)
        return CometChatKingfisherWrapper.image(data: data, options: options)
    }
    
    @available(*, deprecated, message:
    "Will be removed soon. Pass parameters with `ImageCreatingOptions`, use `animatedImage(with:options:)` instead.")
     static func animated(
        with data: Data,
        scale: CGFloat = 1.0,
        duration: TimeInterval = 0.0,
        preloadAll: Bool,
        onlyFirstFrame: Bool = false) -> CFCrossPlatformImage?
    {
        let options = ImageCreatingOptions(
            scale: scale, duration: duration, preloadAll: preloadAll, onlyFirstFrame: onlyFirstFrame)
        return animatedImage(data: data, options: options)
    }
}

@available(*, deprecated, message: "Will be removed soon. Use `Result<RetrieveImageResult>` based callback instead")
 typealias CompletionHandler =
    ((_ image: CFCrossPlatformImage?, _ error: NSError?, _ cacheType: CacheType, _ imageURL: URL?) -> Void)

@available(*, deprecated, message: "Will be removed soon. Use `Result<ImageLoadingResult>` based callback instead")
 typealias ImageDownloaderCompletionHandler =
    ((_ image: CFCrossPlatformImage?, _ error: NSError?, _ url: URL?, _ originalData: Data?) -> Void)

// MARK: - Deprecated
@available(*, deprecated, message: "Will be removed soon. Use `DownloadTask` to cancel a task.")
extension RetrieveImageTask {
    @available(*, deprecated, message: "RetrieveImageTask.empty will be removed soon. Use `nil` to represent a no task.")
     static let empty = RetrieveImageTask()
}

// MARK: - Deprecated
extension CometChatKingfisherManager {
    /// Get an image with resource.
    /// If `.empty` is used as `options`, CometChatKingfisher will seek the image in memory and disk first.
    /// If not found, it will download the image at `resource.downloadURL` and cache it with `resource.cacheKey`.
    /// These default behaviors could be adjusted by passing different options. See `CometChatKingfisherOptions` for more.
    ///
    /// - Parameters:
    ///   - resource: Resource object contains information such as `cacheKey` and `downloadURL`.
    ///   - options: A dictionary could control some behaviors. See `CometChatKingfisherOptionsInfo` for more.
    ///   - progressBlock: Called every time downloaded data changed. This could be used as a progress UI.
    ///   - completionHandler: Called when the whole retrieving process finished.
    /// - Returns: A `RetrieveImageTask` task object. You can use this object to cancel the task.
    @available(*, deprecated, message: "Use `Result` based callback instead.")
    @discardableResult
     func retrieveImage(with resource: Resource,
                              options: CometChatKingfisherOptionsInfo?,
                              progressBlock: DownloadProgressBlock?,
                              completionHandler: CompletionHandler?) -> DownloadTask?
    {
        return retrieveImage(with: resource, options: options, progressBlock: progressBlock) {
            result in
            switch result {
            case .success(let value): completionHandler?(value.image, nil, value.cacheType, value.source.url)
            case .failure(let error): completionHandler?(nil, error as NSError, .none, resource.downloadURL)
            }
        }
    }
}

// MARK: - Deprecated
extension ImageDownloader {
    @available(*, deprecated, message: "Use `Result` based callback instead.")
    @discardableResult
     func downloadImage(with url: URL,
                            retrieveImageTask: RetrieveImageTask? = nil,
                            options: CometChatKingfisherOptionsInfo? = nil,
                            progressBlock: ImageDownloaderProgressBlock? = nil,
                            completionHandler: ImageDownloaderCompletionHandler?) -> DownloadTask?
    {
        return downloadImage(with: url, options: options, progressBlock: progressBlock) {
            result in
            switch result {
            case .success(let value): completionHandler?(value.image, nil, value.url, value.originalData)
            case .failure(let error): completionHandler?(nil, error as NSError, nil, nil)
            }
        }
    }
}

@available(*, deprecated, message: "RetrieveImageDownloadTask is removed. Use `DownloadTask` to cancel a task.")
 struct RetrieveImageDownloadTask {
}

@available(*, deprecated, message: "RetrieveImageTask is removed. Use `DownloadTask` to cancel a task.")
 final class RetrieveImageTask {
}

@available(*, deprecated, message: "Use `DownloadProgressBlock` instead.", renamed: "DownloadProgressBlock")
 typealias ImageDownloaderProgressBlock = DownloadProgressBlock

#if !os(watchOS)
// MARK: - Deprecated
extension CometChatKingfisherWrapper where Base: CFCrossPlatformImageView {
    @available(*, deprecated, message: "Use `Result` based callback instead.")
    @discardableResult
     func setImage(with resource: Resource?,
                         placeholder: Placeholder? = nil,
                         options: CometChatKingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: CompletionHandler?) -> DownloadTask?
    {
        return setImage(with: resource, placeholder: placeholder, options: options, progressBlock: progressBlock) {
            result in
            switch result {
            case .success(let value):
                completionHandler?(value.image, nil, value.cacheType, value.source.url)
            case .failure(let error):
                completionHandler?(nil, error as NSError, .none, nil)
            }
        }
    }
}
#endif

#if  !os(watchOS)
// MARK: - Deprecated
extension CometChatKingfisherWrapper where Base: UIButton {
    @available(*, deprecated, message: "Use `Result` based callback instead.")
    @discardableResult
     func setImage(
        with resource: Resource?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: CompletionHandler?) -> DownloadTask?
    {
        return setImage(
            with: resource,
            for: state,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock)
        {
            result in
            switch result {
            case .success(let value):
                completionHandler?(value.image, nil, value.cacheType, value.source.url)
            case .failure(let error):
                completionHandler?(nil, error as NSError, .none, nil)
            }
        }
    }
    
    @available(*, deprecated, message: "Use `Result` based callback instead.")
    @discardableResult
     func setBackgroundImage(
        with resource: Resource?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: CompletionHandler?) -> DownloadTask?
    {
        return setBackgroundImage(
            with: resource,
            for: state,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock)
        {
            result in
            switch result {
            case .success(let value):
                completionHandler?(value.image, nil, value.cacheType, value.source.url)
            case .failure(let error):
                completionHandler?(nil, error as NSError, .none, nil)
            }
        }
    }
}
#endif

#if os(watchOS)
import WatchKit
// MARK: - Deprecated
extension CometChatKingfisherWrapper where Base: WKInterfaceImage {
    @available(*, deprecated, message: "Use `Result` based callback instead.")
    @discardableResult
     func setImage(_ resource: Resource?,
                         placeholder: CFCrossPlatformImage? = nil,
                         options: CometChatKingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: CompletionHandler?) -> DownloadTask?
    {
        return setImage(
            with: resource,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock)
        {
            result in
            switch result {
            case .success(let value):
                completionHandler?(value.image, nil, value.cacheType, value.source.url)
            case .failure(let error):
                completionHandler?(nil, error as NSError, .none, nil)
            }
        }
    }
}
#endif

#if os(macOS)
// MARK: - Deprecated
extension CometChatKingfisherWrapper where Base: NSButton {
    @discardableResult
    @available(*, deprecated, message: "Use `Result` based callback instead.")
     func setImage(with resource: Resource?,
                         placeholder: CFCrossPlatformImage? = nil,
                         options: CometChatKingfisherOptionsInfo? = nil,
                         progressBlock: DownloadProgressBlock? = nil,
                         completionHandler: CompletionHandler?) -> DownloadTask?
    {
        return setImage(
            with: resource,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock)
        {
            result in
            switch result {
            case .success(let value):
                completionHandler?(value.image, nil, value.cacheType, value.source.url)
            case .failure(let error):
                completionHandler?(nil, error as NSError, .none, nil)
            }
        }
    }
    
    @discardableResult
    @available(*, deprecated, message: "Use `Result` based callback instead.")
     func setAlternateImage(with resource: Resource?,
                                  placeholder: CFCrossPlatformImage? = nil,
                                  options: CometChatKingfisherOptionsInfo? = nil,
                                  progressBlock: DownloadProgressBlock? = nil,
                                  completionHandler: CompletionHandler?) -> DownloadTask?
    {
        return setAlternateImage(
            with: resource,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock)
        {
            result in
            switch result {
            case .success(let value):
                completionHandler?(value.image, nil, value.cacheType, value.source.url)
            case .failure(let error):
                completionHandler?(nil, error as NSError, .none, nil)
            }
        }
    }
}
#endif

// MARK: - Deprecated
extension ImageCache {
    /// The largest cache cost of memory cache. The total cost is pixel count of
    /// all cached images in memory.
    /// Default is unlimited. Memory cache will be purged automatically when a
    /// memory warning notification is received.
    @available(*, deprecated, message: "Use `memoryStorage.config.totalCostLimit` instead.",
    renamed: "memoryStorage.config.totalCostLimit")
    open var maxMemoryCost: Int {
        get { return memoryStorage.config.totalCostLimit }
        set { memoryStorage.config.totalCostLimit = newValue }
    }

    /// The default DiskCachePathClosure
    @available(*, deprecated, message: "Not needed anymore.")
     final class func defaultDiskCachePathClosure(path: String?, cacheName: String) -> String {
        let dstPath = path ?? NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        return (dstPath as NSString).appendingPathComponent(cacheName)
    }

    /// The default file extension appended to cached files.
    @available(*, deprecated, message: "Use `diskStorage.config.pathExtension` instead.",
    renamed: "diskStorage.config.pathExtension")
    open var pathExtension: String? {
        get { return diskStorage.config.pathExtension }
        set { diskStorage.config.pathExtension = newValue }
    }
    
    ///The disk cache location.
    @available(*, deprecated, message: "Use `diskStorage.directoryURL.absoluteString` instead.",
    renamed: "diskStorage.directoryURL.absoluteString")
     var diskCachePath: String {
        return diskStorage.directoryURL.absoluteString
    }
    
    /// The largest disk size can be taken for the cache. It is the total
    /// allocated size of cached files in bytes.
    /// Default is no limit.
    @available(*, deprecated, message: "Use `diskStorage.config.sizeLimit` instead.",
    renamed: "diskStorage.config.sizeLimit")
    open var maxDiskCacheSize: UInt {
        get { return UInt(diskStorage.config.sizeLimit) }
        set { diskStorage.config.sizeLimit = newValue }
    }
    
    @available(*, deprecated, message: "Use `diskStorage.cacheFileURL(forKey:).path` instead.",
    renamed: "diskStorage.cacheFileURL(forKey:)")
    open func cachePath(forComputedKey key: String) -> String {
        return diskStorage.cacheFileURL(forKey: key).path
    }
    
    /**
     Get an image for a key from disk.
     
     - parameter key:     Key for the image.
     - parameter options: Options of retrieving image. If you need to retrieve an image which was
     stored with a specified `ImageProcessor`, pass the processor in the option too.
     
     - returns: The image object if it is cached, or `nil` if there is no such key in the cache.
     */
    @available(*, deprecated,
    message: "Use `Result` based `retrieveImageInDiskCache(forKey:options:callbackQueue:completionHandler:)` instead.",
    renamed: "retrieveImageInDiskCache(forKey:options:callbackQueue:completionHandler:)")
    open func retrieveImageInDiskCache(forKey key: String, options: CometChatKingfisherOptionsInfo? = nil) -> CFCrossPlatformImage? {
        let options = CometChatKingfisherParsedOptionsInfo(options ?? .empty)
        let computedKey = key.computedKey(with: options.processor.identifier)
        do {
            if let data = try diskStorage.value(forKey: computedKey, extendingExpiration: options.diskCacheAccessExtendingExpiration) {
                return options.cacheSerializer.image(with: data, options: options)
            }
        } catch {}
        return nil
    }

    @available(*, deprecated,
    message: "Use `Result` based `retrieveImage(forKey:options:callbackQueue:completionHandler:)` instead.",
    renamed: "retrieveImage(forKey:options:callbackQueue:completionHandler:)")
    open func retrieveImage(forKey key: String,
                            options: CometChatKingfisherOptionsInfo?,
                            completionHandler: ((CFCrossPlatformImage?, CacheType) -> Void)?)
    {
        retrieveImage(
            forKey: key,
            options: options,
            callbackQueue: .dispatch((options ?? .empty).callbackDispatchQueue))
        {
            result in
            do {
                let value = try result.get()
                completionHandler?(value.image, value.cacheType)
            } catch {
                completionHandler?(nil, .none)
            }
        }
    }

    /// The longest time duration in second of the cache being stored in disk.
    /// Default is 1 week (60 * 60 * 24 * 7 seconds).
    /// Setting this to a negative value will make the disk cache never expiring.
    @available(*, deprecated, message: "Deprecated. Use `diskStorage.config.expiration` instead")
    open var maxCachePeriodInSecond: TimeInterval {
        get { return diskStorage.config.expiration.timeInterval }
        set { diskStorage.config.expiration = newValue < 0 ? .never : .seconds(newValue) }
    }

    @available(*, deprecated, message: "Use `Result` based callback instead.")
    open func store(_ image: CFCrossPlatformImage,
                    original: Data? = nil,
                    forKey key: String,
                    processorIdentifier identifier: String = "",
                    cacheSerializer serializer: CacheSerializer = DefaultCacheSerializer.default1,
                    toDisk: Bool = true,
                    completionHandler: (() -> Void)?)
    {
        store(
            image,
            original: original,
            forKey: key,
            processorIdentifier: identifier,
            cacheSerializer: serializer,
            toDisk: toDisk)
        {
            _ in
            completionHandler?()
        }
    }

    @available(*, deprecated, message: "Use the `Result`-based `calculateDiskStorageSize` instead.")
    open func calculateDiskCacheSize(completion handler: @escaping ((_ size: UInt) -> Void)) {
        calculateDiskStorageSize { result in
            let size: UInt? = try? result.get()
            handler(size ?? 0)
        }
    }
}

// MARK: - Deprecated
extension Collection where Iterator.Element == CometChatKingfisherOptionsInfoItem {
    /// The queue of callbacks should happen from CometChatKingfisher.
    @available(*, deprecated, message: "Use `callbackQueue` instead.", renamed: "callbackQueue")
     var callbackDispatchQueue: DispatchQueue {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).callbackQueue.queue
    }
}

/// Error domain of CometChatKingfisher
@available(*, deprecated, message: "Use `CometChatKingfisherError.domain` instead.", renamed: "CometChatKingfisherError.domain")
 let CometChatKingfisherErrorDomain = "com.onevcat.CometChatKingfisher.Error"

/// Key will be used in the `userInfo` of `.invalidStatusCode`
@available(*, unavailable,
message: "Use `.invalidHTTPStatusCode` or `isInvalidResponseStatusCode` of `CometChatKingfisherError` instead for the status code.")
 let CometChatKingfisherErrorStatusCodeKey = "statusCode"

// MARK: - Deprecated
extension Collection where Iterator.Element == CometChatKingfisherOptionsInfoItem {
    /// The target `ImageCache` which is used.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `targetCache` instead.")
     var targetCache: ImageCache? {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).targetCache
    }

    /// The original `ImageCache` which is used.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `originalCache` instead.")
     var originalCache: ImageCache? {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).originalCache
    }

    /// The `ImageDownloader` which is specified.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `downloader` instead.")
     var downloader: ImageDownloader? {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).downloader
    }

    /// Member for animation transition when using UIImageView.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `transition` instead.")
     var transition: ImageTransition {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).transition
    }

    /// A `Float` value set as the priority of image download task. The value for it should be
    /// between 0.0~1.0.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `downloadPriority` instead.")
     var downloadPriority: Float {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).downloadPriority
    }

    /// Whether an image will be always downloaded again or not.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `forceRefresh` instead.")
     var forceRefresh: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).forceRefresh
    }

    /// Whether an image should be got only from memory cache or download.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `fromMemoryCacheOrRefresh` instead.")
     var fromMemoryCacheOrRefresh: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).fromMemoryCacheOrRefresh
    }

    /// Whether the transition should always happen or not.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `forceTransition` instead.")
     var forceTransition: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).forceTransition
    }

    /// Whether cache the image only in memory or not.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `cacheMemoryOnly` instead.")
     var cacheMemoryOnly: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).cacheMemoryOnly
    }

    /// Whether the caching operation will be waited or not.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `waitForCache` instead.")
     var waitForCache: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).waitForCache
    }

    /// Whether only load the images from cache or not.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `onlyFromCache` instead.")
     var onlyFromCache: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).onlyFromCache
    }

    /// Whether the image should be decoded in background or not.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `backgroundDecode` instead.")
     var backgroundDecode: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).backgroundDecode
    }

    /// Whether the image data should be all loaded at once if it is an animated image.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `preloadAllAnimationData` instead.")
     var preloadAllAnimationData: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).preloadAllAnimationData
    }

    /// The `CallbackQueue` on which completion handler should be invoked.
    /// If not set in the options, `.mainCurrentOrAsync` will be used.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `callbackQueue` instead.")
     var callbackQueue: CallbackQueue {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).callbackQueue
    }

    /// The scale factor which should be used for the image.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `scaleFactor` instead.")
     var scaleFactor: CGFloat {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).scaleFactor
    }

    /// The `ImageDownloadRequestModifier` will be used before sending a download request.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `requestModifier` instead.")
     var modifier: ImageDownloadRequestModifier? {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).requestModifier
    }

    /// `ImageProcessor` for processing when the downloading finishes.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `processor` instead.")
     var processor: ImageProcessor {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).processor
    }

    /// `ImageModifier` for modifying right before the image is displayed.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `imageModifier` instead.")
     var imageModifier: ImageModifier? {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).imageModifier
    }

    /// `CacheSerializer` to convert image to data for storing in cache.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `cacheSerializer` instead.")
     var cacheSerializer: CacheSerializer {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).cacheSerializer
    }

    /// Keep the existing image while setting another image to an image view.
    /// Or the placeholder will be used while downloading.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `keepCurrentImageWhileLoading` instead.")
     var keepCurrentImageWhileLoading: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).keepCurrentImageWhileLoading
    }

    /// Whether the options contains `.onlyLoadFirstFrame`.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `onlyLoadFirstFrame` instead.")
     var onlyLoadFirstFrame: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).onlyLoadFirstFrame
    }

    /// Whether the options contains `.cacheOriginalImage`.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `cacheOriginalImage` instead.")
     var cacheOriginalImage: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).cacheOriginalImage
    }

    /// The image which should be used when download image request fails.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `onFailureImage` instead.")
     var onFailureImage: Optional<CFCrossPlatformImage?> {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).onFailureImage
    }

    /// Whether the `ImagePrefetcher` should load images to memory in an aggressive way or not.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `alsoPrefetchToMemory` instead.")
     var alsoPrefetchToMemory: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).alsoPrefetchToMemory
    }

    /// Whether the disk storage file loading should happen in a synchronous behavior or not.
    @available(*, deprecated,
    message: "Create a `CometChatKingfisherParsedOptionsInfo` from `CometChatKingfisherOptionsInfo` and use `loadDiskFileSynchronously` instead.")
     var loadDiskFileSynchronously: Bool {
        return CometChatKingfisherParsedOptionsInfo(Array(self)).loadDiskFileSynchronously
    }
}

/// The default modifier.
/// It does nothing and returns the image as is.
@available(*, deprecated, message: "Use `nil` in CometChatKingfisherOptionsInfo to indicate no modifier.")
 struct DefaultImageModifier: ImageModifier {

    /// A default `DefaultImageModifier` which can be used everywhere.
     static let default1 = DefaultImageModifier()
    private init() {}

    /// Modifies an input `Image`. See `ImageModifier` protocol for more.
     func modify(_ image: CFCrossPlatformImage) -> CFCrossPlatformImage { return image }
}


#if os(macOS)
@available(*, deprecated, message: "Use `CFCrossPlatformImage` instead.")
 typealias Image = CFCrossPlatformImage
@available(*, deprecated, message: "Use `CFCrossPlatformView` instead.")
 typealias View = CFCrossPlatformView
@available(*, deprecated, message: "Use `CFCrossPlatformColor` instead.")
 typealias Color = CFCrossPlatformColor
@available(*, deprecated, message: "Use `CFCrossPlatformImageView` instead.")
 typealias ImageView = CFCrossPlatformImageView
@available(*, deprecated, message: "Use `CFCrossPlatformButton` instead.")
 typealias Button = CFCrossPlatformButton
#else
@available(*, deprecated, message: "Use `CFCrossPlatformImage` instead.")
 typealias Image = CFCrossPlatformImage
@available(*, deprecated, message: "Use `CFCrossPlatformColor` instead.")
 typealias Color = CFCrossPlatformColor
    #if !os(watchOS)
    @available(*, deprecated, message: "Use `CFCrossPlatformImageView` instead.")
     typealias ImageView = CFCrossPlatformImageView
    @available(*, deprecated, message: "Use `CFCrossPlatformView` instead.")
     typealias View = CFCrossPlatformView
    @available(*, deprecated, message: "Use `CFCrossPlatformButton` instead.")
     typealias Button = CFCrossPlatformButton
    #endif
#endif
