//
//  AIAssistanceChatHistoryShimmerView.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 18/09/25.
//

import Foundation
import UIKit

open class AIAssistanceChatHistoryShimmerView: CometChatShimmerView {
    
    public var cellCount = 20
    var cellCountManager = 0 // for managing cell count internally
    
    open override func buildUI() {
        super.buildUI()
        backgroundColor = CometChatTheme.backgroundColor03
        tableView.register(AIAssistantChatHistoryCell.self, forCellReuseIdentifier: AIAssistantChatHistoryCell.identifier)
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
        if let listItem = tableView.dequeueReusableCell(withIdentifier: AIAssistantChatHistoryCell.identifier, for: indexPath) as? AIAssistantChatHistoryCell {
            
            listItem.messageLabel.pin(anchors: [.width], to: UIScreen.main.bounds.width * 0.6)
            listItem.messageLabel.pin(anchors: [.height], to: 22)
            listItem.messageLabel.roundViewCorners(corner: .init(cornerRadius: (11)))
            addShimmer(view: listItem.messageLabel, size: CGSize(width: UIScreen.main.bounds.width - 24, height: 22))
            
            return listItem
        }
        return UITableViewCell()
    }
}
