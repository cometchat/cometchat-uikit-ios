



//  CometChatKingfisher
//  CometChatUIKit
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.

import UIKit

/// Transition effect which will be used when an image downloaded and set by `UIImageView`
/// extension API in CometChatKingfisher. You can assign an enum value with transition duration as
/// an item in `CometChatKingfisherOptionsInfo` to enable the animation transition.
///
/// Apple's UIViewAnimationOptions is used under the hood.
/// For custom transition, you should specified your own transition options, animations and
/// completion handler as well.
///
/// - none: No animation transition.
/// - fade: Fade in the loaded image in a given duration.
/// - flipFromLeft: Flip from left transition.
/// - flipFromRight: Flip from right transition.
/// - flipFromTop: Flip from top transition.
/// - flipFromBottom: Flip from bottom transition.
/// - custom: Custom transition.
 enum ImageTransition {
    /// No animation transition.
    case none
    /// Fade in the loaded image in a given duration.
    case fade(TimeInterval)
    /// Flip from left transition.
    case flipFromLeft(TimeInterval)
    /// Flip from right transition.
    case flipFromRight(TimeInterval)
    /// Flip from top transition.
    case flipFromTop(TimeInterval)
    /// Flip from bottom transition.
    case flipFromBottom(TimeInterval)
    /// Custom transition defined by a general animation block.
    ///    - duration: The time duration of this custom transition.
    ///    - options: `UIView.AnimationOptions` should be used in the transition.
    ///    - animations: The animation block will be applied when setting image.
    ///    - completion: A block called when the transition animation finishes.
    case custom(duration: TimeInterval,
                 options: UIView.AnimationOptions,
              animations: ((UIImageView, UIImage) -> Void)?,
              completion: ((Bool) -> Void)?)
    
    var duration: TimeInterval {
        switch self {
        case .none:                          return 0
        case .fade(let duration):            return duration
            
        case .flipFromLeft(let duration):    return duration
        case .flipFromRight(let duration):   return duration
        case .flipFromTop(let duration):     return duration
        case .flipFromBottom(let duration):  return duration
            
        case .custom(let duration, _, _, _): return duration
        }
    }
    
    var animationOptions: UIView.AnimationOptions {
        switch self {
        case .none:                         return []
        case .fade:                         return .transitionCrossDissolve
            
        case .flipFromLeft:                 return .transitionFlipFromLeft
        case .flipFromRight:                return .transitionFlipFromRight
        case .flipFromTop:                  return .transitionFlipFromTop
        case .flipFromBottom:               return .transitionFlipFromBottom
            
        case .custom(_, let options, _, _): return options
        }
    }
    
    var animations: ((UIImageView, UIImage) -> Void)? {
        switch self {
        case .custom(_, _, let animations, _): return animations
        default: return { $0.image = $1 }
        }
    }
    
    var completion: ((Bool) -> Void)? {
        switch self {
        case .custom(_, _, _, let completion): return completion
        default: return nil
        }
    }
}
//
//// Just a placeholder for compiling on macOS.
// enum ImageTransition {
//    case none
//}

