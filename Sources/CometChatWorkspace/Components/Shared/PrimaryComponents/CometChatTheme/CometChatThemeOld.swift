//
//  CometChatTheme.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 15/07/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

class  CometChatCorner: NSObject {
    
    var radius: CGFloat = 0
    var corner: Corner
    
    
    init(excludeCorner: Corner, radius: CGFloat = 0) {
        self.radius = radius
        self.corner = excludeCorner
    }
}


@objc  enum Corner: Int {
    case leftTop, rightTop, leftBottom, rightBottom, none
}

@objc  enum MessageAlignment: Int {
    case left
    case right
}



public class CometChatThemeOld {
    

    struct style {
        
        // Colors
        static var primaryBackgroundColor: UIColor = UIColor(named: "primaryBackgroundColor", in: Bundle.main, compatibleWith: nil) ?? .white
        
        static var secondaryBackgroundColor: UIColor = UIColor(named: "secondaryBackgroundColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        
        static var primaryIconColor: UIColor = UIColor(named: "primaryIconColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
        
        static var secondaryIconColor: UIColor = UIColor(named: "secondaryIconColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        
        static var destructiveIconColor: UIColor = UIColor(named: "destructiveIconColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        static var headingColor: UIColor = UIColor(named: "headingColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 0.1607843137, green: 0.1647058824, blue: 0.1725490196, alpha: 1)
        
        static var titleColor: UIColor = UIColor(named: "titleColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 0.1607843137, green: 0.1647058824, blue: 0.1725490196, alpha: 1)
        
        static var subtitleColor: UIColor = UIColor(named: "subtitleColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        
        static var textColor: UIColor = UIColor(named: "textColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1)
        
        // Font
        static var headingFont: UIFont = UIFont(name: "Inter-Bold", size: 35) ?? UIFont.systemFont(ofSize: 35, weight: .bold)
        
        static var titleFont: UIFont = UIFont(name: "Inter-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        static var subtitleFont: UIFont = UIFont(name: "Inter-Semibold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        

    }
    
    struct Avatar {
        
        var shape: Shape = .circle
        var backgroundColor: UIColor = .red
    }
    
    enum Shape {
        case rectangle
        case circle
        case roundedRectangle
    }
    
    struct messageList {
    
        static var bubbleType: BubbleType = .standard
        
       static var actionSheetLayout: LayoutMode = .gridMode
        
       
//        static var leftBubbleBackgroundColor: [Any] = [ UIColor(named: "secondaryBackgroundColor", in: Bundle.main, compatibleWith: nil)?.cgColor ?? #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1), UIColor(named: "primaryIconColor", in: Bundle.main, compatibleWith: nil)?.cgColor ?? #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)]
//
//        static var rightBubbleBackgroundColor: [Any] = [UIColor(named: "primaryIconColor", in: Bundle.main, compatibleWith: nil)?.cgColor ?? #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)]
        
//        static var leftBubbleBackgroundColor: [Any] = [UIColor(displayP3Red: 86/255, green: 142/255, blue: 175/255, alpha: 1).cgColor, UIColor(displayP3Red: 158/255, green: 83/255, blue: 140/255, alpha: 1).cgColor]
//
//        static var rightBubbleBackgroundColor: [Any] = [UIColor.black.cgColor, UIColor.red.cgColor]
        
        static var leftBubbleBackgroundColor: [Any] = [UIColor.systemFill.cgColor]
        
        static var rightBubbleBackgroundColor: [Any] = [UIColor(named: "primaryIconColor", in: Bundle.main, compatibleWith: nil)?.cgColor ?? UIColor.systemBlue.cgColor]
        
//        static var leftBubbleTextColor: UIColor = UIColor(named: "titleColor", in: Bundle.main, compatibleWith: nil) ?? #colorLiteral(red: 0.1607843137, green: 0.1647058824, blue: 0.1725490196, alpha: 1)
        
        static var leftBubbleTextColor: UIColor = UIColor.label
        
       static var rightBubbleTextColor: UIColor = UIColor(named: "primaryBackgroundColor", in: Bundle.main, compatibleWith: nil) ?? .white
        
        static var leftBubbleCorners: CometChatCorner = CometChatCorner(excludeCorner: .leftTop, radius: 12)
        
        static var rightBubbleCorners: CometChatCorner =  CometChatCorner(excludeCorner: .rightTop, radius: 12)

    }
   

}


//
