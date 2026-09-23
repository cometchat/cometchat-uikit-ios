

#if canImport(UIKit)

import UIKit

public extension MarkdownCode {
  // Left as a literal deliberately: CometChatTheme has no syntax-highlighting token, and
  // the nearest candidates (errorColor, textColorHighlight) carry the wrong meaning.
  // Picking one would encode a design decision nobody has made. Needs a `codeColor` token
  // in the theme first — see Track 1 THEME1.
  static let defaultHighlightColor = UIColor(red: 0.90, green: 0.20, blue: 0.40, alpha: 1.0)
  static let defaultBackgroundColor = CometChatTheme.neutralColor300
  static let defaultFont = UIFont(name: "Menlo-Regular", size: 16)
}

#endif
