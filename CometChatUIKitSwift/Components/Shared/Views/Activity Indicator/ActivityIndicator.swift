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
    
    /// The indicator most recently returned by `show()`. Kept for `hide()`,
    /// `set(style:)` and `set(tintColor:)`; callers should hold on to the view
    /// `show()` returns and stop it with `hide(_:)` / `hide(in:)` instead.
    static var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    /// Makes a new, animating indicator for one caller. Every call returns its own view.
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
    
    /// Stops the indicator from the most recent `show()`, whoever installed it.
    static func hide() {
        activityIndicator.stopAnimating()
    }
    
    /// Stops the given indicator, leaving every other caller's indicator alone.
    static func hide(_ indicator: UIView?) {
        (indicator as? UIActivityIndicatorView)?.stopAnimating()
    }
    
    /// Stops the indicator a caller installed as `tableView`'s footer, if it has one.
    static func hide(in tableView: UITableView?) {
        hide(tableView?.tableFooterView)
    }
    
    static func set(tintColor: UIColor) {
        activityIndicator.tintColor = tintColor
    }
}
