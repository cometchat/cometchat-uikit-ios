//
//  SavedMessagesShimmerView.swift
//  CometChatUIKitSwift
//

import UIKit
import Foundation

open class SavedMessagesShimmerView: CometChatShimmerView {

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

            listItem.statusIndicator.isHidden = true
            listItem.titleStack.spacing = 8
            listItem.titleStack.alignment = .leading
            listItem.titleLabel.pin(anchors: [.width], to: 120)
            listItem.titleLabel.pin(anchors: [.height], to: 18)
            listItem.titleLabel.roundViewCorners(corner: .init(cornerRadius: 9))

            // Matches the real row's avatar, which the Figma parity pass restored.
            listItem.avatarHeightConstraint.constant = 48
            listItem.avatarWidthConstraint.constant = 48

            addShimmer(view: listItem.avatar, size: CGSize(width: 48, height: 48))
            addShimmer(view: listItem.titleLabel, size: CGSize(width: 120, height: 18))

            let subtitleView = UIView().withoutAutoresizingMaskConstraints()
            subtitleView.pin(anchors: [.height], to: 12)
            subtitleView.pin(anchors: [.width], to: 210)
            subtitleView.roundViewCorners(corner: .init(cornerRadius: 6))
            listItem.set(subtitle: subtitleView)

            addShimmer(view: subtitleView, size: CGSize(width: 210, height: 12))

            return listItem
        }
        return UITableViewCell()
    }
}
