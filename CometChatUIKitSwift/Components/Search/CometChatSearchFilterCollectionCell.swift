//
//  CometChatSearchFilterCollectionCell.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 06/08/25.
//

import Foundation
import UIKit

class FilterCell: UICollectionViewCell {
    static let reuseIdentifier = "FilterCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let stack = UIStackView()

    override var isSelected: Bool {
        didSet {
            updateSelectionAppearance()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16.5
        contentView.layer.masksToBounds = true

        iconView.tintColor = CometChatTheme.iconColorSecondary
        iconView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = CometChatTheme.textColorSecondary
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(CometChatSpacing.Padding.p3)),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 33)
        ])
        
        updateSelectionAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: FilterItem, isSelected: Bool) {
        iconView.image = UIImage(systemName: item.iconName)
        titleLabel.text = item.title
        self.isSelected = isSelected
        updateSelectionAppearance()
    }

    private func updateSelectionAppearance() {
        if isSelected {
            contentView.backgroundColor = CometChatTheme.extendedPrimaryColor100
            titleLabel.textColor = CometChatTheme.textColorHighlight
            iconView.tintColor = CometChatTheme.iconColorHighlight
            contentView.borderWith(width: 1)
            contentView.borderColor(color: CometChatTheme.extendedPrimaryColor200)
        } else {
            contentView.backgroundColor = CometChatTheme.backgroundColor03
            titleLabel.textColor = CometChatTheme.textColorSecondary
            iconView.tintColor = CometChatTheme.iconColorSecondary
            contentView.borderWith(width: 0)
            contentView.borderColor(color: .clear)
        }
    }
}


class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0

        attributes?.forEach { layoutAttribute in
            if layoutAttribute.representedElementCategory == .cell {
                if layoutAttribute.frame.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }
        return attributes
    }
}
