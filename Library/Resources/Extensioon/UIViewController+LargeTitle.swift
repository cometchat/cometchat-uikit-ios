//
//  UIViewController+LargeTitle.swift
//  ios13-large-title-glitch
//
//  Created by thomas on 14/10/19.
//  Copyright © 2020 thomas. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setLargeTitleDisplayMode(_ largeTitleDisplayMode: UINavigationItem.LargeTitleDisplayMode) {
        switch largeTitleDisplayMode {
        case .automatic:
            guard let navigationController = navigationController else { break }
            if let index = navigationController.children.firstIndex(of: self) {
                setLargeTitleDisplayMode(index == 0 ? .always : .never)
            } else {
                setLargeTitleDisplayMode(.always)
            }
        case .always, .never:
            // Always override to be .never if large title isn't available (contentSizeCategory, device size..)
            navigationItem.largeTitleDisplayMode = isLargeTitleAvailable() ? largeTitleDisplayMode : .never
            // Even when .never, needs to be true otherwise animation will be broken on iOS11, 12, 13
            navigationController?.navigationBar.prefersLargeTitles = true
        @unknown default:
            assertionFailure("\(#function): Missing handler for \(largeTitleDisplayMode)")
        }
    }
    
    private func isLargeTitleAvailable() -> Bool {
        switch traitCollection.preferredContentSizeCategory {
        case .accessibilityExtraExtraExtraLarge,
             .accessibilityExtraExtraLarge,
             .accessibilityExtraLarge,
             .accessibilityLarge,
             .accessibilityMedium,
             .extraExtraExtraLarge:
            return false
        default:
            /// Exclude 4" screen or 4.7" with zoomed
            return UIScreen.main.bounds.height > 568
        }
    }
}
