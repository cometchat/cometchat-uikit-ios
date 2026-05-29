//
//  NotificationFeedItemCell.swift
//  CometChatUIKitSwift
//
//  Created by CometChat on 14/05/26.
//

import UIKit
import CometChatSDK
import CometChatCardsSwift

public class NotificationFeedItemCell: UITableViewCell {
    
    public static let identifier = "NotificationFeedItemCell"
    
    // MARK: - UI Elements
    
    /// The CometChatCardView renders the Card_Schema JSON natively
    private var cardView: CometChatCardView?
    
    /// Container that wraps the card view with padding
    private lazy var cardContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = false
        return view
    }()
    
    // MARK: - Properties
    var style: NotificationFeedStyle = NotificationFeedStyle()
    var onCardAction: ((_ actionEvent: CometChatCardActionEvent) -> Void)?
    
    /// Called when the card's content size changes (accordion expand/collapse).
    /// The controller should clear any cached height for this cell.
    var onContentSizeChanged: (() -> Void)?
    
    private var currentCardJson: String?
    private var contentSizeObserver: NSObjectProtocol?
    
    /// The current height the cell should be, based on the card view's bounds
    var currentCellHeight: CGFloat {
        guard let cardView = cardView, cardView.bounds.height > 0 else { return 0 }
        return cardView.bounds.height + 16 // 8pt top + 8pt bottom padding
    }
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    // MARK: - Build UI
    private func buildUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // iOS 26 adds a default background layer to cells — remove it
        if #available(iOS 26, *) {
            var bgConfig = UIBackgroundConfiguration.clear()
            backgroundConfiguration = bgConfig
        }
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false
        clipsToBounds = false
        
        contentView.addSubview(cardContainer)
        
        // Card container: 16px horizontal padding, 8px vertical (per Figma)
        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure
    func configure(with item: NotificationFeedItem, relativeTime: String, style: NotificationFeedStyle) {
        self.style = style
        
        // Convert content dictionary to JSON string for CometChatCardView
        let cardJson = convertContentToJsonString(item.content)
        
        // Only recreate the card view if the JSON changed
        if cardJson != currentCardJson {
            currentCardJson = cardJson
            setupCardView(with: cardJson)
        }
    }
    
    private func convertContentToJsonString(_ content: [String: Any]) -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: content, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }
        return jsonString
    }
    
    private func setupCardView(with cardJson: String) {
        // Remove existing observer and card view
        removeContentSizeObserver()
        cardView?.removeFromSuperview()
        cardView = nil
        
        // Create new CometChatCardView
        let newCardView = CometChatCardView(frame: .zero)
        newCardView.translatesAutoresizingMaskIntoConstraints = false
        newCardView.clipsToBounds = false
        newCardView.themeMode = .auto
        
        // Set action callback BEFORE cardJson — rendering captures the callback at parse time
        newCardView.actionCallback = { [weak self] actionEvent in
            self?.onCardAction?(actionEvent)
        }
        
        // Now set cardJson — this triggers render with the callback already in place
        newCardView.cardJson = cardJson
        
        cardContainer.addSubview(newCardView)
        
        NSLayoutConstraint.activate([
            newCardView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            newCardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            newCardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            newCardView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor)
        ])
        
        cardView = newCardView
        
        // Observe contentSizeDidChangeNotification from the framework.
        // This fires BEFORE the framework calls beginUpdates/endUpdates on the table view.
        // We use it to clear the cached height so heightForRowAt returns automaticDimension.
        contentSizeObserver = NotificationCenter.default.addObserver(
            forName: CometChatCardView.contentSizeDidChangeNotification,
            object: newCardView,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            // Notify the controller to clear cached height for this cell
            self.onContentSizeChanged?()
        }
    }
    
    // MARK: - Size Fitting
    
    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        // CometChatCardView now reports intrinsicContentSize after the framework update.
        // Let auto layout handle it naturally.
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        return size
    }
    
    // MARK: - Cleanup
    
    private func removeContentSizeObserver() {
        if let observer = contentSizeObserver {
            NotificationCenter.default.removeObserver(observer)
            contentSizeObserver = nil
        }
    }
    
    // MARK: - Reuse
    public override func prepareForReuse() {
        super.prepareForReuse()
        removeContentSizeObserver()
        cardView?.removeFromSuperview()
        cardView = nil
        currentCardJson = nil
        onCardAction = nil
        onContentSizeChanged = nil
    }
    
    deinit {
        removeContentSizeObserver()
    }
}
