//
//  CometChatAIConversationStarterShimmer.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 18/11/24.
//

import Foundation
import UIKit

open class CometChatAIConversationStarterShimmer: CometChatShimmerView {
    
    public var cellCount = 3
    var cellCountManager = 0 // for managing cell count internally
    
    open override func buildUI() {
        super.buildUI()
        backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.register(AIConversationStarterCell.self, forCellReuseIdentifier: "AIConversationStarterCell")
    }
    
    open override func startShimmer() {
        cellCountManager = cellCount
        tableView.reloadData()
    }
    
    open override func stopShimmer() {
        cellCountManager = 0
        tableView.reloadData()
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCountManager
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: "AIConversationStarterCell", for: indexPath) as? AIConversationStarterCell {
            listItem.backgroundColor = .clear
            listItem.containerView.pin(anchors: [.height], to: 30)
            listItem.containerView.roundViewCorners(corner: .init(cornerRadius: 15))
            
            if indexPath.row == 0{
                listItem.containerView.pin(anchors: [.width], to: 200)
                addShimmer(view: listItem.containerView, size: CGSize(width: (200), height: 30))
            }else if indexPath.row == 1{
                listItem.containerView.pin(anchors: [.width], to: 250)
                addShimmer(view: listItem.containerView, size: CGSize(width: (250), height: 30))
            }else{
                listItem.containerView.pin(anchors: [.width], to: 300)
                addShimmer(view: listItem.containerView, size: CGSize(width: (300), height: 30))
            }
            listItem.backgroundColor = .clear
            
            return listItem
        }
        
        return UITableViewCell()
    }
}
