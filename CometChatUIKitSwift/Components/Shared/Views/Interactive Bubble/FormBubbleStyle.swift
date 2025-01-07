//
//  FormBubbleStyle.swift
//  
//
//  Created by Admin on 26/09/23.
//

import Foundation
import UIKit

public final class FormBubbleStyle: BaseStyle {
    private var titleColor: UIColor = CometChatTheme_v4.palatte.accent900
    
    private var labelColor: UIColor = CometChatTheme_v4.palatte.accent900
    
    private var inputTextColor: UIColor = CometChatTheme_v4.palatte.accent900
    private var inputHintColor: UIColor = CometChatTheme_v4.palatte.accent500
    private var inputErrorColor: UIColor = CometChatTheme_v4.palatte.error
    private var inputStrokeColor: UIColor = CometChatTheme_v4.palatte.accent
    private var inputStrokeWidth: CGFloat = 0.7
    
    private var checkboxButtonTint: UIColor = .clear
    private var checkboxTextColor: UIColor = CometChatTheme_v4.palatte.accent900
    
    private var buttonBackgroundColor: UIColor = CometChatTheme_v4.palatte.primary
    private var buttonTextColor: UIColor = CometChatTheme_v4.palatte.secondary
    
    private var radioButtonTint: UIColor = .clear
    private var radioButtonTextColor: UIColor = CometChatTheme_v4.palatte.accent
    
    private var spinnerTextColor: UIColor = CometChatTheme_v4.palatte.accent
    private var spinnerBackgroundColor: UIColor = .clear
    
    private var selectedOptionTextColor: UIColor = CometChatTheme_v4.palatte.accent900
    private var optionTextColor: UIColor = CometChatTheme_v4.palatte.accent100
    private var selectedBackgroundColor: UIColor = .clear

    
    public override func set(background: UIColor) -> Self {
        super.set(background: background)
        return self
    }
    
    public override func set(borderWidth: CGFloat) -> Self {
        super.set(borderWidth: borderWidth)
        return self
    }
    
    public override func set(cornerRadius: CometChatCornerStyle) -> Self {
        super.set(cornerRadius: cornerRadius)
        return self
    }
    
    public override func set(borderColor: UIColor) -> Self {
        super.set(borderColor: borderColor)
        return self
    }
    
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    public func set(labelColor: UIColor) -> Self {
        self.labelColor = labelColor
        return self
    }
    
    public func set(inputTextColor: UIColor) -> Self {
        self.inputTextColor = inputTextColor
        return self
    }
    
    public func set(inputHintColor: UIColor) -> Self {
        self.inputHintColor = inputHintColor
        return self
    }
    
    public func set(inputErrorColor: UIColor) -> Self {
        self.inputErrorColor = inputErrorColor
        return self
    }
    
    public func set(inputStrokeColor: UIColor) -> Self {
        self.inputStrokeColor = inputStrokeColor
        return self
    }
    
    public func set(inputStrokeWidth: CGFloat) -> Self {
        self.inputStrokeWidth = inputStrokeWidth
        return self
    }
    
    public func set(checkboxButtonTint: UIColor) -> Self {
        self.checkboxButtonTint = checkboxButtonTint
        return self
    }
    
    public func set(checkboxTextColor: UIColor) -> Self {
        self.checkboxTextColor = checkboxTextColor
        return self
    }
    
    public func set(buttonBackgroundColor: UIColor) -> Self {
        self.buttonBackgroundColor = buttonBackgroundColor
        return self
    }
    
    public func set(buttonTextColor: UIColor) -> Self {
        self.buttonTextColor = buttonTextColor
        return self
    }
    
    public func set(radioButtonTint: UIColor) -> Self {
        self.radioButtonTint = radioButtonTint
        return self
    }
    
    public func set(radioButtonTextColor: UIColor) -> Self {
        self.radioButtonTextColor = radioButtonTextColor
        return self
    }
    
    public func set(spinnerTextColor: UIColor) -> Self {
        self.spinnerTextColor = spinnerTextColor
        return self
    }
    
    public func set(spinnerBackgroundColor: UIColor) -> Self {
        self.spinnerBackgroundColor = spinnerBackgroundColor
        return self
    }
    
    public func set(selectedOptionTextColor: UIColor) -> Self {
        self.selectedOptionTextColor = selectedOptionTextColor
          return self;
      }
    
    public func set(optionTextColor: UIColor) -> Self {
        self.optionTextColor = optionTextColor
          return self;
      }
    
    public func set(selectedBackgroundColor: UIColor) -> Self {
        self.selectedBackgroundColor = selectedBackgroundColor
          return self;
      }
    
    public func getSelectedOptionTextColor() -> UIColor {
          return selectedOptionTextColor;
      }
    
    public func getOptionTextColor() -> UIColor {
          return optionTextColor;
      }
    
    public func getSelectedBackgroundColor() -> UIColor {
          return selectedBackgroundColor;
      }
    
    public func getSpinnerBackgroundColor() -> UIColor {
          return spinnerBackgroundColor;
      }

      public func getTitleColor() -> UIColor {
          return titleColor;
      }

      public func getLabelColor() -> UIColor {
          return labelColor;
      }

    public func getInputTextColor() -> UIColor {
        return inputTextColor;
    }

      public func getInputHintColor() -> UIColor {
          return inputHintColor;
      }

      public func getInputErrorColor() -> UIColor {
          return inputErrorColor;
      }

      public func getInputStrokeColor() -> UIColor {
          return inputStrokeColor;
      }

      public func getInputStrokeWidth() -> CGFloat {
          return inputStrokeWidth;
      }

      public func getCheckboxButtonTint() -> UIColor {
          return checkboxButtonTint;
      }

      public func getCheckboxTextColor() -> UIColor {
          return checkboxTextColor;
      }

      public func getButtonBackgroundColor() -> UIColor {
          return buttonBackgroundColor;
      }

      public func getButtonTextColor() -> UIColor {
          return buttonTextColor;
      }

      public func getRadioButtonTint() -> UIColor {
          return radioButtonTint;
      }

      public func getRadioButtonTextColor() -> UIColor {
          return radioButtonTextColor;
      }

      public func getSpinnerTextColor() -> UIColor {
          return spinnerTextColor;
      }
}
