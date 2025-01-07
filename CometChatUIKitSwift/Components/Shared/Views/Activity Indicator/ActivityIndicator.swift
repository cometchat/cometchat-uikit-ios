//
//  ActivityIndicator.swift
//
//
//  Created by Abdullah Ansari on 20/11/22.
//

import Foundation
import UIKit

public enum ActivityIndicatorStyle {
    case medium
    case gray
    case large
}

final class ActivityIndicator {
    
    static let shared = ActivityIndicator()
    
    private init() {}
    
    static var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    static func show() -> UIActivityIndicatorView {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = CometChatTheme_v4.palatte.accent600
        activityIndicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: UIScreen.main.bounds.width, height: CGFloat(44))
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    static func set(style: UIActivityIndicatorView.Style) {
        activityIndicator.style = style
    }
    
    static func hide() {
        activityIndicator.stopAnimating()
    }
    
    static func set(tintColor: UIColor) {
        activityIndicator.tintColor = tintColor
    }
}
