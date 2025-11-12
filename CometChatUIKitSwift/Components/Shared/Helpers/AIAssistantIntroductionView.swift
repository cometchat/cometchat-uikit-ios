//
//  AIAssistantIntroductionView.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 17/09/25.
//

import Foundation
import UIKit

class AIAssistantIntroductionView: UIView {
    
    // MARK: - UI Components
    
    public lazy var avatarView: CometChatAvatar = {
        let avatar = CometChatAvatar(frame: .zero)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        return avatar
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hey, How can I help?"
        label.font = CometChatTypography.Heading4.medium
        label.textAlignment = .center
        label.textColor = CometChatTheme.textColorPrimary
        return label
    }()
    
    public lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "You can ask me anything..."
        label.font = CometChatTypography.Body.regular
        label.textAlignment = .center
        label.textColor = CometChatTheme.textColorTertiary
        return label
    }()
    
    public lazy var labelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()
    
    private lazy var optionsLayout: CenteredCollectionViewFlowLayout = {
        let layout = CenteredCollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = .zero 
        return layout
    }()
    
    public lazy var optionsCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: optionsLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: OptionCell.identifier)
        collectionView.isScrollEnabled = false // expand to fit content
        collectionView.alwaysBounceVertical = false
        return collectionView
    }()
    
    public var options : [String] = []
    
    public var onOptionSelected: ((String) -> Void)?
    
    // Gradient
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setupGradientBackground()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        setupGradientBackground()
        setupLayout()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
//            self.backgroundColor = UIColor.dynamicColor(
//                lightModeColor: CometChatTheme.backgroundColor03.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
//                darkModeColor: CometChatTheme.backgroundColor02.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
//            )
            self.backgroundColor = .clear
        }
    }
    
    // MARK: - Setup
    
    private func setupGradientBackground() {
        let purple = UIColor(hex: "#F4F2FC").cgColor
        gradientLayer.colors = [CometChatTheme.backgroundColor01.cgColor, purple]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupLayout() {
        let mainStack = UIStackView(arrangedSubviews: [avatarView, labelStack, optionsCollectionView])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            avatarView.widthAnchor.constraint(equalToConstant: 60),
            avatarView.heightAnchor.constraint(equalToConstant: 60),
            
            optionsCollectionView.heightAnchor.constraint(equalToConstant: 200), // fixed height
            optionsCollectionView.widthAnchor.constraint(equalTo: mainStack.widthAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    func configure(greetingMessage: String?, introductoryMessage: String?, suggestedMessages: [String]?, hideSuggestedMessages : Bool = false) {
        if let greeting = greetingMessage {
            titleLabel.text = greeting
        }
        if let intro = introductoryMessage {
            subtitleLabel.text = intro
        }
        if let suggestions = suggestedMessages {
            self.options = suggestions
            optionsCollectionView.reloadData()
        }
        if hideSuggestedMessages{
            optionsCollectionView.isHidden = true
        } else {
            optionsCollectionView.isHidden = false
        }
    }
}

// MARK: - Collection View

extension AIAssistantIntroductionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OptionCell.identifier, for: indexPath) as? OptionCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: options[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.onOptionSelected?(options[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = options[indexPath.item]
        let maxWidth = collectionView.bounds.width - 40 // account for insets
        let font = UIFont.systemFont(ofSize: 15, weight: .medium)
        let textRect = (text as NSString).boundingRect(
            with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        let width = min(textRect.width + 40, maxWidth)
        let height = textRect.height + 24 // top + bottom padding from stackView/container
        return CGSize(width: width, height: height)
    }
}

// MARK: - Custom Cell

class OptionCell: UICollectionViewCell {
    static let identifier = "OptionCell"
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Body.regular
        label.textColor = CometChatTheme.textColorSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        imageView.image = UIImage(systemName: "arrow.right", withConfiguration: config)
        imageView.tintColor = CometChatTheme.iconColorSecondary
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = CometChatTheme.backgroundColor01
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = CometChatTheme.borderColorDefault.cgColor
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, arrowImageView])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(with text: String) {
        titleLabel.text = text
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        var frame = layoutAttributes.frame
        frame.size.height = size.height
        frame.size.width = size.width
        layoutAttributes.frame = frame
        return layoutAttributes
    }

}



final class CenteredCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect),
              let collectionView = collectionView else {
            return nil
        }
        
        // Make a copy so we don’t mutate the cached attributes
        let attributesCopy = originalAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        // Group attributes by row (using center.y)
        var rows: [[UICollectionViewLayoutAttributes]] = []
        var currentRowY: CGFloat?
        
        for attr in attributesCopy where attr.representedElementCategory == .cell {
            if let rowY = currentRowY, abs(attr.center.y - rowY) <= 1 {
                rows[rows.count - 1].append(attr)
            } else {
                currentRowY = attr.center.y
                rows.append([attr])
            }
        }
        
        // Center each row horizontally
        let availableWidth = collectionView.bounds.width - (sectionInset.left + sectionInset.right)
        
        for row in rows {
            let rowWidth = row.reduce(0) { $0 + $1.frame.width } + CGFloat(row.count - 1) * minimumInteritemSpacing
            let startX = sectionInset.left + max(0, (availableWidth - rowWidth) / 2.0)
            
            var x = startX
            for attr in row {
                var frame = attr.frame
                frame.origin.x = x
                attr.frame = frame
                x += frame.width + minimumInteritemSpacing
            }
        }
        
        return attributesCopy
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

