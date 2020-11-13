//
//  Sticker.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 06/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

class Sticker {
    
    var id: String?
    var name: String?
    var order: Int?
    var setID: String?
    var setName: String?
    var setOrder: Int?
    var url: String?
    
    init(id: String ,name: String, order: Int, setID: String, setName: String, setOrder: Int, url: String) {
        self.id = id
        self.name = name
        self.order = order
        self.setID = setID
        self.setName = setName
        self.setOrder = setOrder
        self.url = url
    }
}

