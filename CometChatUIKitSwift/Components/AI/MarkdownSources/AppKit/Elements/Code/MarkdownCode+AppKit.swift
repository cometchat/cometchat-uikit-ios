
#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension MarkdownCode {
  static let defaultHighlightColor = MarkdownColor(red: 0.90, green: 0.20, blue: 0.40, alpha: 1.0)
  static let defaultBackgroundColor = MarkdownColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
  static let defaultFont = MarkdownFont(name: "Menlo-Regular", size: 16)
}

#endif
