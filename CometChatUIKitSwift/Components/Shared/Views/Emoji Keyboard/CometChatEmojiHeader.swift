//
//  CometChatEmojiHeader.swift
 
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
        category.textColor = CometChatTheme_v4.palatte.accent600
        set(backgroundColor: CometChatTheme_v4.palatte.background)
    }
    
    @discardableResult
    @objc public func set(backgroundColor: UIColor) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
}
