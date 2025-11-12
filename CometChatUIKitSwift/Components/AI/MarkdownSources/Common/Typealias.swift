

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public typealias MarkdownFont = NSFont
public typealias MarkdownColor = NSColor

public typealias NSMutableParagraphStyle = AppKit.NSMutableParagraphStyle
public typealias NSUnderlineStyle = AppKit.NSUnderlineStyle

#elseif canImport(UIKit)

import UIKit

public typealias MarkdownFont = UIFont
public typealias MarkdownColor = UIColor

public typealias NSMutableParagraphStyle = UIKit.NSMutableParagraphStyle
public typealias NSUnderlineStyle = UIKit.NSUnderlineStyle

#endif
