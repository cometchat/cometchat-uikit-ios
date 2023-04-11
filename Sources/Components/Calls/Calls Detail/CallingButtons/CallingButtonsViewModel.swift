//
//  File.swift
//  
//
//  Created by Ajay Verma on 10/03/23.
//

import Foundation
import CometChatPro

protocol CallingButtonsViewModelProtocol {
    var user: User? { get set }
    var group: Group? { get set }
    var failure: ((CometChatPro.CometChatException) -> Void)? { get set }
    var reload: (() -> Void)? { get set }
}

public class CallingButtonsViewModel: NSObject , CallingButtonsViewModelProtocol {
    var user: User?
    var group: Group?
    var failure: ((CometChatPro.CometChatException) -> Void)?
    var reload: (() -> Void)?
}
