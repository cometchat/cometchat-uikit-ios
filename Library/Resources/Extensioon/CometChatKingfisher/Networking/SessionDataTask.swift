



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.


import Foundation

/// Represents a session data task in `ImageDownloader`. It consists of an underlying `URLSessionDataTask` and
/// an array of `TaskCallback`. Multiple `TaskCallback`s could be added for a single downloading data task.
@objc  class SessionDataTask: NSObject {

    /// Represents the type of token which used for cancelling a task.
     typealias CancelToken = Int

    struct TaskCallback {
        let onCompleted: Delegate<Result<ImageLoadingResult, CometChatKingfisherError>, Void>?
        let options: CometChatKingfisherParsedOptionsInfo
    }

    /// Downloaded raw data of current task.
     private(set) var mutableData: Data

    /// The underlying download task. It is only for debugging purpose when you encountered an error. You should not
    /// modify the content of this task or start it yourself.
     let task: URLSessionDataTask
    private var callbacksStore = [CancelToken: TaskCallback]()

    var callbacks: [SessionDataTask.TaskCallback] {
        lock.lock()
        defer { lock.unlock() }
        return Array(callbacksStore.values)
    }

    private var currentToken = 0
    private let lock = NSLock()

    let onTaskDone = Delegate<(Result<(Data, URLResponse?), CometChatKingfisherError>, [TaskCallback]), Void>()
    let onCallbackCancelled = Delegate<(CancelToken, TaskCallback), Void>()

    var started = false
    var containsCallbacks: Bool {
        // We should be able to use `task.state != .running` to check it.
        // However, in some rare cases, cancelling the task does not change
        // task state to `.cancelling` immediately, but still in `.running`.
        // So we need to check callbacks count to for sure that it is safe to remove the
        // task in delegate.
        return !callbacks.isEmpty
    }

    init(task: URLSessionDataTask) {
        self.task = task
        mutableData = Data()
    }

    func addCallback(_ callback: TaskCallback) -> CancelToken {
        lock.lock()
        defer { lock.unlock() }
        callbacksStore[currentToken] = callback
        defer { currentToken += 1 }
        return currentToken
    }

    func removeCallback(_ token: CancelToken) -> TaskCallback? {
        lock.lock()
        defer { lock.unlock() }
        if let callback = callbacksStore[token] {
            callbacksStore[token] = nil
            return callback
        }
        return nil
    }

    func resume() {
        guard !started else { return }
        started = true
        task.resume()
    }

    func cancel(token: CancelToken) {
        guard let callback = removeCallback(token) else {
            return
        }
        if callbacksStore.count == 0 {
            task.cancel()
        }
        onCallbackCancelled.call((token, callback))
    }

    func forceCancel() {
        for token in callbacksStore.keys {
            cancel(token: token)
        }
    }

    func didReceiveData(_ data: Data) {
        mutableData.append(data)
    }
}
