//
//  FileBubbleConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit

public class FileBubbleConfiguration {

    private(set) var iconURL: String?
    private(set) var style: FileBubbleStyle?
    
    @discardableResult
    public func set(style: FileBubbleStyle) -> FileBubbleConfiguration {
        self.style =  style
        return self
    }
    
    @discardableResult
    public func set(iconURL: String) -> FileBubbleConfiguration {
        self.iconURL =  iconURL
        return self
    }
    
}
