//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 15/02/23.
//

import Foundation

public class StickerConfiguration {
    
    var stickerKeyboardStyle: StickerKeyboardStyle?
    
    init(stickerKeyboardStyle: StickerKeyboardStyle? = nil) {
        self.stickerKeyboardStyle = stickerKeyboardStyle
    }
}
