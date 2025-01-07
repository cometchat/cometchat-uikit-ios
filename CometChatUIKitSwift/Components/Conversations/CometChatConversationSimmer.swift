//
//  CometChatConversationSimmer.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 28/09/24.
//

import UIKit
import Foundation

open class ConversationSimmerView: CometChatShimmerView {
    
    public var cellCount = 20
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
            
            listItem.statusIndicator.isHidden = true
            listItem.titleStack.spacing = 8
            listItem.titleStack.alignment = .leading
            listItem.titleLabel.pin(anchors: [.width], to: 160)
            listItem.titleLabel.pin(anchors: [.height], to: 19)
            listItem.titleLabel.roundViewCorners(corner: .init(cornerRadius: (8)))
            
            listItem.avatarHeightConstraint.constant = 48
            listItem.avatarWidthConstraint.constant = 48
            
            addShimmer(view: listItem.avatar, size: CGSize(width: 48, height: 48))
            addShimmer(view: listItem.titleLabel, size: CGSize(width: 160, height: 19))
            
            //Subtitle View
            let subtitleView = UIView().withoutAutoresizingMaskConstraints()
            subtitleView.pin(anchors: [.height], to: 12)
            subtitleView.pin(anchors: [.width], to: 210)
            subtitleView.roundViewCorners(corner: .init(cornerRadius: (6)))
            listItem.set(subtitle: subtitleView)
            
            addShimmer(view: subtitleView, size: CGSize(width: 210, height: 12))
            
            //Tail View
            let tailView = UIStackView().withoutAutoresizingMaskConstraints()
            let topTailView = UIView().withoutAutoresizingMaskConstraints()
            let bottomTailView = UIView().withoutAutoresizingMaskConstraints()
            
            tailView.spacing = 8
            tailView.alignment = .trailing
            tailView.distribution = .fillEqually
            tailView.axis = .vertical
            tailView.addArrangedSubview(topTailView)
            tailView.addArrangedSubview(bottomTailView)
            
            topTailView.pin(anchors: [.width], to: 60)
            topTailView.pin(anchors: [.height], to: 19)
            topTailView.roundViewCorners(corner: .init(cornerRadius: 8))
            
            bottomTailView.pin(anchors: [.width], to: 20)
            bottomTailView.pin(anchors: [.height], to: 20)
            bottomTailView.roundViewCorners(corner: .init(cornerRadius: (20/2)))
            
            listItem.set(tail: tailView)
            
            addShimmer(view: topTailView, size: CGSize(width: 60, height: 19))
            addShimmer(view: bottomTailView, size: CGSize(width: 20, height: 20))
            
            return listItem
 
        }
        
        return UITableViewCell()
    }
}

