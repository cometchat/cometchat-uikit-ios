//
//  ReactionListCollectionCell.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 23/02/24.
//

import UIKit
import Foundation

class ReactionListCollectionCell: UICollectionViewCell {
    
    private var backgroundContainerView = UIView()
    private var purpleBarView = UIView()
    private var reactionLabel = UILabel()
    var reaction: String?
    var count: Int?
    var onTapped: ((_ reaction: String?, _ count: Int?) -> Void)?
    var didSelected = false
    var selectedBackgroundColor: UIColor?
    var selectedTextColor: UIColor?
    var textColor: UIColor?
    var font: UIFont?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        // Clean up the views before reusing
        backgroundContainerView.removeFromSuperview()
        purpleBarView.removeFromSuperview()
        reactionLabel.removeFromSuperview()
    }
    
    func build() {
        // Setting up the main background view
        self.contentView.embed(backgroundContainerView)
        
        // Setting up the purple bar view at the bottom
        purpleBarView = UIView()
        purpleBarView.translatesAutoresizingMaskIntoConstraints = false
        purpleBarView.backgroundColor = didSelected ? selectedBackgroundColor : .clear
        backgroundContainerView.addSubview(purpleBarView)
        
        // Setting up the label to display reaction and count
        reactionLabel = UILabel()
        reactionLabel.translatesAutoresizingMaskIntoConstraints = false
        reactionLabel.textColor = didSelected ? selectedTextColor : textColor
        reactionLabel.font = font
        if let reaction = reaction, let count = count {
            reactionLabel.text = "\(reaction) \(count)"
        }
        reactionLabel.textAlignment = .center
        reactionLabel.adjustsFontSizeToFitWidth = true
        reactionLabel.minimumScaleFactor = 0.5
        backgroundContainerView.addSubview(reactionLabel)
        
        // Adding gesture recognizer for tap action
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didReactionButtonPressed))
        backgroundContainerView.addGestureRecognizer(tapGesture)
        
        // AutoLayout constraints
        NSLayoutConstraint.activate([
            
            // Constraints for the purple bar view (fixed height at the bottom)
            purpleBarView.leadingAnchor.constraint(equalTo: backgroundContainerView.leadingAnchor),
            purpleBarView.trailingAnchor.constraint(equalTo: backgroundContainerView.trailingAnchor),
            purpleBarView.bottomAnchor.constraint(equalTo: backgroundContainerView.bottomAnchor),
            purpleBarView.heightAnchor.constraint(equalToConstant: 3), // Adjust the height as per design
            
            // Constraints for the reaction label (centered inside the background view)
            reactionLabel.centerXAnchor.constraint(equalTo: backgroundContainerView.centerXAnchor),
            reactionLabel.centerYAnchor.constraint(equalTo: backgroundContainerView.centerYAnchor),
            reactionLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundContainerView.leadingAnchor, constant: CometChatSpacing.Spacing.s2),
            reactionLabel.trailingAnchor.constraint(lessThanOrEqualTo: backgroundContainerView.trailingAnchor, constant: -(CometChatSpacing.Spacing.s2))
        ])
    }
    
    @objc func didReactionButtonPressed(_ sender: UIButton) {
        onTapped?(reaction, count)
    }
}
