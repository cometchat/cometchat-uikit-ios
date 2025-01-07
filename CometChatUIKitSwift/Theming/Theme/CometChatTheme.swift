//
//  CometChatTheme.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 27/08/24.
//

import Foundation
import UIKit

class CometChatThemeHelper {
    static var defaultPrimaryLightColor = UIColor(hex: "#6852D6")
    static var defaultPrimaryDarkColor = UIColor(hex: "#6852D6")
}

public class CometChatTheme {

    //MARK: Primary Colors
    public static var primaryColor = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor,
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor
    ) {
        didSet {
            updateExtendedColors()
        }
    }
    
    public static var white = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#FFFFFF"),
        darkModeColor: UIColor(hex: "#FFFFFF")
    )
    
    public static var black = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#141414"),
        darkModeColor: UIColor(hex: "#141414")
    )

    //MARK: Extended Colors
    public static var extendedPrimaryColor50 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.96),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.80)
    )
    
    public static var extendedPrimaryColor100 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.88),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.72)
    )

    public static var extendedPrimaryColor200 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.77),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.64)
    )

    public static var extendedPrimaryColor300 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.66),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.56)
    )

    public static var extendedPrimaryColor400 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.55),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.48)
    )

    public static var extendedPrimaryColor500 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.44),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.40)
    )

    public static var extendedPrimaryColor600 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.33),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.32)
    )

    public static var extendedPrimaryColor700 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.22),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.24)
    )

    public static var extendedPrimaryColor800 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithWhite(percentage: 0.11),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithBlack(percentage: 0.16)
    )

    public static var extendedPrimaryColor900 = UIColor.dynamicColor(
        lightModeColor: CometChatThemeHelper.defaultPrimaryLightColor.mixWithBlack(percentage: 0.11),
        darkModeColor: CometChatThemeHelper.defaultPrimaryDarkColor.mixWithWhite(percentage: 0.08)
    )
  

    //MARK: Neutral Colors
    public static var neutralColor50 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#FFFFFF"),
        darkModeColor: UIColor(hex: "#141414")
    )
    public static var neutralColor100 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#FAFAFA"),
        darkModeColor: UIColor(hex: "#1A1A1A")
    )
    public static var neutralColor200 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#F5F5F5"),
        darkModeColor: UIColor(hex: "#272727")
    )
    public static var neutralColor300 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#E8E8E8"),
        darkModeColor: UIColor(hex: "#383838")
    )
    public static var neutralColor400 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#DCDCDC"),
        darkModeColor: UIColor(hex: "#4C4C4C")
    )
    public static var neutralColor500 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#A1A1A1"),
        darkModeColor: UIColor(hex: "#858585")
    )
    public static var neutralColor600 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#727272"),
        darkModeColor: UIColor(hex: "#989898")
    )
    public static var neutralColor700 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#5B5B5B"),
        darkModeColor: UIColor(hex: "#A8A8A8")
    )
    public static var neutralColor800 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#434343"),
        darkModeColor: UIColor(hex: "#C8C8C8")
    )
    public static var neutralColor900 = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#141414"),
        darkModeColor: UIColor(hex: "#FFFFFF")
    )


    //MARK: Background Colors
    static var _backgroundColor01: UIColor?
    public static var backgroundColor01: UIColor {
        set {
            _backgroundColor01 = newValue
        }
        get {
            return _backgroundColor01 ?? CometChatTheme.neutralColor50
        }
    }

    // Mapping backgroundColor02 to neutralColor100
    static var _backgroundColor02: UIColor?
    public static var backgroundColor02: UIColor {
        set {
            _backgroundColor02 = newValue
        }
        get {
            return _backgroundColor02 ?? CometChatTheme.neutralColor100
        }
    }

    // Mapping backgroundColor03 to neutralColor200
    static var _backgroundColor03: UIColor?
    public static var backgroundColor03: UIColor {
        set {
            _backgroundColor03 = newValue
        }
        get {
            return _backgroundColor03 ?? CometChatTheme.neutralColor200
        }
    }

    // Mapping backgroundColor04 to neutralColor300
    static var _backgroundColor04: UIColor?
    public static var backgroundColor04: UIColor {
        set {
            _backgroundColor04 = newValue
        }
        get {
            return _backgroundColor04 ?? CometChatTheme.neutralColor300
        }
    }


    //MARK: Border Colors
    // Mapping borderColorDefault to neutralColor300
    static var _borderColorDefault: UIColor?
    public static var borderColorDefault: UIColor {
        set {
            _borderColorDefault = newValue
        }
        get {
            return _borderColorDefault ?? CometChatTheme.neutralColor300
        }
    }

    // Mapping borderColorLight to neutralColor200
    static var _borderColorLight: UIColor?
    public static var borderColorLight: UIColor {
        set {
            _borderColorLight = newValue
        }
        get {
            return _borderColorLight ?? CometChatTheme.neutralColor200
        }
    }

    // Mapping borderColorDark to neutralColor400
    static var _borderColorDark: UIColor?
    public static var borderColorDark: UIColor {
        set {
            _borderColorDark = newValue
        }
        get {
            return _borderColorDark ?? CometChatTheme.neutralColor400
        }
    }
    static var _borderColorHighlight: UIColor?
    public static var borderColorHighlight: UIColor {
        set {
            _borderColorHighlight = newValue
        }
        get {
            return _borderColorHighlight ?? CometChatTheme.primaryColor
        }
    }


    //MARK: Text Colors
    static var _textColorPrimary: UIColor?
    public static var textColorPrimary: UIColor {
        set {
            _textColorPrimary = newValue
        }
        get {
            return _textColorPrimary ?? CometChatTheme.neutralColor900
        }
    }
    
    static var _textColorSecondary: UIColor?
    public static var textColorSecondary: UIColor {
        set {
            _textColorSecondary = newValue
        }
        get {
            return _textColorSecondary ?? CometChatTheme.neutralColor600
        }
    }
    
    
    // Mapping textColorTertiary to neutralColor500
    static var _textColorTertiary: UIColor?
    public static var textColorTertiary: UIColor {
        set {
            _textColorTertiary = newValue
        }
        get {
            return _textColorTertiary ?? CometChatTheme.neutralColor500
        }
    }

    // Mapping textColorDisabled to neutralColor400
    static var _textColorDisabled: UIColor?
    public static var textColorDisabled: UIColor {
        set {
            _textColorDisabled = newValue
        }
        get {
            return _textColorDisabled ?? CometChatTheme.neutralColor400
        }
    }

    // Mapping textColorWhite to neutralColor50
    static var _textColorWhite: UIColor?
    public static var textColorWhite: UIColor {
        set {
            _textColorWhite = newValue
        }
        get {
            return _textColorWhite ?? CometChatTheme.neutralColor50
        }
    }

    // Mapping textColorHighlight (no neutral color, using provided color)
    static var _textColorHighlight: UIColor?
    public static var textColorHighlight: UIColor {
        set {
            _textColorHighlight = newValue
        }
        get {
            return _textColorHighlight ?? CometChatTheme.primaryColor
        }
    }

    // MARK: - Icon Colors

    // Mapping iconColorPrimary to neutralColor900
    static var _iconColorPrimary: UIColor?
    public static var iconColorPrimary: UIColor {
        set {
            _iconColorPrimary = newValue
        }
        get {
            return _iconColorPrimary ?? CometChatTheme.neutralColor900
        }
    }

    // Mapping iconColorSecondary to neutralColor500
    static var _iconColorSecondary: UIColor?
    public static var iconColorSecondary: UIColor {
        set {
            _iconColorSecondary = newValue
        }
        get {
            return _iconColorSecondary ?? CometChatTheme.neutralColor500
        }
    }

    // Mapping iconColorTertiary to neutralColor400
    static var _iconColorTertiary: UIColor?
    public static var iconColorTertiary: UIColor {
        set {
            _iconColorTertiary = newValue
        }
        get {
            return _iconColorTertiary ?? CometChatTheme.neutralColor400
        }
    }

    // Mapping iconColorWhite to neutralColor50
    static var _iconColorWhite: UIColor?
    public static var iconColorWhite: UIColor {
        set {
            _iconColorWhite = newValue
        }
        get {
            return _iconColorWhite ?? CometChatTheme.neutralColor50
        }
    }
    
    // Mapping iconColorWhite to neutralColor50
    static var _iconColorHighlight: UIColor?
    public static var iconColorHighlight: UIColor {
        set {
            _iconColorHighlight = newValue
        }
        get {
            return _iconColorHighlight ?? CometChatTheme.primaryColor
        }
    }
    
    public static var messageReadColor: UIColor = UIColor(hex: "#56E8A7")
    
    //MARK: Alert Bubble Colors
    public static var infoColor = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#0B7BEA"),
        darkModeColor: UIColor(hex: "#0D66BF")
    )
    public static var warningColor = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#FFAB00"),
        darkModeColor: UIColor(hex: "#D08D04")
    )
    public static var successColor = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#09C26F"),
        darkModeColor: UIColor(hex: "#0B9F5D")
    )
    public static var errorColor = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#F44649"),
        darkModeColor: UIColor(hex: "#C73C3E")
    )
    
    //MARK: Button Colors
    private static var _buttonBackgroundColor: UIColor? = nil
    public static var buttonBackgroundColor: UIColor {
        get {
            return _buttonBackgroundColor ?? primaryColor
        }
        set {
            _buttonBackgroundColor = newValue
        }
    }

    public static var buttonIconColor: UIColor = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#FFFFFF"),
        darkModeColor: UIColor(hex: "#FFFFFF")
    )

    public static var buttonTextColor: UIColor = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#FFFFFF"),
        darkModeColor: UIColor(hex: "#FFFFFF")
    )
    
    private static var _secondaryButtonBackgroundColor: UIColor? = nil
    public static var secondaryButtonBackgroundColor: UIColor {
        get {
            return _secondaryButtonBackgroundColor ?? neutralColor800
        }
        set {
            _secondaryButtonBackgroundColor = newValue
        }
    }

    private static var _secondaryButtonIconColor: UIColor? = nil
    public static var secondaryButtonIconColor: UIColor {
        get {
            return _secondaryButtonIconColor ?? neutralColor800
        }
        set {
            _secondaryButtonIconColor = newValue
        }
    }

    private static var _secondaryButtonTextColor: UIColor? = nil
    public static var secondaryButtonTextColor: UIColor {
        get {
            return _secondaryButtonTextColor ?? neutralColor800
        }
        set {
            _secondaryButtonTextColor = newValue
        }
    }

    private static var _fabButtonBackgroundColor: UIColor? = nil
    public static var fabButtonBackgroundColor: UIColor {
        get {
            return _fabButtonBackgroundColor ?? primaryColor
        }
        set {
            _fabButtonBackgroundColor = newValue
        }
    }

    public static var fabButtonIconColor: UIColor = UIColor.dynamicColor(
        lightModeColor: UIColor(hex: "#FFFFFF"),
        darkModeColor: UIColor(hex: "#FFFFFF")
    )

    private static var _whiteHoverColor: UIColor? = nil
    public static var whiteHoverColor: UIColor {
        get {
            return _whiteHoverColor ?? neutralColor50
        }
        set {
            _whiteHoverColor = newValue
        }
    }

}

//updating extended color
extension CometChatTheme {
    private static func updateExtendedColors() {
        extendedPrimaryColor50 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.96),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.80)
        )
        extendedPrimaryColor100 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.88),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.72)
        )
        extendedPrimaryColor200 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.77),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.64)
        )
        extendedPrimaryColor300 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.66),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.56)
        )
        extendedPrimaryColor400 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.55),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.48)
        )
        extendedPrimaryColor500 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.44),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.40)
        )
        extendedPrimaryColor600 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.33),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.32)
        )
        extendedPrimaryColor700 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.22),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.24)
        )
        extendedPrimaryColor800 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithWhite(percentage: 0.11),
            darkModeColor: primaryColor.mixWithBlack(percentage: 0.16)
        )
        extendedPrimaryColor900 = UIColor.dynamicColor(
            lightModeColor: primaryColor.mixWithBlack(percentage: 0.11),
            darkModeColor: primaryColor.mixWithWhite(percentage: 0.08)
        )
    }
}
