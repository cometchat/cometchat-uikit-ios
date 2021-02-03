



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
#if !os(watchOS)


import UIKit

extension CometChatKingfisherWrapper where Base: UIButton {

    // MARK: Setting Image
    /// Sets an image to the button for a specified state with a source.
    ///
    /// - Parameters:
    ///   - source: The `Source` object contains information about the image.
    ///   - state: The button state to which the image should be set.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `CometChatKingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    /// Internally, this method will use `CometChatKingfisherManager` to get the requested source, from either cache
    /// or network. Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
     func setImage(
        with source: Source?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        guard let source = source else {
            base.setImage(placeholder, for: state)
            setTaskIdentifier(nil, for: state)
            completionHandler?(.failure(CometChatKingfisherError.imageSettingError(reason: .emptySource)))
            return nil
        }
        
        var options = CometChatKingfisherParsedOptionsInfo(CometChatKingfisherManager.shared.defaultOptions + (options ?? .empty))
        if !options.keepCurrentImageWhileLoading {
            base.setImage(placeholder, for: state)
        }
        
        var mutatingSelf = self
        let issuedIdentifier = Source.Identifier.next()
        setTaskIdentifier(issuedIdentifier, for: state)
        
        if let block = progressBlock {
            options.onDataReceived = (options.onDataReceived ?? []) + [ImageLoadingProgressSideEffect(block)]
        }
        
        if let provider = ImageProgressiveProvider(options, refresh: { image in
            self.base.setImage(image, for: state)
        }) {
            options.onDataReceived = (options.onDataReceived ?? []) + [provider]
        }
        
        options.onDataReceived?.forEach {
            $0.onShouldApply = { issuedIdentifier == self.taskIdentifier(for: state) }
        }
        
        let task = CometChatKingfisherManager.shared.retrieveImage(
            with: source,
            options: options,
            downloadTaskUpdated: { mutatingSelf.imageTask = $0 },
            completionHandler: { result in
                CallbackQueue.mainCurrentOrAsync.execute {
                    guard issuedIdentifier == self.taskIdentifier(for: state) else {
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
                    mutatingSelf.setTaskIdentifier(nil, for: state)
                    
                    switch result {
                    case .success(let value):
                        self.base.setImage(value.image, for: state)
                        completionHandler?(result)
                        
                    case .failure:
                        if let image = options.onFailureImage {
                            self.base.setImage(image, for: state)
                        }
                        completionHandler?(result)
                    }
                }
            }
        )
        
        mutatingSelf.imageTask = task
        return task
    }
    
    /// Sets an image to the button for a specified state with a requested resource.
    ///
    /// - Parameters:
    ///   - resource: The `Resource` object contains information about the resource.
    ///   - state: The button state to which the image should be set.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `CometChatKingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    /// Internally, this method will use `CometChatKingfisherManager` to get the requested resource, from either cache
    /// or network. Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
     func setImage(
        with resource: Resource?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        return setImage(
            with: resource.map { Source.network($0) },
            for: state,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler)
    }

    // MARK: Cancelling Downloading Task
    
    /// Cancels the image download task of the button if it is running.
    /// Nothing will happen if the downloading has already finished.
     func cancelImageDownloadTask() {
        imageTask?.cancel()
    }

    // MARK: Setting Background Image

    /// Sets a background image to the button for a specified state with a source.
    ///
    /// - Parameters:
    ///   - source: The `Source` object contains information about the image.
    ///   - state: The button state to which the image should be set.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `CometChatKingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    /// Internally, this method will use `CometChatKingfisherManager` to get the requested source
    /// Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
     func setBackgroundImage(
        with source: Source?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        guard let source = source else {
            base.setBackgroundImage(placeholder, for: state)
            setBackgroundTaskIdentifier(nil, for: state)
            completionHandler?(.failure(CometChatKingfisherError.imageSettingError(reason: .emptySource)))
            return nil
        }

        var options = CometChatKingfisherParsedOptionsInfo(CometChatKingfisherManager.shared.defaultOptions + (options ?? .empty))
        if !options.keepCurrentImageWhileLoading {
            base.setBackgroundImage(placeholder, for: state)
        }
        
        var mutatingSelf = self
        let issuedIdentifier = Source.Identifier.next()
        setBackgroundTaskIdentifier(issuedIdentifier, for: state)
        
        if let block = progressBlock {
            options.onDataReceived = (options.onDataReceived ?? []) + [ImageLoadingProgressSideEffect(block)]
        }
        
        if let provider = ImageProgressiveProvider(options, refresh: { image in
            self.base.setBackgroundImage(image, for: state)
        }) {
            options.onDataReceived = (options.onDataReceived ?? []) + [provider]
        }
        
        options.onDataReceived?.forEach {
            $0.onShouldApply = { issuedIdentifier == self.backgroundTaskIdentifier(for: state) }
        }
        
        let task = CometChatKingfisherManager.shared.retrieveImage(
            with: source,
            options: options,
            downloadTaskUpdated: { mutatingSelf.backgroundImageTask = $0 },
            completionHandler: { result in
                CallbackQueue.mainCurrentOrAsync.execute {
                    guard issuedIdentifier == self.backgroundTaskIdentifier(for: state) else {
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
                    
                    mutatingSelf.backgroundImageTask = nil
                    mutatingSelf.setBackgroundTaskIdentifier(nil, for: state)
                    
                    switch result {
                    case .success(let value):
                        self.base.setBackgroundImage(value.image, for: state)
                        completionHandler?(result)
                        
                    case .failure:
                        if let image = options.onFailureImage {
                            self.base.setBackgroundImage(image, for: state)
                        }
                        completionHandler?(result)
                    }
                }
            }
        )

        mutatingSelf.backgroundImageTask = task
        return task
    }

    /// Sets a background image to the button for a specified state with a requested resource.
    ///
    /// - Parameters:
    ///   - resource: The `Resource` object contains information about the resource.
    ///   - state: The button state to which the image should be set.
    ///   - placeholder: A placeholder to show while retrieving the image from the given `resource`.
    ///   - options: An options set to define image setting behaviors. See `CometChatKingfisherOptionsInfo` for more.
    ///   - progressBlock: Called when the image downloading progress gets updated. If the response does not contain an
    ///                    `expectedContentLength`, this block will not be called.
    ///   - completionHandler: Called when the image retrieved and set finished.
    /// - Returns: A task represents the image downloading.
    ///
    /// - Note:
    /// Internally, this method will use `CometChatKingfisherManager` to get the requested resource, from either cache
    /// or network. Since this method will perform UI changes, you must call it from the main thread.
    /// Both `progressBlock` and `completionHandler` will be also executed in the main thread.
    ///
    @discardableResult
     func setBackgroundImage(
        with resource: Resource?,
        for state: UIControl.State,
        placeholder: UIImage? = nil,
        options: CometChatKingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: ((Result<RetrieveImageResult, CometChatKingfisherError>) -> Void)? = nil) -> DownloadTask?
    {
        return setBackgroundImage(
            with: resource.map { .network($0) },
            for: state,
            placeholder: placeholder,
            options: options,
            progressBlock: progressBlock,
            completionHandler: completionHandler)
    }

    // MARK: Cancelling Background Downloading Task
    
    /// Cancels the background image download task of the button if it is running.
    /// Nothing will happen if the downloading has already finished.
     func cancelBackgroundImageDownloadTask() {
        backgroundImageTask?.cancel()
    }
}

// MARK: - Associated Object
private var taskIdentifierKey: Void?
private var imageTaskKey: Void?

// MARK: Properties
extension CometChatKingfisherWrapper where Base: UIButton {

    private typealias TaskIdentifier = Box<[UInt: Source.Identifier.Value]>
    
     func taskIdentifier(for state: UIControl.State) -> Source.Identifier.Value? {
        return taskIdentifierInfo.value[state.rawValue]
    }

    private func setTaskIdentifier(_ identifier: Source.Identifier.Value?, for state: UIControl.State) {
        taskIdentifierInfo.value[state.rawValue] = identifier
    }
    
    private var taskIdentifierInfo: TaskIdentifier {
        return  getAssociatedObject(base, &taskIdentifierKey) ?? {
            setRetainedAssociatedObject(base, &taskIdentifierKey, $0)
            return $0
        } (TaskIdentifier([:]))
    }
    
    private var imageTask: DownloadTask? {
        get { return getAssociatedObject(base, &imageTaskKey) }
        set { setRetainedAssociatedObject(base, &imageTaskKey, newValue)}
    }
}


private var backgroundTaskIdentifierKey: Void?
private var backgroundImageTaskKey: Void?

// MARK: Background Properties
extension CometChatKingfisherWrapper where Base: UIButton {
    
     func backgroundTaskIdentifier(for state: UIControl.State) -> Source.Identifier.Value? {
        return backgroundTaskIdentifierInfo.value[state.rawValue]
    }
    
    private func setBackgroundTaskIdentifier(_ identifier: Source.Identifier.Value?, for state: UIControl.State) {
        backgroundTaskIdentifierInfo.value[state.rawValue] = identifier
    }
    
    private var backgroundTaskIdentifierInfo: TaskIdentifier {
        return  getAssociatedObject(base, &backgroundTaskIdentifierKey) ?? {
            setRetainedAssociatedObject(base, &backgroundTaskIdentifierKey, $0)
            return $0
        } (TaskIdentifier([:]))
    }
    
    private var backgroundImageTask: DownloadTask? {
        get { return getAssociatedObject(base, &backgroundImageTaskKey) }
        mutating set { setRetainedAssociatedObject(base, &backgroundImageTaskKey, newValue) }
    }
}

extension CometChatKingfisherWrapper where Base: UIButton {

    /// Gets the image URL of this button for a specified state.
    ///
    /// - Parameter state: The state that uses the specified image.
    /// - Returns: Current URL for image.
    @available(*, deprecated, message: "Use `taskIdentifier` instead to identify a setting task.")
     func webURL(for state: UIControl.State) -> URL? {
        return nil
    }

    /// Gets the background image URL of this button for a specified state.
    ///
    /// - Parameter state: The state that uses the specified background image.
    /// - Returns: Current URL for image.
    @available(*, deprecated, message: "Use `backgroundTaskIdentifier` instead to identify a setting task.")
     func backgroundWebURL(for state: UIControl.State) -> URL? {
        return nil
    }
}
#endif


