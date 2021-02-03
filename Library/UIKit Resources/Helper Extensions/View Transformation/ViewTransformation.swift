//
//  ViewTransformation.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/02/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func roundViewCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
        self.layer.cornerRadius = radius
    }
}


extension UIViewController{
    func isModal() -> Bool {
        
        if let navigationController = self.navigationController{
            if navigationController.viewControllers.first != self{
                return false
            }
        }
        
        if self.presentingViewController != nil {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}



extension UIView {
    
    func dropShadow() {
        DispatchQueue.main.async {  [weak self] in
               guard let this = self else { return }
              this.layer.masksToBounds = false
                  this.layer.shadowColor = UIColor.gray.cgColor
                  this.layer.shadowOpacity = 0.3
                  this.layer.shadowOffset = CGSize.zero
                  this.layer.shadowRadius = 5
                  this.layer.shouldRasterize = true
                  this.layer.rasterizationScale = UIScreen.main.scale
        }
    }
}


extension UISegmentedControl {
    /// Tint color doesn't have any effect on iOS 13.
    func ensureiOS12Style() {
        if #available(iOS 13, *) {
            
        }else {
            self.backgroundColor = UIColor.white
            self.tintColor = UIKitSettings.primaryColor
            self.layer.borderColor = UIKitSettings.primaryColor.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 8
            self.clipsToBounds = true
            
        }
    }
}
