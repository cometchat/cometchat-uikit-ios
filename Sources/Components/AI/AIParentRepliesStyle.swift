//
//  AIParentRepliesStyle.swift
//  
//
//  Created by SuryanshBisen on 25/09/23.
//

import Foundation

import UIKit

public class AIParentRepliesStyle: NSObject {
    
    private(set) var repliesTextFont: UIFont?
    private(set) var repliesTextBorder: CGFloat?
    private(set) var repliesTextBorderRadius: CGFloat?
    private(set) var repliesTextColor: UIColor?
    private(set) var repliesTextBackground: UIColor?
    private(set) var repliesViewBackgroundColour: UIColor?
    
    private(set) var loadingViewTextFont: UIFont?
    private(set) var loadingViewBorder: CGFloat?
    private(set) var loadingViewBorderRadius: CGFloat?
    private(set) var loadingViewTextColor: UIColor?
    private(set) var loadingViewBackgroundColor: UIColor?
    
    private(set) var errorViewTextFont: UIFont?
    private(set) var errorViewBorder: CGFloat?
    private(set) var errorViewBorderRadius: CGFloat?
    private(set) var errorViewTextColor: UIColor?
    private(set) var errorViewBackgroundColor: UIColor?

    private(set) var emptyViewTextFont: UIFont?
    private(set) var emptyViewBorder: CGFloat?
    private(set) var emptyViewBorderRadius: CGFloat?
    private(set) var emptyViewTextColor: UIColor?
    private(set) var emptyViewBackgroundColor: UIColor?

    private(set) var repliesTableViewSeparatorStyle: UITableViewCell.SeparatorStyle?
    
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
