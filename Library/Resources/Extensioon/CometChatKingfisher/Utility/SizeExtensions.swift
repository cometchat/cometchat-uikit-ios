
//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//  THE SOFTWARE.

import CoreGraphics

extension CGSize: CometChatKingfisherCompatibleValue {}
extension CometChatKingfisherWrapper where Base == CGSize {
    
    /// Returns a size by resizing the `base` size to a target size under a given content mode.
    ///
    /// - Parameters:
    ///   - size: The target size to resize to.
    ///   - contentMode: Content mode of the target size should be when resizing.
    /// - Returns: The resized size under the given `ContentMode`.
     func resize(to size: CGSize, for contentMode: ContentMode) -> CGSize {
        switch contentMode {
        case .aspectFit:
            return constrained(size)
        case .aspectFill:
            return filling(size)
        case .none:
            return size
        }
    }
    
    /// Returns a size by resizing the `base` size by making it aspect fitting the given `size`.
    ///
    /// - Parameter size: The size in which the `base` should fit in.
    /// - Returns: The size fitted in by the input `size`, while keeps `base` aspect.
     func constrained(_ size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        return aspectWidth > size.width ?
            CGSize(width: size.width, height: aspectHeight) :
            CGSize(width: aspectWidth, height: size.height)
    }
    
    /// Returns a size by resizing the `base` size by making it aspect filling the given `size`.
    ///
    /// - Parameter size: The size in which the `base` should fill.
    /// - Returns: The size be filled by the input `size`, while keeps `base` aspect.
     func filling(_ size: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * size.height)
        let aspectHeight = round(size.width / aspectRatio)
        
        return aspectWidth < size.width ?
            CGSize(width: size.width, height: aspectHeight) :
            CGSize(width: aspectWidth, height: size.height)
    }
    
    /// Returns a `CGRect` for which the `base` size is constrained to an input `size` at a given `anchor` point.
    ///
    /// - Parameters:
    ///   - size: The size in which the `base` should be constrained to.
    ///   - anchor: An anchor point in which the size constraint should happen.
    /// - Returns: The result `CGRect` for the constraint operation.
     func constrainedRect(for size: CGSize, anchor: CGPoint) -> CGRect {
        
        let unifiedAnchor = CGPoint(x: anchor.x.clamped(to: 0.0...1.0),
                                    y: anchor.y.clamped(to: 0.0...1.0))
        
        let x = unifiedAnchor.x * base.width - unifiedAnchor.x * size.width
        let y = unifiedAnchor.y * base.height - unifiedAnchor.y * size.height
        let r = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        let ori = CGRect(origin: .zero, size: base)
        return ori.intersection(r)
    }
    
    private var aspectRatio: CGFloat {
        return base.height == 0.0 ? 1.0 : base.width / base.height
    }
}

extension CGRect {
    func scaled(_ scale: CGFloat) -> CGRect {
        return CGRect(x: origin.x * scale, y: origin.y * scale,
                      width: size.width * scale, height: size.height * scale)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
