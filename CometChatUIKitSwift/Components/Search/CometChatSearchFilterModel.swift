//
//  CometChatSearchFilterModel.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 06/08/25.
//

import Foundation
import UIKit

public enum SearchScope {
    case conversations
    case messages
}

public struct FilterItem {
    let iconName: String // SF Symbol
    let title: String
}


public enum MessageFilterType: String, CaseIterable {
    case image = "Image"
    case video = "Video"
    case audio = "Audio"
    case file = "File"
}

public enum SearchFilter: String {
    case messages
    case conversations
    case unread
    case groups
    case photos
    case videos
    case links
    case documents
    case audio
}
