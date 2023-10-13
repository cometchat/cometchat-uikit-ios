//
//  AIParentRepliesStyle.swift
//  
//
//  Created by SuryanshBisen on 25/09/23.
//

import Foundation

import UIKit

public class AIParentRepliesStyle: NSObject {
    
    var repliesTextFont: UIFont?
    var repliesTextBorder: CGFloat?
    var repliesTextBorderRadius: CGFloat?
    var repliesTextColor: UIColor?
    var repliesTextBackground: UIColor?
    var repliesViewBackgroundColour: UIColor?
    
    var loadingViewTextFont: UIFont?
    var loadingViewBorder: CGFloat?
    var loadingViewBorderRadius: CGFloat?
    var loadingViewTextColor: UIColor?
    var loadingViewBackgroundColor: UIColor?
    
    var errorViewTextFont: UIFont?
    var errorViewBorder: CGFloat?
    var errorViewBorderRadius: CGFloat?
    var errorViewTextColor: UIColor?
    var errorViewBackgroundColor: UIColor?

    var emptyViewTextFont: UIFont?
    var emptyViewBorder: CGFloat?
    var emptyViewBorderRadius: CGFloat?
    var emptyViewTextColor: UIColor?
    var emptyViewBackgroundColor: UIColor?

    var repliesTableViewSeparatorStyle: UITableViewCell.SeparatorStyle?
    
    @discardableResult
    @objc public func set(repliesTextFont: UIFont) -> Self {
        self.repliesTextFont = repliesTextFont
        return self
    }
    
    @discardableResult
    @objc public func set(repliesTextBorder: CGFloat) -> Self {
        self.repliesTextBorder = repliesTextBorder
        return self
    }
    
    @discardableResult
    @objc public func set(repliesTextBorderRadius: CGFloat) -> Self {
        self.repliesTextBorderRadius = repliesTextBorderRadius
        return self
    }
    
    @discardableResult
    @objc public func set(repliesTextColor: UIColor) -> Self {
        self.repliesTextColor = repliesTextColor
        return self
    }
    
    @discardableResult
    @objc public func set(repliesTextBackgroundColour: UIColor) -> Self {
        self.repliesTextBackground = repliesTextBackgroundColour
        return self
    }
    
    @discardableResult
    @objc public func set(loadingViewTextFont: UIFont) -> Self {
        self.loadingViewTextFont = loadingViewTextFont
        return self
    }
    
    @discardableResult
    @objc public func set(loadingViewBorder: CGFloat) -> Self {
        self.loadingViewBorder = loadingViewBorder
        return self
    }
    
    @discardableResult
    @objc public func set(loadingViewBorderRadius: CGFloat) -> Self {
        self.loadingViewBorderRadius = loadingViewBorderRadius
        return self
    }
    
    @discardableResult
    @objc public func set(loadingViewTextColor: UIColor) -> Self {
        self.loadingViewTextColor = loadingViewTextColor
        return self
    }
    
    @discardableResult
    @objc public func set(loadingViewBackgroundColor: UIColor) -> Self {
        self.loadingViewBackgroundColor = loadingViewBackgroundColor
        return self
    }
    
    @discardableResult
    @objc public func set(errorViewTextFont: UIFont) -> Self {
        self.errorViewTextFont = errorViewTextFont
        return self
    }
    
    @discardableResult
    @objc public func set(errorViewTextBorder: CGFloat) -> Self {
        self.errorViewBorder = errorViewTextBorder
        return self
    }
    
    @discardableResult
    @objc public func set(errorViewTextBorderRadius: CGFloat) -> Self {
        self.errorViewBorderRadius = errorViewTextBorderRadius
        return self
    }
    
    @discardableResult
    @objc public func set(errorTextColor: UIColor) -> Self {
        self.errorViewTextColor = errorTextColor
        return self
    }
    
    @discardableResult
    @objc public func set(errorViewBackgroundColor: UIColor) -> Self {
        self.errorViewBackgroundColor = errorViewBackgroundColor
        return self
    }
    
    @discardableResult
    @objc public func set(repliesViewBackgroundColour: UIColor) -> Self {
        self.repliesViewBackgroundColour = repliesViewBackgroundColour
        return self
    }
    
    @discardableResult
    @objc public func set(repliesTableViewSeparatorStyle: UITableViewCell.SeparatorStyle) -> Self {
        self.repliesTableViewSeparatorStyle = repliesTableViewSeparatorStyle
        return self
    }
    
    

}
