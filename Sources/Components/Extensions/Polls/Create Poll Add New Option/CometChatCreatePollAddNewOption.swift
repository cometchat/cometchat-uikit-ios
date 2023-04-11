//
//  CometChatCreatePollAddNewOption.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 16/09/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit
protocol  AddNewOptionDelegate: NSObject {
  func didNewOptionPressed()
}
class CometChatCreatePollAddNewOption: UITableViewCell {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addButtonText: UILabel!
    
    weak var newOptionDelegate: AddNewOptionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addButton.setImage(UIImage(named: "message-composer-plus", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.tintColor = CometChatTheme.palatte.primary
        
        addButtonText.text = "ADD_ANOTHER_ANSWER".localize()
        addButtonText.textColor = CometChatTheme.palatte.primary
        addButtonText.font = CometChatTheme.typography.title2
     
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        addButtonText.addGestureRecognizer(tap)
        addButtonText.isUserInteractionEnabled = true
        backgroundColor = CometChatTheme.palatte.background
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        newOptionDelegate?.didNewOptionPressed()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func didAddButtonPressed(_ sender: Any) {
        
        newOptionDelegate?.didNewOptionPressed()
    }
    
}
