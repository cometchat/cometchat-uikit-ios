



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.

#if !os(watchOS)

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Represents a placeholder type which could be set while loading as well as
/// loading finished without getting an image.
 protocol Placeholder {
    
    /// How the placeholder should be added to a given image view.
    func add(to imageView: CFCrossPlatformImageView)
    
    /// How the placeholder should be removed from a given image view.
    func remove(from imageView: CFCrossPlatformImageView)
}

/// Default implementation of an image placeholder. The image will be set or
/// reset directly for `image` property of the image view.
extension CFCrossPlatformImage: Placeholder {
    /// How the placeholder should be added to a given image view.
     func add(to imageView: CFCrossPlatformImageView) { imageView.image = self }

    /// How the placeholder should be removed from a given image view.
     func remove(from imageView: CFCrossPlatformImageView) { imageView.image = nil }
}

/// Default implementation of an arbitrary view as placeholder. The view will be 
/// added as a subview when adding and be removed from its super view when removing.
///
/// To use your customize View type as placeholder, simply let it conforming to 
/// `Placeholder` by `extension MyView: Placeholder {}`.
extension Placeholder where Self: CFCrossPlatformView {
    
    /// How the placeholder should be added to a given image view.
     func add(to imageView: CFCrossPlatformImageView) {
        imageView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false

        centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        heightAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }

    /// How the placeholder should be removed from a given image view.
     func remove(from imageView: CFCrossPlatformImageView) {
        removeFromSuperview()
    }
}

#endif
