//
//  CometChatDateTimeFormatter.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 16/04/25.
//

import Foundation

public struct CometChatDateTimeFormatter {

    public var time: ((_ timestamp: Int) -> String)?
    public var today: ((_ timestamp: Int) -> String)?
    public var yesterday: ((_ timestamp: Int) -> String)?
    public var lastWeek: ((_ timestamp: Int) -> String)?
    public var otherDay: ((_ timestamp: Int) -> String)?
    
    public var minute: ((_ timestamp: Int) -> String)?
    public var minutes: ((_ timestamp: Int) -> String)?
    public var hour: ((_ timestamp: Int) -> String)?
    public var hours: ((_ timestamp: Int) -> String)?

    public init() {}
}
