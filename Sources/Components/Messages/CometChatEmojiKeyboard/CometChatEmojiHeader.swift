//
//  CometChatEmojiHeader.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 09/06/22.
//

import UIKit

class CometChatEmojiHeader: UICollectionReusableView {

    static let identifier = "EmojiHeader"
    @IBOutlet weak var category: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        category.textColor = CometChatTheme.palatte?.accent600
        set(backgroundColor: (CometChatTheme.palatte?.background)!)
    }
    
    @discardableResult
    @objc public func set(backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
}
