//
//  PinnedMessagesShimmerView.swift
//  CometChatUIKitSwift
//

import UIKit
import Foundation

open class PinnedMessagesShimmerView: CometChatShimmerView {

    public var cellCount = 10
    var cellCountManager = 0 // for managing cell count internally

    /// Widths cycle so the placeholder reads as a conversation rather than a stack of
    /// identical bars, matching how the real bubbles size to their content.
    private let bubbleWidths: [CGFloat] = [190, 140, 230, 165]

    open override func buildUI() {
        super.buildUI()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PinnedMessagesShimmerCell")
        tableView.separatorStyle = .none
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

    /// A bubble silhouette: incoming rows lead with a 32pt avatar to match
    /// `CometChatMessageBubble`'s avatar column, outgoing rows sit flush right with none.
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PinnedMessagesShimmerCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        cell.selectionStyle = .none

        let bubbleWidth = bubbleWidths[indexPath.row % bubbleWidths.count]
        let bubbleHeight: CGFloat = 44

        let avatar = UIView().withoutAutoresizingMaskConstraints()
        avatar.roundViewCorners(corner: .init(cornerRadius: 16))
        cell.contentView.addSubview(avatar)

        let bubble = UIView().withoutAutoresizingMaskConstraints()
        bubble.roundViewCorners(corner: .init(cornerRadius: CometChatSpacing.Radius.r3))
        cell.contentView.addSubview(bubble)

        // Every real row is left-aligned with an avatar, so the placeholder is too.
        NSLayoutConstraint.activate([
            avatar.widthAnchor.pin(equalToConstant: 32),
            avatar.heightAnchor.pin(equalToConstant: 32),
            avatar.leadingAnchor.pin(equalTo: cell.contentView.leadingAnchor, constant: CometChatSpacing.Padding.p4),
            avatar.topAnchor.pin(equalTo: bubble.topAnchor),

            bubble.widthAnchor.pin(equalToConstant: bubbleWidth),
            bubble.heightAnchor.pin(equalToConstant: bubbleHeight),
            bubble.leadingAnchor.pin(equalTo: avatar.trailingAnchor, constant: CometChatSpacing.Padding.p2),
            bubble.topAnchor.pin(equalTo: cell.contentView.topAnchor, constant: CometChatSpacing.Padding.p2),
            bubble.bottomAnchor.pin(equalTo: cell.contentView.bottomAnchor, constant: -CometChatSpacing.Padding.p2)
        ])

        addShimmer(view: avatar, size: CGSize(width: 32, height: 32))
        addShimmer(view: bubble, size: CGSize(width: bubbleWidth, height: bubbleHeight))

        return cell
    }
}
