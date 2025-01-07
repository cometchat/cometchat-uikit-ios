//
//  CometChatCorner.swift
//  
//
//  Created by Abdullah Ansari on 23/09/22.
//

import UIKit

public enum Corner: Int {
    case leftTop, rightTop, leftBottom, rightBottom, none
}

public struct CometChatCornerStyle {

    private(set) var topLeft = false
    private(set) var topRight = false
    private(set) var bottomLeft = false
    private(set) var bottomRight = false
    private(set) var cornerRadius = 0.0
    
    public init() {}
    
    public init(topLeft: Bool = false, topRight: Bool = false, bottomLeft: Bool = false, bottomRight: Bool = false, cornerRadius: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
        self.cornerRadius = cornerRadius
    }

}

public struct CometChatCorner {

    var topLeft = 0.0
    var topRight = 0.0
    var bottomLeft = 0.0
    var bottomRight = 0.0
    var cornerRadius = 0.0
    
    public init() {}
    
    public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    public init(cornerRadius: CGFloat) {
        self.topLeft = cornerRadius
        self.topRight = cornerRadius
        self.bottomLeft = cornerRadius
        self.bottomRight = cornerRadius
        self.cornerRadius = cornerRadius
    }

}
