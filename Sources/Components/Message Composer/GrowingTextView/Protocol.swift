//
//  Protocol.swift
//  GrowingTextView
//
//  Created by Xin Hong on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

@objc protocol GrowingTextViewDelegate: NSObjectProtocol {
    @objc optional func growingTextViewShouldBeginEditing(_ growingTextView: GrowingTextView) -> Bool
    @objc optional func growingTextViewShouldEndEditing(_ growingTextView: GrowingTextView) -> Bool

    @objc optional func growingTextViewDidBeginEditing(_ growingTextView: GrowingTextView)
    @objc optional func growingTextViewDidEndEditing(_ growingTextView: GrowingTextView)

    @objc optional func growingTextView(_ growingTextView: GrowingTextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    @objc optional func growingTextViewDidChange(_ growingTextView: GrowingTextView)
    @objc optional func growingTextViewDidChangeSelection(_ growingTextView: GrowingTextView)

    @objc optional func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat)
    @objc optional func growingTextView(_ growingTextView: GrowingTextView, didChangeHeight height: CGFloat, difference: CGFloat)

    @objc optional func growingTextViewShouldReturn(_ growingTextView: GrowingTextView) -> Bool
}

internal struct DelegateSelectors {
    static let shouldBeginEditing = #selector(GrowingTextViewDelegate.growingTextViewShouldBeginEditing(_:))
    static let shouldEndEditing = #selector(GrowingTextViewDelegate.growingTextViewShouldEndEditing(_:))
    static let didBeginEditing = #selector(GrowingTextViewDelegate.growingTextViewDidBeginEditing(_:))
    static let didEndEditing = #selector(GrowingTextViewDelegate.growingTextViewDidEndEditing(_:))
    static let shouldChangeText = #selector(GrowingTextViewDelegate.growingTextView(_:shouldChangeTextInRange:replacementText:))
    static let didChange = #selector(GrowingTextViewDelegate.growingTextViewDidChange(_:))
    static let didChangeSelection = #selector(GrowingTextViewDelegate.growingTextViewDidChangeSelection(_:))
    static let willChangeHeight = #selector(GrowingTextViewDelegate.growingTextView(_:willChangeHeight:difference:))
    static let didChangeHeight = #selector(GrowingTextViewDelegate.growingTextView(_:didChangeHeight:difference:))
    static let shouldReturn = #selector(GrowingTextViewDelegate.growingTextViewShouldReturn(_:))
}
