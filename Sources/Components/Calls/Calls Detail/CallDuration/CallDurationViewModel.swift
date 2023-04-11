//
//  CallDurationViewModel.swift
//  
//
//  Created by Ajay Verma on 09/03/23.
//

import Foundation
import CometChatPro

protocol CallDurationViewModelProtocol {
    
    var user: User? { get set }
    var group: Group? { get set }
    var calls:  [CometChatPro.BaseMessage]{ get set }
    var groupedCalls:  [[CometChatPro.BaseMessage]] { get set }
    var callsRequestBuilder: MessagesRequest.MessageRequestBuilder { get set }
    var failure: ((CometChatPro.CometChatException) -> Void)? { get set }
    var reload: (() -> Void)? { get set }
    func fetchCalls(completion: @escaping () -> ())
}

public class CallDurationViewModel: NSObject, CallDurationViewModelProtocol {
    
    var user: User?
    var group: Group?
    var calls:  [CometChatPro.BaseMessage] = []
    var groupedCalls:  [[CometChatPro.BaseMessage]] = [[BaseMessage]]()
    var callsRequestBuilder: CometChatPro.MessagesRequest.MessageRequestBuilder
    var failure: ((CometChatPro.CometChatException) -> Void)?
    var reload: (() -> Void)?
    var updateTableViewHeight: (() -> Void)?
    private var callsRequest: MessagesRequest?
        
    init(callsRequestBuilder: MessagesRequest.MessageRequestBuilder = CallDetailsBuilder().shared) {
        self.callsRequestBuilder = callsRequestBuilder
    }
    
    func fetchCalls(completion: @escaping () -> ()) {
        if let user = user, let uid = user.uid {
            self.callsRequest = callsRequestBuilder.set(uid: uid).build()
        } else if let group = group {
            self.callsRequest = callsRequestBuilder.set(guid: group.guid).build()
        }
        guard let callsRequest = callsRequest else { return }
        calls.removeAll()
        groupedCalls.removeAll()
        CallDetailsBuilder.fetchCalls(callsRequest: callsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedCalls):
                if let fetchedCalls = fetchedCalls {
                    this.calls += fetchedCalls
                    this.groupMessages(messages:  fetchedCalls)
                    completion()
                }
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    private func groupMessages(messages: [BaseMessage]) {
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.groupedCalls.append(values ?? [])
            DispatchQueue.main.async{  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.updateTableViewHeight?()
            }
        }
    }
}
