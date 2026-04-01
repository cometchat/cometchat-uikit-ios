//
//  RoundedBackgroundLayoutManager.swift
//  CometChatUIKitSwift
//
//  Custom NSLayoutManager that draws rounded backgrounds with borders for inline code.
//

import UIKit

/// Custom attribute key for inline code rounded background styling
public extension NSAttributedString.Key {
    /// Attribute key for inline code rounded background. Value should be a RoundedBackgroundStyle.
    static let inlineCodeRoundedBackground = NSAttributedString.Key("CometChatInlineCodeRoundedBackground")
}

/// Style configuration for rounded background
public struct RoundedBackgroundStyle {
    public let backgroundColor: UIColor
    public let borderColor: UIColor
    public let borderWidth: CGFloat
    public let cornerRadius: CGFloat
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    
    public init(
        backgroundColor: UIColor,
        borderColor: UIColor,
        borderWidth: CGFloat = 1.0,
        cornerRadius: CGFloat = 6.0,
        horizontalPadding: CGFloat = 4.0,
        verticalPadding: CGFloat = 2.0
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
    }
}

/// Custom NSLayoutManager that draws rounded backgrounds with borders for inline code
public class RoundedBackgroundLayoutManager: NSLayoutManager {
    
    public override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        // First draw the standard backgrounds (but we'll skip our custom ones)
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)
        
        // Then draw our custom rounded backgrounds
        guard let textStorage = textStorage else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let characterRange = self.characterRange(forGlyphRange: glyphsToShow, actualGlyphRange: nil)
        
        // Find all ranges with our custom attribute and group them
        var currentRange: NSRange?
        var currentStyle: RoundedBackgroundStyle?
        
        textStorage.enumerateAttribute(.inlineCodeRoundedBackground, in: characterRange, options: []) { value, range, _ in
            if let style = value as? RoundedBackgroundStyle {
                if currentRange == nil {
                    currentRange = range
                    currentStyle = style
                } else if let existingRange = currentRange,
                          existingRange.location + existingRange.length == range.location {
                    // Extend the current range (consecutive)
                    currentRange = NSRange(location: existingRange.location, length: existingRange.length + range.length)
                } else {
                    // Draw the previous range and start a new one
                    if let rangeToRender = currentRange, let styleToUse = currentStyle {
                        drawRoundedBackground(for: rangeToRender, style: styleToUse, at: origin, in: context)
                    }
                    currentRange = range
                    currentStyle = style
                }
            } else {
                // No attribute - draw any pending range
                if let rangeToRender = currentRange, let styleToUse = currentStyle {
                    drawRoundedBackground(for: rangeToRender, style: styleToUse, at: origin, in: context)
                }
                currentRange = nil
                currentStyle = nil
            }
        }
        
        // Draw any remaining range
        if let rangeToRender = currentRange, let styleToUse = currentStyle {
            drawRoundedBackground(for: rangeToRender, style: styleToUse, at: origin, in: context)
        }
    }
    
    private func drawRoundedBackground(for characterRange: NSRange, style: RoundedBackgroundStyle, at origin: CGPoint, in context: CGContext) {
        guard let textContainer = textContainers.first else { return }
        
        let glyphRange = self.glyphRange(forCharacterRange: characterRange, actualCharacterRange: nil)
        
        // Get the bounding rect for the entire glyph range
        var boundingRect = self.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        // Offset by origin
        boundingRect.origin.x += origin.x
        boundingRect.origin.y += origin.y
        
        // Add padding
        boundingRect = CGRect(
            x: boundingRect.origin.x - style.horizontalPadding,
            y: boundingRect.origin.y - style.verticalPadding,
            width: boundingRect.width + (style.horizontalPadding * 2),
            height: boundingRect.height + (style.verticalPadding * 2)
        )
        
        // Draw the rounded rectangle
        let path = UIBezierPath(roundedRect: boundingRect, cornerRadius: style.cornerRadius)
        
        // Fill background
        context.setFillColor(style.backgroundColor.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        // Draw border
        if style.borderWidth > 0 {
            context.setStrokeColor(style.borderColor.cgColor)
            context.setLineWidth(style.borderWidth)
            context.addPath(path.cgPath)
            context.strokePath()
        }
    }
}
