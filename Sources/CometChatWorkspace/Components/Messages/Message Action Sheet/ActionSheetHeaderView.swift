//
//  ActionSheetHeaderView.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 08/11/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro


protocol ActionSheetHeaderViewDelegate: NSObject {

    func didCloseButtonPressed()
    func didChangeLayoutPressed()

}

@objc @IBDesignable class ActionSheetHeaderView: UIView , NibLoadable {
  
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var layoutMode: UIButton!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var background: CometChatGradientView!
    
    var currentUser: User?
    var currentGroup: Group?
    var controller: UIViewController?
    
    weak var actionSheetHeaderViewDelegate: ActionSheetHeaderViewDelegate?

    // MARK: - Initialization of required Methods
    
    override init(frame: CGRect) {
      super.init(frame: UIScreen.main.bounds)
      commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      commonInit()
    }
    
    override func reloadInputViews() {
     
        
    }
    
    private func commonInit() {
      Bundle.module.loadNibNamed("ActionSheetHeaderView", owner: self, options: nil)
      addSubview(contentView)
      contentView.frame = bounds
        background.backgroundColor = CometChatActionSheet.backgroundColor
      contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let image = UIImage(named: "actionsheet-change-layout.png")?.withRenderingMode(.alwaysTemplate)
        layoutMode.setImage(image, for: .normal)
        layoutMode.tintColor = .white
        close.isHidden = true
    }

    
    @discardableResult
    public func set(backgroundColor: [Any]?) ->  ActionSheetHeaderView {
        if let backgroundColors = backgroundColor as? [CGColor] {
            if backgroundColors.count == 1 {
                background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                background.set(backgroundColorWithGradient: backgroundColor)
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func set(controller: UIViewController) -> ActionSheetHeaderView {
        self.controller = controller
        return self
    }
    
    @discardableResult
    @objc public func set(title: String) -> ActionSheetHeaderView {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> ActionSheetHeaderView {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> ActionSheetHeaderView {
        self.title.textColor = titleColor
        return self
    }
    
  
    
    @IBAction func didChangeLayoutPressed(_ sender: Any) {
        actionSheetHeaderViewDelegate?.didChangeLayoutPressed()
    }
    
    @IBAction func didCloseButtonPressed(_ sender: Any) {
        actionSheetHeaderViewDelegate?.didCloseButtonPressed()
     
    }
    
    
}


