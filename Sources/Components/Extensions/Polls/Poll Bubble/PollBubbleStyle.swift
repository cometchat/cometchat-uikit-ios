//
//  PollBubbleStyle.swift
 
//
//  Created by Abdullah Ansari on 20/05/22.
//

import Foundation
import UIKit

public final class PollBubbleStyle: BaseStyle {
    
    private(set) var pollQuestionTextFont = CometChatTheme.typography.text1
    private(set) var pollQuestionTextColor = CometChatTheme.palatte.accent
    private(set) var pollOptionTextFont = CometChatTheme.typography.text1
    private(set) var pollOptionTextColor = CometChatTheme.palatte.accent
    private(set) var pollOptionBackground = CometChatTheme.palatte.background
    private(set) var selectedPollOptionBackground = CometChatTheme.palatte.primary
    private(set) var votePercentTextFont = CometChatTheme.typography.text1
    private(set) var votePercentTextColor = CometChatTheme.palatte.accent500
    private(set) var totalVoteCountTextFont = CometChatTheme.typography.subtitle1
    private(set) var totalVoteCountTextColor = CometChatTheme.palatte.accent500
    
    @discardableResult
    public func set(pollQuestionTextFont: UIFont) -> Self {
        self.pollQuestionTextFont = pollQuestionTextFont
        return self
    }
    
    @discardableResult
    public func set(pollQuestionTextColor: UIColor) -> Self {
        self.pollQuestionTextColor = pollQuestionTextColor
        return self
    }
    
    @discardableResult
    public func set(pollOptionTextFont: UIFont) -> Self {
        self.pollOptionTextFont = pollOptionTextFont
        return self
    }
    
    @discardableResult
    public func set(pollOptionTextColor: UIColor) -> Self {
        self.pollOptionTextColor = pollOptionTextColor
        return self
    }
    
    @discardableResult
    public func set(votePercentTextFont: UIFont) -> Self {
        self.votePercentTextFont = votePercentTextFont
        return self
    }
    
    @discardableResult
    public func set(votePercentTextColor: UIColor) -> Self {
        self.votePercentTextColor = votePercentTextColor
        return self
    }
    
    @discardableResult
    public func set(totalVoteCountTextFont: UIFont) -> Self {
        self.totalVoteCountTextFont = totalVoteCountTextFont
        return self
    }
    
    @discardableResult
    public func set(totalVoteCountTextColor: UIColor) -> Self {
        self.totalVoteCountTextColor = totalVoteCountTextColor
        return self
    }
    
}
