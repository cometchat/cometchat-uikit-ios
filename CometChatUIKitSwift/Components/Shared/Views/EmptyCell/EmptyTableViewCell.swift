//
//  EmptyTableViewCell.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 30/11/23.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    @IBOutlet weak var baseContainerView: UIStackView!
    
    static let identifier = "EmptyTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        baseContainerView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.baseContainerView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    @discardableResult
    public func set(customView: UIView) -> Self {
        baseContainerView.addArrangedSubview(customView)
        return self
    }
}
