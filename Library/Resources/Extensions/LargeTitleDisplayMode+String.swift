//
//  LargeTitleDisplayMode+String.swift
//  ios13-large-title-glitch
//
//  Created by thomas on 13/10/19.
//  Copyright © 2020 thomas. All rights reserved.
//

import UIKit

extension UINavigationItem.LargeTitleDisplayMode {
    var stringValue: String {
        switch self {
        case .always: return "always"
        case .automatic: return "automatic"
        case .never: return "never"
        @unknown default: fatalError()
        }
    }
}

