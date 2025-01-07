//
//  CometChatAIConversationSummaryShimmer.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 08/11/24.
//

import Foundation
import UIKit

open class CometChatAIConversationSummaryShimmer: CometChatShimmerView {
    
    public var cellCount = 7
    var cellCountManager = 0 // for managing cell count internally
    
    open override func buildUI() {
        super.buildUI()
        backgroundColor = .clear
        tableView.register(AIRepliesCell.self, forCellReuseIdentifier: "AIRepliesCell")
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
        if let listItem = tableView.dequeueReusableCell(withIdentifier: "AIRepliesCell", for: indexPath) as? AIRepliesCell {
            listItem.backgroundColor = .clear
            listItem.containerView.pin(anchors: [.width], to: (tableView.bounds.width - CometChatSpacing.Padding.p6))
            listItem.containerView.pin(anchors: [.height], to: 16)
            listItem.containerView.roundViewCorners(corner: .init(cornerRadius: 8))
            
            addShimmer(view: listItem.containerView, size: CGSize(width: (tableView.bounds.width - CometChatSpacing.Padding.p6), height: 16))
            
            return listItem
        }
        
        return UITableViewCell()
    }
}
