//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 15/11/22.
//

import Foundation
import UIKit

public class ListItemOption: CometChatOption {
    
}


public final class ListItemStyle: BaseStyle {

    private(set) var titleColor = CometChatTheme.palatte.accent900
    private(set) var titleFont = CometChatTheme.typography.title2
    
  ///TODO: - required to find better way because it will change the cornerRadius of listitem every where
  override  var cornerRadius: CometChatCornerStyle  {
        get {
            CometChatCornerStyle(cornerRadius: 0)
        }
        set {}
    }

  
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
}
