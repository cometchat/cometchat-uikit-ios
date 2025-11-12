//
//  MarkdownHeader.swift
//  Pods
//
//  Created by Ivan Bruel on 18/07/16.
//
//
import Foundation
import CoreGraphics

open class MarkdownHeader: MarkdownLevelElement {

    fileprivate static let regex = "^(#{1,%@})\\s*(.+)$"

    open var maxLevel: Int
    open var color: MarkdownColor?
    open var fontIncrease: Int
    open var font: MarkdownFont?

    open var regex: String {
        let level: String = maxLevel > 0 ? "\(maxLevel)" : ""
        return String(format: MarkdownHeader.regex, level)
    }

    public init(font: MarkdownFont? = nil,
                maxLevel: Int = 3,
                fontIncrease: Int = 2,
                color: MarkdownColor? = nil) {
        self.maxLevel = maxLevel
        self.font = font
        self.color = color
        self.fontIncrease = fontIncrease
    }

    // ✅ apply header attributes based on # level
    open func formatText(_ attributedString: NSMutableAttributedString, range: NSRange, level: Int) {
        let nsText = attributedString.string as NSString
        let fullText = nsText.substring(with: range)
        let cleanText = fullText.replacingOccurrences(of: "^#{1,}\\s*", with: "", options: .regularExpression)

        let headerFont: UIFont
        switch level {
        case 1:
            headerFont = CometChatTypography.Heading4.bold
        case 2:
            headerFont = CometChatTypography.Body.bold
        default:
            headerFont = CometChatTypography.Body.medium
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: color ?? CometChatTheme.textColorPrimary
        ]

        let styled = NSAttributedString(string: cleanText + "\n", attributes: attributes)
        attributedString.replaceCharacters(in: range, with: styled)
    }

    // Optional but safe to keep — applies level attributes if needed
    open func attributesForLevel(_ level: Int) -> [NSAttributedString.Key: AnyObject] {
        let headerFont: UIFont
        switch level {
        case 1:
            headerFont = CometChatTypography.Heading4.bold
        case 2:
            headerFont = CometChatTypography.Body.bold
        default:
            headerFont = CometChatTypography.Body.medium
        }

        return [
            .font: headerFont,
            .foregroundColor: (color ?? CometChatTheme.textColorPrimary) as AnyObject
        ]
    }
}
