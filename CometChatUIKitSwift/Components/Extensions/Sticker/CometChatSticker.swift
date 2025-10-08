//
//  Sticker.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 06/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

public class CometChatSticker {
    
    public var id: String?
    public var name: String?
    public var order: Int?
    public var setID: String?
    public var setName: String?
    public var setOrder: Int?
    public var url: String?
    
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

