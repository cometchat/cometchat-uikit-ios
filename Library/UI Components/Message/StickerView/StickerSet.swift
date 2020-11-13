//
//  StickerSet.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 06/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

class StickerSet {
    
    var order: Int?
    var id: String?
    var thumbnail: String?
    var name: String?
    var stickers: [Sticker]?
    
    init(order: Int ,id: String, thumbnail: String, name: String, stickers: [Sticker]) {
        self.order = order
        self.id = id
        self.thumbnail = thumbnail
        self.name = name
        self.stickers = stickers
    }
}
