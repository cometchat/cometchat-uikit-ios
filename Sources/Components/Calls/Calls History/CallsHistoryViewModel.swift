//
//  GroupsViewModel.swift
 
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import Foundation
import CometChatSDK

protocol CallHistoryViewModelProtocol {
    
    var row: Int { get set }
    var isSearching: Bool { get set }
    var calls: [CometChatSDK.BaseMessage] { get set }
    var filteredCalls: [CometChatSDK.BaseMessage] { get set }
    var selectedCalls: [CometChatSDK.BaseMessage] { get set }
    var callsRequestBuilder: MessagesRequest.MessageRequestBuilder { get set }
    
    var reload: (() -> Void)? { get set }
    var reloadAt: ((Int) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    
    func fetchCalls()
    func filterCalls(text: String)
}


open class CallHistoryViewModel: NSObject, CallHistoryViewModelProtocol {
    
    var row: Int = 0 {
        didSet {
            reloadAt?(row)
        }
    }
    
    var calls: [CometChatSDK.BaseMessage] = [] {
        didSet {
            reload?()
        }
    }
    
    var filteredCalls: [CometChatSDK.BaseMessage] = [] {
        didSet {
            reload?()
        }
    }
    
    var isSearching: Bool = false
    var selectedCalls: [CometChatSDK.BaseMessage] = []
    var callsRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder
    private var callsRequest: MessagesRequest?
    private var filterCallsRequest: MessagesRequest?
    
    var reload: (() -> Void)?
    var reloadAt: ((Int) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    
    init(callsRequestBuilder: MessagesRequest.MessageRequestBuilder) {
        self.callsRequestBuilder = callsRequestBuilder
        self.callsRequest = callsRequestBuilder.build()
    }
    
    func fetchCalls() {
        guard let callsRequest = callsRequest else { return }
        CallsBuilder.fetchCalls(callsRequest: callsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedCalls):
                guard let filteredCalls = fetchedCalls?.filter({
                    ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .initiated)  ||
                    ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .unanswered) ||   ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .rejected)  ||  ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .cancelled) ||  ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .ended) ||  ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .ongoing) || ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .busy)   || ($0 as? CustomMessage != nil)
                }) else { return }

                this.calls.insert(contentsOf: filteredCalls, at: 0)
             
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func filterCalls(text: String) {
        self.filteredCalls.removeAll()
        self.filterCallsRequest = self.callsRequestBuilder.set(searchKeyword: text).build()
        guard let filterCallsRequest = filterCallsRequest else { return }
        CallsBuilder.getfilteredCalls(filterCallsRequest: filterCallsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let filteredCalls):
                guard let filteredCalls = filteredCalls?.filter({
                    ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .initiated)  ||
                    ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .unanswered) ||   ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .rejected)  ||  ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .cancelled) ||  ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .ended) ||  ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .ongoing) || ($0 as? CometChatSDK.Call != nil && ($0 as? CometChatSDK.Call)?.callStatus == .busy)   || ($0 as? CustomMessage != nil)
                }) else { return }
                
                this.filteredCalls = filteredCalls
                
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func connect() {
        CometChat.addCallListener("call-list-call-sdk-listner", self)
        CometChatCallEvents.addListener("call-list-call-event-listner", self)
    }
    
    func disconnect() {
        CometChat.removeCallListener("call-list-call-sdk-listner")
        CometChatCallEvents.removeListener("call-list-call-event-listner")
    }
    
    @discardableResult
    func add(call: BaseMessage) -> Self {
        if !self.calls.contains(obj: call) {
            self.calls.append(call)
        }
        return self
    }
    
    @discardableResult
    func insert(call: Call, at: Int) -> Self {
        if !self.calls.contains(obj: call) {
            self.calls.insert(call, at: at)
        }
        return self
    }
    
    @discardableResult
    func update(call: Call) -> Self {
        if let index = calls.firstIndex(of: call) {
            self.calls[index] = call
        }
        return self
    }
    
    @discardableResult
    func remove(call: Call) -> Self {
        if let index = calls.firstIndex(of: call) {
            self.calls.remove(at: index)
        }
        return self
    }
    
    @discardableResult
    func clearList() -> Self {
        self.calls.removeAll()
        return self
    }
    
    func size() -> Int {
        return self.calls.count
    }
}

extension  CallHistoryViewModel : CometChatCallDelegate {
    public func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let incomingCall = incomingCall {
            self.add(call: incomingCall)
        }
    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let acceptedCall = acceptedCall {
            self.add(call: acceptedCall)
        }
    }
    
    public func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let rejectedCall = rejectedCall {
            self.add(call: rejectedCall)
        }
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let canceledCall = canceledCall {
            self.add(call: canceledCall)
        }
    }
}

extension CallHistoryViewModel:  CometChatCallEventListener {
    public func onIncomingCallAccepted(call: CometChatSDK.Call) {
        self.add(call: call)
    }
    
    public func onIncomingCallRejected(call: CometChatSDK.Call) {
        self.add(call: call)
    }
    
    public func onCallEnded(call: CometChatSDK.Call) {
        self.add(call: call)
    }
    
    public func onCallInitiated(call: CometChatSDK.Call) {
        self.add(call: call)
    }
    
    public func onOutgoingCallAccepted(call: CometChatSDK.Call) {
        self.add(call: call)
    }
    
    public func onOutgoingCallRejected(call: CometChatSDK.Call) {
        self.add(call: call)
    }
    
}
