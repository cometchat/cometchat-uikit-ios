
#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension MarkdownParser {
  static let defaultFont = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
  static let defaultColor = NSColor.black
}

#endif
