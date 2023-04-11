//
//  GroupsViewModel.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import Foundation
import CometChatPro

protocol CallHistoryViewModelProtocol {
    
    var row: Int { get set }
    var isSearching: Bool { get set }
    var calls: [CometChatPro.BaseMessage] { get set }
    var filteredCalls: [CometChatPro.BaseMessage] { get set }
    var selectedCalls: [CometChatPro.BaseMessage] { get set }
    var callsRequestBuilder: MessagesRequest.MessageRequestBuilder { get set }
    
    var reload: (() -> Void)? { get set }
    var reloadAt: ((Int) -> Void)? { get set }
    var failure: ((CometChatPro.CometChatException) -> Void)? { get set }
    
    func fetchCalls()
    func filterCalls(text: String)
}


open class CallHistoryViewModel: NSObject, CallHistoryViewModelProtocol {
    
    var row: Int = 0 {
        didSet {
            reloadAt?(row)
        }
    }
    
    var calls: [CometChatPro.BaseMessage] = [] {
        didSet {
            reload?()
        }
    }
    
    var filteredCalls: [CometChatPro.BaseMessage] = [] {
        didSet {
            reload?()
        }
    }
    
    var isSearching: Bool = false
    var selectedCalls: [CometChatPro.BaseMessage] = []
    var callsRequestBuilder: CometChatPro.MessagesRequest.MessageRequestBuilder
    private var callsRequest: MessagesRequest?
    private var filterCallsRequest: MessagesRequest?
    
    var reload: (() -> Void)?
    var reloadAt: ((Int) -> Void)?
    var failure: ((CometChatPro.CometChatException) -> Void)?
    
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
                    ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .initiated)  ||
                    ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .unanswered) ||   ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .rejected)  ||  ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .cancelled) ||  ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .ended) ||  ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .ongoing) || ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .busy)   || ($0 as? CustomMessage != nil)
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
                    ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .initiated)  ||
                    ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .unanswered) ||   ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .rejected)  ||  ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .cancelled) ||  ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .ended) ||  ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .ongoing) || ($0 as? CometChatPro.Call != nil && ($0 as? CometChatPro.Call)?.callStatus == .busy)   || ($0 as? CustomMessage != nil)
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
    public func onIncomingCallReceived(incomingCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        if let incomingCall = incomingCall {
            self.add(call: incomingCall)
        }
    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        if let acceptedCall = acceptedCall {
            self.add(call: acceptedCall)
        }
    }
    
    public func onOutgoingCallRejected(rejectedCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        if let rejectedCall = rejectedCall {
            self.add(call: rejectedCall)
        }
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        if let canceledCall = canceledCall {
            self.add(call: canceledCall)
        }
    }
}

extension CallHistoryViewModel:  CometChatCallEventListener {
    public func onIncomingCallAccepted(call: CometChatPro.Call) {
        self.add(call: call)
    }
    
    public func onIncomingCallRejected(call: CometChatPro.Call) {
        self.add(call: call)
    }
    
    public func onCallEnded(call: CometChatPro.Call) {
        self.add(call: call)
    }
    
    public func onCallInitiated(call: CometChatPro.Call) {
        self.add(call: call)
    }
    
    public func onOutgoingCallAccepted(call: CometChatPro.Call) {
        self.add(call: call)
    }
    
    public func onOutgoingCallRejected(call: CometChatPro.Call) {
        self.add(call: call)
    }
    
}
