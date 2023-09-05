//
//  File.swift
//  
//
//  Created by Ajay Verma on 07/07/23.
//

import Foundation
import CometChatSDK
import UIKit

public class MessageInformationConfiguration {
    
    private(set) var titleText: String?
    private(set) var backIcon: UIImage?
    private(set) var readIcon: UIImage?
    private(set) var deliveredIcon: UIImage?
    private(set) var emptyStateText: String?
    private(set) var emptyStateView: UIView?
    private(set) var loadingIcon: UIImage?
    private(set) var loadingStateView: UIView?
    private(set) var errorStateText: String?
    private(set) var errorStateView: UIView?
    private(set) var listItemView: ((_ message: BaseMessage, _ receipt: MessageReceipt) ->  UIView)?
    private(set) var onError: ((_ error: CometChatException) -> Void)?
    private(set) var onBack: (() -> ())?
    private(set) var messageInformationStyle: MessageInformationStyle?
    
    public init() {}
    
    @discardableResult
    public func set(backIcon: UIImage) -> Self {
        self.backIcon = backIcon
        return self
    }
    
    @discardableResult
    public func set(readIcon: UIImage) -> Self {
        self.readIcon = readIcon
        return self
    }
    
    @discardableResult
    public func set(deliveredIcon: UIImage) -> Self {
        self.deliveredIcon = deliveredIcon
        return self
    }
    
    @discardableResult
    public func set(emptyStateText: String) -> Self {
        self.emptyStateText = emptyStateText
        return self
    }
    
    @discardableResult
    public func set(emptyStateView: UIView) -> Self {
        self.emptyStateView = emptyStateView
        return self
    }
    
    @discardableResult
    public func set(loadingStateView: UIView) -> Self {
        self.loadingStateView = loadingStateView
        return self
    }
    
    @discardableResult
    public func set(loadingIcon: UIImage) -> Self {
        self.loadingIcon = loadingIcon
        return self
    }
    
    @discardableResult
    public func set(errorStateText: String) -> Self {
        self.errorStateText = errorStateText
        return self
    }
    
    @discardableResult
    public func set(errorStateView: UIView) -> Self {
        self.errorStateView = errorStateView
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: ((_ message: BaseMessage, _ receipt: MessageReceipt) ->  UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: () -> ()) -> Self {
        self.onBack = self.onBack
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func setStyle(messageInformationStyle: MessageInformationStyle) -> Self {
        self.messageInformationStyle = messageInformationStyle
        return self
    }
    
    @discardableResult
    public func set(titleText: String) -> Self {
        self.titleText = titleText
        return self
    }
    
}
