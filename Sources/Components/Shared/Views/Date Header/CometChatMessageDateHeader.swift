//
//  CometChatMessageDateHeader.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import Foundation
import UIKit


/*  ----------------------------------------------------------------------------------------- */

public class CometChatMessageDateHeader: CometChatDate {
    
    // MARK: - Initialization of required methods.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        set(backgroundColor: CometChatTheme.palatte.accent100)
        set(timeColor: CometChatTheme.palatte.accent600)
        set(timeFont: CometChatTheme.typography.caption1)
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false // enables auto layout
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        self.set(borderWidth: 1)
        self.set(borderColor:  borderColor != .clear ? borderColor : UIColor.systemFill)
        self.set(cornerRadius: 14)
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 20, height: height)
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
