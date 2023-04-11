//
//  CreatePollStyle.swift
//  
//
//  Created by Abdullah Ansari on 26/09/22.
//

import UIKit

public final class CreatePollStyle: BaseStyle {

    private(set) var titleFont = CometChatTheme.typography.title2
    private(set) var titleColor = CometChatTheme.palatte.accent
    private(set) var questionPlaceholderColor = CometChatTheme.palatte.accent500
    private(set) var questionPlaceholderFont = CometChatTheme.typography.text1
    private(set) var questionTextColor = CometChatTheme.palatte.accent
    private(set) var questionTextFont = CometChatTheme.typography.text1
    private(set) var answerPlaceholderColor = CometChatTheme.palatte.accent500
    private(set) var answerPlaceholderFont = CometChatTheme.typography.text1
    private(set) var answerTextColor = CometChatTheme.palatte.accent
    private(set) var answerTextFont = CometChatTheme.typography.text1
    private(set) var questionInputBoxCornerRadius: CGFloat = 10.0
    private(set) var questionInputBoxBackground = CometChatTheme.palatte.background
    private(set) var answerInputBoxCornerRadius: CGFloat = 10.0
    private(set) var answerInputBoxBackground = CometChatTheme.palatte.background
    private(set) var cancelButtonColor = CometChatTheme.palatte.primary
    private(set) var cancelButtonFont = CometChatTheme.typography.text1
    private(set) var errorTextFont = CometChatTheme.typography.text1
    private(set) var errorTextColor = CometChatTheme.palatte.accent
    private(set) var addAnswerIconTint = CometChatTheme.palatte.primary
    private(set) var addAnswerButtonTextColor = CometChatTheme.palatte.primary
    private(set) var addAnswerButtonTextFont = CometChatTheme.typography.text1
    private(set) var createPollButtonTextColor = CometChatTheme.palatte.primary
    private(set) var createPollButtonTextFont = CometChatTheme.typography.text1

    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(questionPlaceholderColor: UIColor) -> Self {
        self.questionPlaceholderColor = questionPlaceholderColor
        return self
    }
    
    @discardableResult
    public func set(questionPlaceholderFont: UIFont) -> Self {
        self.questionPlaceholderFont = questionPlaceholderFont
        return self
    }
    
    @discardableResult
    public func set(questionTextColor: UIColor) -> Self {
        self.questionTextColor = questionTextColor
        return self
    }
    
    @discardableResult
    public func set(questionTextFont: UIFont) -> Self {
        self.questionTextFont = questionTextFont
        return self
    }
    
    @discardableResult
    public func set(answerPlaceholderColor: UIColor) -> Self {
        self.answerPlaceholderColor = answerPlaceholderColor
        return self
    }
    
    @discardableResult
    public func set(answerPlaceholderFont: UIFont) -> Self {
        self.answerPlaceholderFont = answerPlaceholderFont
        return self
    }
    
    @discardableResult
    public func set(answerTextColor: UIColor) -> Self {
        self.answerTextColor = answerTextColor
        return self
    }
    
    @discardableResult
    public func set(answerTextFont: UIFont) -> Self {
        self.answerTextFont = answerTextFont
        return self
    }
    
    @discardableResult
    public func set(questionInputBoxCornerRadius: CGFloat) -> Self {
        self.questionInputBoxCornerRadius = questionInputBoxCornerRadius
        return self
    }
    
    @discardableResult
    public func set(answerInputBoxCornerRadius: CGFloat) -> Self {
        self.answerInputBoxCornerRadius = answerInputBoxCornerRadius
        return self
    }
    
    
    @discardableResult
    public func set(cancelButtonColor: UIColor) -> Self {
        self.cancelButtonColor = cancelButtonColor
        return self
    }
    
    @discardableResult
    public func set(cancelButtonFont: UIFont) -> Self {
        self.cancelButtonFont = cancelButtonFont
        return self
    }
    
    @discardableResult
    public func set(errorTextFont: UIFont) -> Self {
        self.errorTextFont = errorTextFont
        return self
    }
    
    @discardableResult
    public func set(errorTextColor: UIColor) -> Self {
        self.errorTextColor = errorTextColor
        return self
    }
    @discardableResult
    public func set(addAnswerIconTint: UIColor) -> Self {
        self.addAnswerIconTint = addAnswerIconTint
        return self
    }
    
    @discardableResult
    public func set(addAnswerButtonTextFont: UIFont) -> Self {
        self.addAnswerButtonTextFont = addAnswerButtonTextFont
        return self
    }
    
    @discardableResult
    public func set(createPollButtonTextColor: UIColor) -> Self {
        self.createPollButtonTextColor = createPollButtonTextColor
        return self
    }
    
    @discardableResult
    public func set(createPollButtonTextFont: UIFont) -> Self {
        self.createPollButtonTextFont = createPollButtonTextFont
        return self
    }
    
}


