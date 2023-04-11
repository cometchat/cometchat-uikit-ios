//
//  AudioBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class AudioBubbleConfiguration {

    private(set) var style: AudioBubbleStyle?
    
    @discardableResult
    public func set(style: AudioBubbleStyle) -> AudioBubbleConfiguration {
        self.style = style
        return self
    }
}
