//
//  ActivityIndicatorView.swift
//  
//
//  Created by admin on 24/08/22.
//

import Foundation
import UIKit

// TODO: - Can separate indicator view or not
struct ActivityIndicatorView {
    var activityIndicator = UIActivityIndicatorView()
    
    mutating func setup() {
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
        activityIndicator.color = CometChatTheme_v4.palatte.accent600

    }
    
    ///Show Indicator
    ///Hide Indicator
}
