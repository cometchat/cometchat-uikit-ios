
#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension MarkdownHeader {
  static let defaultFont = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize)
}

#endif
