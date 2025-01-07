//
//  CometChatGradientView.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/09/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
@objc class CometChatGradientView: UIView {
    
    private var gradientLayer = CAGradientLayer()
    var colors =  [CGColor]()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if colors.count != 1 {
            
            let gradientLayer = CAGradientLayer()
               gradientLayer.colors = colors
               gradientLayer.locations = [0.0, 1.0]
               gradientLayer.frame = self.bounds
               self.layer.insertSublayer(gradientLayer, at:0)
            
//            gradientLayer.backgroundColor = UIColor.clear.cgColor
//            gradientLayer.colors = colors
//            gradientLayer.locations = [0.0 , 1.0]
//            gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
//            gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//            gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
//            self.layer.insertSublayer(gradientLayer, at: 0)
            colors.removeAll()
        }
    }
    @discardableResult
    @objc public func set(backgroundColor: UIColor) -> CometChatGradientView {
        self.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    @objc public func set(backgroundColorWithGradient: [Any]?) ->  CometChatGradientView {
        if let currentColors = backgroundColorWithGradient as? [CGColor] {
            self.colors = currentColors
        }
        return self
    }
    
    
}
