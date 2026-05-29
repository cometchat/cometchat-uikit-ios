//
//  NotificationFeedFilterChipsView.swift
//  CometChatUIKitSwift
//
//  Created by CometChat on 14/05/26.
//

import UIKit
import CometChatSDK

public struct FilterChipData {
    public let id: String
    public let label: String
    public var isActive: Bool
    public var unreadCount: Int
}

public class NotificationFeedFilterChipsView: UIView {
    
    // MARK: - Properties
    private var chips: [FilterChipData] = []
    var onChipSelected: ((String?) -> Void)?
    var style: NotificationFeedStyle = NotificationFeedStyle()
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
    }
    
    // MARK: - Build UI
    private func buildUI() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        let trailingConstraint = stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16)
        trailingConstraint.priority = .defaultLow // Don't stretch chips to fill
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 50),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            trailingConstraint,
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -8),
            stackView.heightAnchor.constraint(equalToConstant: 34),
            
            // Key: stack view height matches scroll view content height
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -16)
        ])
    }
    
    // MARK: - Update Chips
    func updateChips(categories: [NotificationCategory], activeCategory: String?, unreadCounts: [String: Int], totalUnreadCount: Int) {
        var chipData: [FilterChipData] = []
        
        // "All" chip is always first
        chipData.append(FilterChipData(
            id: "all",
            label: "All",
            isActive: activeCategory == nil,
            unreadCount: totalUnreadCount
        ))
        
        // Category chips
        for category in categories {
            chipData.append(FilterChipData(
                id: category.label,  // Use label/name for filtering
                label: category.label,
                isActive: activeCategory == category.label,
                unreadCount: unreadCounts[category.label] ?? 0
            ))
        }
        
        self.chips = chipData
        renderChips()
    }
    
    private func renderChips() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for (index, chip) in chips.enumerated() {
            let chipView = createChipView(for: chip, index: index)
            stackView.addArrangedSubview(chipView)
        }
    }
    
    private func createChipView(for chip: FilterChipData, index: Int) -> UIView {
        // Use a simple approach: UIView with explicit width calculated from text
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Calculate the exact width needed
        let font = CometChatTypography.Body.bold
        let labelText = chip.label
        let textSize = (labelText as NSString).size(withAttributes: [.font: font])
        let padding: CGFloat = 24 // 12 left + 12 right
        
        // Badge width calculation
        var badgeWidth: CGFloat = 0
        if chip.unreadCount > 0 {
            let badgeText = "\(chip.unreadCount)"
            let badgeFont = CometChatTypography.Caption1.medium
            let badgeTextSize = (badgeText as NSString).size(withAttributes: [.font: badgeFont])
            badgeWidth = max(ceil(badgeTextSize.width) + 12, 20) + 8 // badge + spacing
        }
        
        let totalWidth = ceil(textSize.width) + padding + badgeWidth
        
        // Styling
        if chip.isActive {
            container.backgroundColor = CometChatTheme.primaryColor
            container.layer.borderWidth = 0
        } else {
            container.backgroundColor = CometChatTheme.backgroundColor01
            container.layer.borderWidth = 1
            container.layer.borderColor = CometChatTheme.borderColorDefault.cgColor
        }
        container.layer.cornerRadius = 17
        container.clipsToBounds = true
        
        // Explicit size
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 34),
            container.widthAnchor.constraint(equalToConstant: totalWidth)
        ])
        
        // Inner stack
        let innerStack = UIStackView()
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        innerStack.axis = .horizontal
        innerStack.spacing = 6
        innerStack.alignment = .center
        container.addSubview(innerStack)
        
        NSLayoutConstraint.activate([
            innerStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            innerStack.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        // Label
        let label = UILabel()
        label.text = labelText
        label.font = font
        label.textColor = chip.isActive ? .white : CometChatTheme.textColorSecondary
        innerStack.addArrangedSubview(label)
        
        // Badge (unread count)
        if chip.unreadCount > 0 {
            let badge: UIView
            if chip.isActive {
                badge = createActiveBadge(count: chip.unreadCount)
            } else {
                badge = createInactiveBadge(count: chip.unreadCount)
            }
            innerStack.addArrangedSubview(badge)
        }
        
        // Tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(chipTapped(_:)))
        container.addGestureRecognizer(tap)
        container.tag = index
        container.isUserInteractionEnabled = true
        
        return container
    }
    
    /// Active chip badge: light purple bg (#F4F3FF), purple border (#D9D6FE), purple text (#5925DC)
    private func createActiveBadge(count: Int) -> UIView {
        let badgeContainer = UIView()
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.backgroundColor = UIColor(hex: "#F4F3FF")
        badgeContainer.layer.borderWidth = 1
        badgeContainer.layer.borderColor = UIColor(hex: "#D9D6FE").cgColor
        badgeContainer.layer.cornerRadius = 10
        badgeContainer.clipsToBounds = true
        
        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.text = "\(count)"
        badgeLabel.font = CometChatTypography.Caption1.medium
        badgeLabel.textColor = UIColor(hex: "#5925DC")
        badgeLabel.textAlignment = .center
        
        badgeContainer.addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: badgeContainer.topAnchor, constant: 2),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeContainer.bottomAnchor, constant: -2),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 6),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -6)
        ])
        
        return badgeContainer
    }
    
    /// Inactive chip badge: dark gray bg (#535862), white text
    private func createInactiveBadge(count: Int) -> UIView {
        let badgeContainer = UIView()
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.backgroundColor = UIColor(hex: "#535862")
        badgeContainer.layer.cornerRadius = 10
        badgeContainer.clipsToBounds = true
        
        let badgeLabel = UILabel()
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.text = "\(count)"
        badgeLabel.font = CometChatTypography.Caption1.medium
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        
        badgeContainer.addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: badgeContainer.topAnchor, constant: 2),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeContainer.bottomAnchor, constant: -2),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 6),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -6)
        ])
        
        return badgeContainer
    }
    
    @objc private func chipTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        guard index < chips.count else { return }
        let chip = chips[index]
        
        if chip.id == "all" {
            onChipSelected?(nil)
        } else {
            onChipSelected?(chip.id)
        }
    }
}
