//
//  MessageDateHeader.swift
//  ios-chat-uikit-app
//
//  Created by MacMini-03 on 21/02/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import Foundation
import UIKit


class MessageDateHeader: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 13.0, *) {
            backgroundColor = .darkGray
        } else {
            backgroundColor = .gray
        }
        textColor = .white
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false // enables auto layout
        font = UIFont (name: "SFProDisplay-Medium", size: 14)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 20, height: height)
    }
    
}

