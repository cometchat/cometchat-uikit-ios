//
//  AIParentRepliesStyle.swift
//  
//
//  Created by SuryanshBisen on 25/09/23.
//

import Foundation
import UIKit

public protocol AIParentStyle {
    
    var errorViewTextFont: UIFont? { get set }
    var errorViewTextColor: UIColor? { get set }

    var emptyViewTextFont: UIFont? { get set }
    var emptyViewTextColor: UIColor? { get set }
}
