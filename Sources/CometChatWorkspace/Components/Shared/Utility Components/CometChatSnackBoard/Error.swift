//
//  Error.swift
//  CometChatSnackBoard
//
//  Created by Timothy Moose on 8/7/16.
//  Copyright © 2016 SwiftKick Mobile LLC. All rights reserved.
//

import Foundation

/**
 The `CometChatSnackBoardError` enum contains the errors thrown by CometChatSnackBoard.
 */
enum CometChatSnackBoardError: Error {
    case cannotLoadViewFromNib(nibName: String)
    case noRootViewController
}
