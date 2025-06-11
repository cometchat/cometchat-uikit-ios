//
//  DeviceTypeConstants.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 10/06/25.
//

import Foundation

struct DeviceType {
    static let IS_PHONE = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_PAD = UIDevice.current.userInterfaceIdiom == .pad

    static let IS_SMALL_DEVICE: Bool = {
        return IS_PHONE && DeviceWidthConstants.SCREEN_MAX_LENGTH <= 667 // iPhone SE, 6, 7, 8
    }()

    static let IS_BIG_DEVICE: Bool = {
        return IS_PAD || (IS_PHONE && DeviceWidthConstants.SCREEN_MAX_LENGTH > 667) // iPhone Plus, X and above, iPads
    }()
}

struct DeviceWidthConstants {
    static let SCREEN_WIDTH = UIScreen.main.bounds.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.height
    static let SCREEN_MAX_LENGTH = max(SCREEN_WIDTH, SCREEN_HEIGHT)
}
