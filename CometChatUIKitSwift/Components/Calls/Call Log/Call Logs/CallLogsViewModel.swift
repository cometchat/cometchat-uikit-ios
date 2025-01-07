//
//  CallLogsViewModel.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 17/11/23.
//

import Foundation
import CometChatSDK
#if canImport(CometChatCallsSDK)
import CometChatCallsSDK

public class CallLogsViewModel {
    
    var reload: (() -> Void)?
    var refresh: (() -> Void)?
    var onError: ((CometChatCallsSDK.CometChatCallException?) -> Void)?
    var group: CometChatSDK.Group?
    var user: CometChatSDK.User?
    var callLogs: [CometChatCallsSDK.CallLog] = []
    var callLogRequest: CometChatCallsSDK.CallLogsRequest
    var failure: ((CometChatCallsSDK.CometChatCallException?) -> Void)?
    var empty: (() -> Void)?
    var isFreshReloading = false
    var callLogRequestBuilder: CometChatCallsSDK.CallLogsRequest.CallLogsBuilder
    var isFetching = false
    var isFetchedAll = false
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchCallLogs()
            }
        }
    }

    init() {
        callLogRequestBuilder = CometChatCallsSDK.CallLogsRequest.CallLogsBuilder()
            .set(authToken: CometChat.getUserAuthToken())
            .set(callCategory: .call)
        callLogRequest = callLogRequestBuilder.build()
    }
    
    func fetchNext() {
        if isRefresh {
            isFetchedAll = false
        }
        if isFetchedAll { return }
        isFetching =  true
        
        callLogRequest.fetchNext { [weak self] callLogs in
            guard let this = self else { return }
            if !callLogs.isEmpty {
                this.addCallLogs(newCallLogs: callLogs)
            } else {
                this.isFetchedAll = true
                this.isFreshReloading = false
                this.empty?()
            }
            this.isFetching = false
            this.reload?()
        } onError: { [weak self] error in
            guard let this = self else { return }
            this.onError?(error)
            this.isFreshReloading = false
            this.isFetching = false
            this.failure?(error)
        }
    }
    
    func fetchCallLogs() {
        isFreshReloading = true
        callLogRequest = callLogRequestBuilder.build()
        fetchNext()
    }
    
    func addCallLogs(newCallLogs: [CometChatCallsSDK.CallLog]) {
        if isFreshReloading {
            callLogs.removeAll()
            isFreshReloading = false
        }
        callLogs.append(contentsOf: newCallLogs)
        reload?()
    }
}
#endif
