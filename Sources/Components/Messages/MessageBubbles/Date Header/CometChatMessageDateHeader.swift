//
//  CometChatMessageDateHeader.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import Foundation
import UIKit


/*  ----------------------------------------------------------------------------------------- */

class CometChatMessageDateHeader: UILabel {
    
    // MARK: - Initialization of required methods.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = CometChatTheme.palatte?.background
        textColor = CometChatTheme.palatte?.accent600
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false // enables auto layout
        font = CometChatTheme.typography?.Caption1
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        layer.cornerRadius = height / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemFill.cgColor
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 20, height: height)
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
