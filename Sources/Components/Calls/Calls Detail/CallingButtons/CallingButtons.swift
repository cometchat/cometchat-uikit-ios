//
//  CallingButtons.swift
//  
//
//  Created by Ajay Verma on 07/03/23.
//

import Foundation
import CometChatSDK
import UIKit

public class CallingButtons: UIView {
    
    //MARK: OUTLETS
    @IBOutlet weak var audioView: UIView!
    @IBOutlet weak var audioLabel: UILabel!
    @IBOutlet weak var audioImage: UIImageView!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoImage: UIImageView!
    @IBOutlet weak var videoLabel: UILabel!
    
    
    // MARK: - Initialization of required Methods
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = self.bounds
            self.addSubview(contentView)
        }
        setupAppearance()
    }
    
    func setupAppearance() {
        audioView.backgroundColor = CometChatTheme.palatte.background
        audioImage.image = audioImage.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        audioImage.tintColor = CometChatTheme.palatte.primary
        audioLabel.textColor = CometChatTheme.palatte.primary
        audioLabel.font = CometChatTheme.typography.subtitle2
        
        videoView.backgroundColor = CometChatTheme.palatte.background
        videoImage.image = videoImage.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        videoImage.tintColor = CometChatTheme.palatte.primary
        videoLabel.textColor = CometChatTheme.palatte.primary
        videoLabel.font = CometChatTheme.typography.subtitle2
    }
    
    public func set(user: User) {}
    
    public func set(group: Group) {}
    
    //MARK: ACTIONS
    @IBAction func didAudioCallPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func didVideoCallPressed(_ sender: UIButton) {
        
    }
    
    
}
