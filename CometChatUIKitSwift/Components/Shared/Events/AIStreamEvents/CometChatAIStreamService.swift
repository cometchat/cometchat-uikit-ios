//
//  CometChatAIStreamService.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 16/09/25.
//

import Foundation
import CometChatSDK

public class CometChatAIStreamService {
    
    // ---------------------------
    // Singleton
    // ---------------------------
    public static let shared = CometChatAIStreamService()
    private init() {}
    var streamBuffers: [Int: String] = [:]         // buffer text per runId
    var streamTimers: [Int: Timer] = [:]
    // ---------------------------
    // Core Data Structures
    private let lock = NSLock()
    private var eventQueues: [Int: [AIAssistantBaseEvent]] = [:]
    private var deltaBuffers: [Int: String] = [:]
    private var runIdToMessageIdMap: [Int: Int] = [:]
    private var messageMap: [Int: StreamMessage] = [:]
    public var aiAssistantMessages: [Int: AIAssistantMessage] = [:]
    public var aiToolResultMessages: [Int: AIToolResultMessage] = [:]
    public var aiToolArgumentMessages: [Int: AIToolArgumentMessage] = [:]
    public var queueCompletionCallbacks: [Int: QueueCompletionCallback] = [:]
    private var controllers: [Int: ((AIAssistantBaseEvent) -> Void)] = [:]
    
    private var streamCallbacks: [Int: WeakStreamCallback] = [:]

    private class WeakStreamCallback {
        weak var value: StreamCallback?
        init (_ value: StreamCallback) { self.value = value }
    }
    
    // ---------------------------
    // Config
    private var _maxConcurrentQueues: Int = 10

    private var _isAIBusy: Bool = false

    public var maxConcurrentQueues: Int {
        get { lock.lock(); defer { lock.unlock() }; return _maxConcurrentQueues }
        set { lock.lock(); _maxConcurrentQueues = max(1, min(newValue, 10)); lock.unlock() }
    }
    
    private var _streamProcessingDelay: TimeInterval = 0.15
    public var streamProcessingDelay: TimeInterval {
        get { lock.lock(); defer { lock.unlock() }; return _streamProcessingDelay }
        set {
            lock.lock()
            _streamProcessingDelay = max(0.03, min(newValue, 0.5)) // clamp for safety
            lock.unlock()
        }
    }

    
    public var isAIBusy: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _isAIBusy }
        set {
            lock.lock(); let oldValue = _isAIBusy;
            _isAIBusy = newValue; lock.unlock()
            DispatchQueue.main.async(execute: { [weak self] in
                self?.onStreamingStateChanged?(newValue)
                if oldValue != newValue {
                    NotificationCenter.default.post(name: NSNotification.Name("AIBusyStateChanged"), object: nil)
                }
            })
        }
    }
    
    public var onStreamingStateChanged: ((Bool) -> Void)?
    
    public func getCurrentQueueCount() -> Int {
        lock.lock(); defer { lock.unlock() }
        return eventQueues.count
    }
    
    public func isQueueEmpty(runId: Int) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return eventQueues[runId]?.isEmpty ?? true
    }
    
    public func hasEvents(runId: Int) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return eventQueues[runId]?.isEmpty == false
    }
    
    public func runExists(runId: Int) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return eventQueues.keys.contains(runId)
    }
    
    // ---------------------------
    // Queue Management
    public func handleIncomingEvent(runId: Int, event: AIAssistantBaseEvent) {
        lock.lock()
        if eventQueues[runId] != nil {
            eventQueues[runId]?.append(event)
        } else if eventQueues.count < _maxConcurrentQueues {
            eventQueues[runId] = [event]
        }
        lock.unlock()
        if controllers[runId] != nil {
            emitNext(runId: runId)
        }
    }

    private let streamQueue = DispatchQueue(label: "com.cometchat.ai.streamQueue", qos: .utility)

    private func emitNext(runId: Int) {
        // Clear existing timer if any
        streamTimers[runId]?.invalidate()

        let delay = _streamProcessingDelay
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true) { [weak self] t in
            guard let self = self else { return }
            self.lock.lock()
//            guard let controller = self.controllers[runId] else {
//                t.invalidate()
//                self.streamTimers.removeValue(forKey: runId)
//                return
//            }
            guard var queue = self.eventQueues[runId],
                  let controller = self.controllers[runId],
                  !queue.isEmpty else {
                self.lock.unlock()
                t.invalidate()
                self.streamTimers.removeValue(forKey: runId)
                return
            }
            let event = queue.removeFirst()
            self.eventQueues[runId] = queue
            self.lock.unlock()

            DispatchQueue.main.async {
                controller(event)
            }

            if self.isQueueEmpty(runId: runId) {
                t.invalidate()
                self.streamTimers.removeValue(forKey: runId)
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        streamTimers[runId] = timer
    }
    
    public func startStreamingForRunId(runId: Int, onAiAssistantEvent: @escaping (AIAssistantBaseEvent) -> Void, onError: ((CometChatException) -> Void)? = nil) {
        if isStreamingActive(runId: runId) {
            return
        }
        lock.lock()
        controllers[runId] = onAiAssistantEvent
        lock.unlock()
        emitNext(runId: runId)
        isAIBusy = true
    }
    
    public func stopStreamingForRunId(runId: Int) {
        lock.lock()
        deltaBuffers.removeValue(forKey: runId)
        runIdToMessageIdMap.removeValue(forKey: runId)
        eventQueues.removeValue(forKey: runId)
        aiAssistantMessages.removeValue(forKey: runId)
//        aiToolResultMessages.removeValue(forKey: runId)
//        aiToolArgumentMessages.removeValue(forKey: runId)
        queueCompletionCallbacks.removeValue(forKey: runId)
        controllers.removeValue(forKey: runId)
        let busy = !eventQueues.isEmpty
        lock.unlock()
        isAIBusy = busy
    }
    
    func isStreamingActive(runId: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        return eventQueues.keys.contains(runId) && controllers.keys.contains(runId)
    }
    
    public func appendToBuffer(runId: Int, delta: String) {
        lock.lock()
        if let existing = deltaBuffers[runId] {
            deltaBuffers[runId] = existing + delta
        } else {
            deltaBuffers[runId] = delta
        }
        lock.unlock()
    }

    // ---------------------------
    // Network Events
    
    public func onConnectionError() {
        for runId in getAllRunIds() {
            streamCallbacks[runId]?.value?.onStreamInterrupted()
            stopStreamingForRunId(runId: runId)
            unregisterStreamCallback(runId: runId)
        }
    }
    
    private func registerStreamCallback(runId: Int, callback: StreamCallback) {
        streamCallbacks[runId] = WeakStreamCallback(callback)
    }

    public func unregisterStreamCallback(runId: Int) {
        streamCallbacks.removeValue(forKey: runId)
    }
    
//    public func stopStreamingForAllRunIds() {
//        lock.lock()
//        let allRunIds = Array(eventQueues.keys)
//        lock.unlock()
//
//        for runId in allRunIds {
//            stopStreamingForRunId(runId: runId)
//        }
//    }


    public func cleanupAll() {
        lock.lock()
        deltaBuffers.removeAll()
        runIdToMessageIdMap.removeAll()
        eventQueues.removeAll()
        messageMap.removeAll()
        aiAssistantMessages.removeAll()
//        aiToolResultMessages.removeAll()
//        aiToolArgumentMessages.removeAll()
        queueCompletionCallbacks.removeAll()
        controllers.removeAll()
        _isAIBusy = false
        lock.unlock()
        DispatchQueue.main.async(execute: {
            self.onStreamingStateChanged?(false)
        })
    }
        
    // ---------------------------
    // Buffer Management
    public func getOrCreateBuffer(runId: Int) -> String {
        lock.lock(); defer { lock.unlock() }
        if let buf = deltaBuffers[runId] { return buf }
        deltaBuffers[runId] = ""
        return ""
    }
    public func clearBuffer(runId: Int) { lock.lock(); deltaBuffers[runId] = ""; lock.unlock() }
    public func getBufferContent(runId: Int) -> String? { lock.lock(); defer { lock.unlock() }; return deltaBuffers[runId] }
    public func removeBuffer(runId: Int) { lock.lock(); deltaBuffers.removeValue(forKey: runId); lock.unlock() }
    
    // ---------------------------
    // Message ID & O(1) Lookup
    public func setMessageIdForRun(runId: Int, messageId: Int) { lock.lock(); runIdToMessageIdMap[runId] = messageId; lock.unlock() }
    public func getMessageIdForRun(runId: Int) -> Int? { lock.lock(); defer { lock.unlock() }; return runIdToMessageIdMap[runId] }
    public func removeMessageIdMapping(runId: Int) { lock.lock(); runIdToMessageIdMap.removeValue(forKey: runId); lock.unlock() }

    public func registerMessage(_ message: StreamMessage) { lock.lock(); messageMap[message.id] = message; lock.unlock() }
    public func getMessageById(messageId: Int) -> StreamMessage? { lock.lock(); defer { lock.unlock() }; return messageMap[messageId] }
    public func checkMessageExists(messageId: Int) -> Bool { lock.lock(); defer { lock.unlock() }; return messageMap.keys.contains(messageId) }
    public func removeMessageById(messageId: Int) { lock.lock(); messageMap.removeValue(forKey: messageId); lock.unlock() }
    public func updateMessage(_ message: StreamMessage) { lock.lock(); messageMap[message.id] = message; lock.unlock() }
    
    // ---------------------------
    // Completion Callback
    public func queueCompletionCallback(runId: Int) -> AIAssistantMessage? {
        lock.lock()
        eventQueues.removeValue(forKey: runId)
        let aiMsg = aiAssistantMessages.removeValue(forKey: runId)
        lock.unlock()
        return aiMsg
    }
    
    public func setQueueCompletionCallback(runId: Int, callback: QueueCompletionCallback) {
        lock.lock()
        queueCompletionCallbacks[runId] = callback
        lock.unlock()
        checkAndTriggerQueueCompletion(runId: runId)
    }
    
    // MARK: - Queue Completion (patched)
    func checkAndTriggerQueueCompletion(runId: Int) {
        lock.lock()
        let queueEmpty = eventQueues[runId]?.isEmpty ?? true
        let callback = queueCompletionCallbacks[runId]
        let aiMsg = aiAssistantMessages[runId]
        let toolResult = aiToolResultMessages[runId]
        let toolArg = aiToolArgumentMessages[runId]
        lock.unlock()

        if !queueEmpty {
            DispatchQueue.global().asyncAfter(deadline: .now() + (streamProcessingDelay * 2)) {
                self.checkAndTriggerQueueCompletion(runId: runId)
            }
            return
        }

        if let cb = callback {
            if let aiMsg = aiMsg {
                DispatchQueue.main.async {
                    cb.onQueueCompleted(aiMsg, nil, nil)
                    self.streamCallbacks[runId]?.value?.onStreamCompleted()
                    self.stopStreamingForRunId(runId: runId)
                }
            } else if let toolResult = toolResult {
                DispatchQueue.main.async {
                    cb.onQueueCompleted(nil, toolResult, nil)
                    self.stopStreamingForRunId(runId: runId)
                }
            } else if let toolArg = toolArg {
                DispatchQueue.main.async {
                    cb.onQueueCompleted(nil, nil, toolArg)
                    self.stopStreamingForRunId(runId: runId)
                }
            }
        }
    }
    
    // ---------------------------
    // Utility
    public func getAllRunIds() -> Set<Int> {
        lock.lock(); defer { lock.unlock() }
        return Set(eventQueues.keys)
    }
    
    public func addSmallDelay() async {
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
    
    public func getQueueStats() -> [String: Any] {
        lock.lock(); defer { lock.unlock() }
        return [
            "eventQueueSizes": eventQueues.mapValues { $0.count },
            "maxConcurrentQueues": _maxConcurrentQueues,
            "streamProcessingDelayMs": Int(_streamProcessingDelay * 1000)
        ]
    }
    
    public func printQueueStats() {
        lock.lock()
        let stats = eventQueues.mapValues { $0.count }
        lock.unlock()
        print("[AI Queue] Event counts: \(stats)")
    }
    
    public func handleNetworkDisconnected() {
        for runId in getAllRunIds() {
            stopStreamingForRunId(runId: runId)
        }
    }

    public func handleNetworkReconnected() {
        cleanupAll()
    }
    
    
    // ---------------------------
    // Connection Handling
    // ---------------------------
    private var isConnected: Bool = true
    private var disconnectedRunIds: Set<Int> = []

    public func onConnected() {
        lock.lock()
        isConnected = true
        disconnectedRunIds.removeAll()
        lock.unlock()
        
        cleanupAll() // clear queues and reset states
        
        print("[AI Stream] Connected")
        CometChatStreamCallBackEvents.ccStreamCompleted(true)
    }

    public func onDisconnected() {
        lock.lock()
        guard isConnected else { lock.unlock(); return }
        isConnected = false
        disconnectedRunIds = Set(eventQueues.keys)
        lock.unlock()
        
        for runId in disconnectedRunIds {
            streamCallbacks[runId]?.value?.onStreamInterrupted()
            stopStreamingForRunId(runId: runId)
            unregisterStreamCallback(runId: runId)
        }

        print("[AI Stream] Disconnected")
        CometChatStreamCallBackEvents.ccStreamInterrupted(true)
    }

    public func onConnectionError(_ error: CometChatException) {
        lock.lock()
        guard isConnected else { lock.unlock(); return }
        isConnected = false
        disconnectedRunIds = Set(eventQueues.keys)
        lock.unlock()
        
        for runId in disconnectedRunIds {
            streamCallbacks[runId]?.value?.onStreamInterrupted()
            stopStreamingForRunId(runId: runId)
            unregisterStreamCallback(runId: runId)
        }

        print("[AI Stream] Connection error: \(error.description)")
        CometChatStreamCallBackEvents.ccStreamInterrupted(true)
    }

}

// ---------------------------
// Callback Protocols
public protocol QueueCompletionCallback {
    func onQueueCompleted(
        _ aiAssistantMessage: AIAssistantMessage?,
        _ aiToolResultMessage: AIToolResultMessage?,
        _ aiToolArgumentMessage: AIToolArgumentMessage?
    )
}

public protocol StreamCallback: AnyObject {
    func onStreamCompleted()
    func onStreamInterrupted()
}

public class CometChatStreamCallBackEvents {
    
    public static let streamCompletedNotification = Notification.Name("CometChatStreamCompleted")
    public static let streamInterruptedNotification = Notification.Name("CometChatStreamInterrupted")
    
    public static func ccStreamCompleted(_ success: Bool) {
        NotificationCenter.default.post(
            name: streamCompletedNotification,
            object: nil,
            userInfo: ["success": success]
        )
    }
    
    public static func ccStreamInterrupted(_ interrupted: Bool) {
        NotificationCenter.default.post(
            name: streamInterruptedNotification,
            object: nil,
            userInfo: ["interrupted": interrupted]
        )
    }
}
