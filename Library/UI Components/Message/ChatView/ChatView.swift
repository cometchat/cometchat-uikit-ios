
//  ChatView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import Foundation
import CometChatPro


// MARK: - Declaration of Protocol

  protocol ChatViewInternalDelegate: AnyObject {
    func didMicrophoneButtonPressed(with: UILongPressGestureRecognizer)
    func didSendButtonPressed()
    func didAttachmentButtonPressed()
    func didReactionButtonPressed()
}

/*  ----------------------------------------------------------------------------------------- */

@IBDesignable open class ChatView:UIView
{
    
      // MARK: - Declaration of Variables
    
    var view:UIView!
    weak var internalDelegate: ChatViewInternalDelegate?
    
     // MARK: - Declaration of IBOutlet
    @IBOutlet weak var attachment: UIView!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var microphone: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var reaction: UIButton!
    
    // MARK: - Initialization of required Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
   
    required  public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
        
    }
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ChatView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
        self.addSubview(view);
        
    }
    
    
    /// This method triggers when microphone button pressed
    /// - Parameter sender: This specifies the sender Object
    @IBAction func microphoneButtonPressed(_ sender: Any) {
        
        
    }
    
    /// This method triggers when send button pressed
       /// - Parameter sender: This specifies the sender Object
    @IBAction func sendButtonPressed(_ sender: Any) {
        internalDelegate?.didSendButtonPressed()
    }
    
    /// This method triggers when sticker button pressed
    /// - Parameter sender: This specifies the sender Object
    @IBAction func reactionButtonPressed(_ sender: Any) {
        internalDelegate?.didReactionButtonPressed()
    }
    
    /// This method triggers when attchment button pressed
    /// - Parameter sender: This specifies the sender Object
    @IBAction func attachmentButtonPressed(_ sender: Any) {
        internalDelegate?.didAttachmentButtonPressed()
    }
    
}

