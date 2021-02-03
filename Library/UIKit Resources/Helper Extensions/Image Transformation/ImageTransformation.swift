//
//  ImageBlur.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/02/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
   convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
       let rect = CGRect(origin: .zero, size: size)
       UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
       color.setFill()
       UIRectFill(rect)
       let image = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       guard let cgImage = image?.cgImage else { return nil }
       self.init(cgImage: cgImage)
   }
}

//Blur the Image:
protocol Bluring {
   func addBlur(_ alpha: CGFloat)
}

extension Bluring where Self: UIView {
   func addBlur(_ alpha: CGFloat = 1) {
       // create effect
       if #available(iOS 13.0, *) {
           let effect = UIBlurEffect(style: .systemThinMaterialDark)
           let effectView = UIVisualEffectView(effect: effect)
           
           // set boundry and alpha
           effectView.frame = self.bounds
           effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           effectView.alpha = alpha
           self.addSubview(effectView)
       } else {
           let effect = UIBlurEffect(style: .dark)
           let effectView = UIVisualEffectView(effect: effect)
           
           // set boundry and alpha
           effectView.frame = self.bounds
           effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           effectView.alpha = alpha
           self.addSubview(effectView)
       }
       
   }
}

// Conformance
extension UIView: Bluring {}

extension URL    {
   func checkFileExist() -> Bool {
       let path = self.path
       if (FileManager.default.fileExists(atPath: path))   {
           return true
       }else{
           return false;
       }
   }
}

