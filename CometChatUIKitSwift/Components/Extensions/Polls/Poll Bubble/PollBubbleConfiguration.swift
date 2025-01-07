//
//  PollBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class PollBubbleConfiguration {

    private(set) var voteIconURL: String?
    private(set) var style: PollBubbleStyle?
    
    @discardableResult
    public func set(style: PollBubbleStyle) -> PollBubbleConfiguration {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(voteIconURL: String) -> PollBubbleConfiguration {
        self.voteIconURL = voteIconURL
        return self
    }
    
}
