//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 20/09/22.
//

import Foundation
import UIKit
import CometChatSDK

public class CometChatDetailsOption: CometChatOption {
    
    var customView: UIView?
    var titleColor: UIColor?
    var titleFont: UIFont?
    var height: CGFloat?
    var onClick: ((_ user: User?, _ group: Group?, _ section: Int, _ option: CometChatDetailsOption, _ controller: UIViewController?) -> ())?

    
    public init(id: String?, title: String?, customView: UIView?, titleColor: UIColor, titleFont: UIFont,height: CGFloat?, onClick: ((_ user: User?, _ group: Group?, _ section: Int, _ option: CometChatDetailsOption, _ controller: UIViewController?) -> ())?) {
        super.init()
        self.id = id
        self.title = title
        self.customView = customView
        self.onClick = onClick
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.height = height
    }
}



        
       
