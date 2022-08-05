//
//  PollBubbleStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 20/05/22.
//

import Foundation
import UIKit

class PollBubbleStyle {
    
    let questionColor: UIColor?
    let questionFont: UIFont?
    let percentageTextColor: UIColor?
    let percentageTextFont: UIFont?
    let pollButtonColor: UIColor?
    let answerTextColor: UIColor?
    let answerTextFont: UIFont?
    let pollBackgroundViewColor: UIColor?
    let answeredPollTextColor: UIColor?
    let answeredPollTextFont: UIFont?
    let spacerViewColor: UIColor?
    
    init(
         questionColor: UIColor? = .gray,
         questionFont: UIFont? = UIFont.systemFont(ofSize: 17, weight: .regular),
         percentageTextColor: UIColor? = .gray,
         percentageTextFont: UIFont? = UIFont.systemFont(ofSize: 15, weight: .regular),
         pollButtonColor: UIColor? = .gray,
         answerTextColor: UIColor? = CometChatTheme.palatte?.accent900,
         answerTextFont: UIFont? = UIFont.systemFont(ofSize: 15, weight: .regular),
         pollBackgroundViewColor: UIColor? = .white,
         answeredPollTextColor: UIColor? = .black,
         answeredPollTextFont: UIFont? = UIFont.systemFont(ofSize: 13, weight: .regular),
         spacerViewColor: UIColor? = .gray
    ) {
        self.questionColor = questionColor
        self.questionFont = questionFont
        self.percentageTextColor = percentageTextColor
        self.percentageTextFont = percentageTextFont
        self.pollButtonColor = pollButtonColor
        self.answerTextColor = answerTextColor
        self.answerTextFont = answerTextFont
        self.pollBackgroundViewColor = pollBackgroundViewColor
        self.answeredPollTextColor = answeredPollTextColor
        self.answeredPollTextFont = answeredPollTextFont
        self.spacerViewColor = spacerViewColor
    }
    
}
