
#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

public extension MarkdownFont {
  func italic() -> MarkdownFont {
    return NSFontManager().convert(self, toHaveTrait: NSFontTraitMask.italicFontMask)
  }
  
  func bold() -> MarkdownFont {
    return NSFontManager().convert(self, toHaveTrait: NSFontTraitMask.boldFontMask)
  }

  func isItalic() -> Bool {
    return NSFontManager().traits(of: self).contains(.italicFontMask)
  }

  func isBold() -> Bool {
    return NSFontManager().traits(of: self).contains(.boldFontMask)
  }
  
  func withSize(_ size: CGFloat) -> NSFont {
    return NSFontManager().convert(self, toSize: size)
  }
}

#endif
