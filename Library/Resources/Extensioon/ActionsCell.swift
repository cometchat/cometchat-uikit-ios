//
//  ActionsCell.swift
//  Heartbeat Messenger
//
//  Created by Pushpsen on 30/04/20.
//  Copyright © 2020 pushpsen airekar. All rights reserved.
//

import UIKit

class ActionsCell: UITableViewCell {

    var presentable = ActionPresentable(name: "", icon: UIImage(named: "more", in: UIKitSettings.bundle, compatibleWith: nil)!)
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var fullScreenSwitch: UISwitch!
    @IBOutlet weak var badgeCountSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
        if let fullScreen = UserDefaults.standard.value(forKey: "fullScreen") as? Int{
            if fullScreen == 1 {
                fullScreenSwitch.setOn(true, animated: true)
            }else{
                fullScreenSwitch.setOn(false, animated: true)
            }
        }else{
            fullScreenSwitch.setOn(false, animated: true)
        }
        
        if let badgeCount = UserDefaults.standard.value(forKey: "badgeCount") as? Int{
            if badgeCount == 1 {
                badgeCountSwitch.setOn(true, animated: true)
            }else{
                badgeCountSwitch.setOn(false, animated: true)
            }
        }else{
            badgeCountSwitch.setOn(false, animated: true)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
        // Configure the view for the selected state
    }
    
    func configure(with presentable: ActionPresentable) {
           self.presentable = presentable
           name.text = presentable.name
           icon.image = presentable.icon
    }
    
    @IBAction func fullScreenSwitchPressed(_ sender: Any) {
     if let fullScreen = UserDefaults.standard.value(forKey: "fullScreen") as? Int{
        if fullScreen == 1 {
            fullScreenSwitch.setOn(false, animated: true)
            UserDefaults.standard.set(0, forKey: "fullScreen")
        }
        if fullScreen == 0 {
            fullScreenSwitch.setOn(true, animated: true)
            UserDefaults.standard.set(1, forKey: "fullScreen")
        }
     }else{
        fullScreenSwitch.setOn(false, animated: true)
        UserDefaults.standard.set(0, forKey: "fullScreen")
        }
    }
    
    @IBAction func badgeCountSwitchPressed(_ sender: Any) {
        if let badgeCount = UserDefaults.standard.value(forKey: "badgeCount") as? Int{
           if badgeCount == 1 {
               badgeCountSwitch.setOn(false, animated: true)
               UserDefaults.standard.set(0, forKey: "badgeCount")
           }
           if badgeCount == 0 {
               badgeCountSwitch.setOn(true, animated: true)
               UserDefaults.standard.set(1, forKey: "badgeCount")
           }
        }else{
           badgeCountSwitch.setOn(false, animated: true)
           UserDefaults.standard.set(0, forKey: "badgeCount")
           }
    }
}
