//
//  AddNewOptionView.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 16/09/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit
protocol  AddNewOptionDelegate: NSObject {
  func didNewOptionPressed()
}
class AddNewOptionView: UITableViewCell {

    weak var newOptionDelegate: AddNewOptionDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func didAddButtonPressed(_ sender: Any) {
        
        newOptionDelegate?.didNewOptionPressed()
    }
    
}
