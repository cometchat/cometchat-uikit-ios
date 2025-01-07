//
//  URLSessionTask+Cancellable.swift
//  CometChatSwift
//
//  Created by Abdullah Ansari on 25/04/22.
//  Copyright © 2022 MacMini-03. All rights reserved.
//

import Foundation

protocol Cancellable: AnyObject {

    // MARK: - Methods

    func cancel()

}

extension URLSessionTask: Cancellable {}
