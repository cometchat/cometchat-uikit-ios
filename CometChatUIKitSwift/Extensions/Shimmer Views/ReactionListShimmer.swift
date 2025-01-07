//
//  ReactionListShimmer.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 27/09/24.
//

import Foundation
import UIKit

open class CometChatReactionListShimmer: CometChatShimmerView {
    
    public var cellCount = 10
    var cellCountManager = 0 // for managing cell count internally
    
    open override func buildUI() {
        super.buildUI()
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
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
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem {
            
            let screenWidth = UIScreen.main.bounds.width
            let avatarWidth = listItem.avatar.frame.width
            let stackViewSpacing = listItem.containerView.spacing
            
            let totalWidthToRemove = avatarWidth + (2 * stackViewSpacing) + (2 * CometChatSpacing.Spacing.s4) + 24
            let titleWidth = screenWidth - totalWidthToRemove
            
            listItem.statusIndicator.isHidden = true
            listItem.titleStack.spacing = 8
            listItem.titleStack.alignment = .leading
            listItem.titleLabel.pin(anchors: [.width], to: titleWidth)
            listItem.titleLabel.pin(anchors: [.height], to: 20)
            listItem.titleLabel.roundViewCorners(corner: .init(cornerRadius: (8)))
            
            listItem.avatarHeightConstraint.constant = 40
            listItem.avatarWidthConstraint.constant = 40
            
            addShimmer(view: listItem.titleLabel, size: CGSize(width: titleWidth, height: 20))
            addShimmer(view: listItem.avatar, size: CGSize(width: 40, height: 40))
            
            //Tail View
            let tailView = UIView().withoutAutoresizingMaskConstraints()
            
            tailView.pin(anchors: [.width, .height], to: 24)
            tailView.roundViewCorners(corner: .init(cornerRadius: 12))
            
            listItem.set(tail: tailView)
            
            addShimmer(view: tailView, size: CGSize(width: 24, height: 24))
            
            return listItem
 
        }
        
        return UITableViewCell()
    }
}
