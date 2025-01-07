//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 29/09/22.
//

import Foundation
import UIKit

public class CometChatOption: Hashable {
    
    public var id: String?
    public var title: String?
    public var icon: UIImage?
    
    public init() {  }
    
    public static func == (lhs: CometChatOption, rhs: CometChatOption) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
