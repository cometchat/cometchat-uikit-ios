//
//  CometChatCallHistoryWithDetails.swift
//  
//
//  Created by Ajay Verma on 13/03/23.
//

import Foundation
import CometChatSDK

internal class CometChatCallHistoryWithDetails: CometChatCallsHistory {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        callbacks()
    }
    
    private func callbacks() {
        onDidSelect = { [weak self] (baseMessage, indexPath) in
            guard let this = self else { return }
            
            if let selectedCall = baseMessage as? Call {
                
                switch selectedCall.receiverType {
                case .user:
                    if ((selectedCall as? Call)?.callInitiator as? User)?.uid == LoggedInUserInformation.getUID() {
                        if let user = ((selectedCall as? Call)?.callReceiver as? User) {
                            this.navigateToCallDetails(forUser: user)
                        }
                    }else{
                        if let user = ((selectedCall as? Call)?.callInitiator as? User) {
                            this.navigateToCallDetails(forUser: user)
                        }
                    }
                case .group:
                    if let group = selectedCall.receiver as? Group {
                        
                        this.navigateToCallDetails(forGroup: group)
                    }
                @unknown default: break
                }
            }
            
            if let call = baseMessage as? CustomMessage, let group = call.receiver as? Group,  baseMessage.receiverType == .group {
                this.navigateToCallDetails(forGroup: group)
            }
        }
    }
    
    private func navigateToCallDetails(forUser: User) {
        DispatchQueue.main.async {
            let cometChatCallDetails = CometChatCallDetails()
            cometChatCallDetails.set(user: forUser)
            cometChatCallDetails.hidesBottomBarWhenPushed = true
            let naviVC = UINavigationController(rootViewController: cometChatCallDetails)
            self.present(naviVC, animated: true)
        }
    }
    
    private func navigateToCallDetails(forGroup: Group) {
        DispatchQueue.main.async {
            let cometChatCallDetails = CometChatCallDetails()
            cometChatCallDetails.set(group: forGroup)
            cometChatCallDetails.hidesBottomBarWhenPushed = true
            let naviVC = UINavigationController(rootViewController: cometChatCallDetails)
            self.present(naviVC, animated: true)
        }
        
    }

}
