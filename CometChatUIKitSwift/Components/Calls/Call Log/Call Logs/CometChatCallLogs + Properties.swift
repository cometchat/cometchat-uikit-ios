//
//  CometChatCallLogs + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import Foundation
import CometChatSDK

#if canImport(CometChatCallsSDK)

extension CometChatCallLogs {
    
    //MARK: Data
    /// Custom CallLog Request Builder
    /// - Parameter callRequestBuilder: Custom Request Builder of type CometChatCallsSDK.CallLogsRequest.CallLogsBuilder
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(callRequestBuilder: Any?) -> Self {
        if let callRequestBuilder = callRequestBuilder as? CometChatCallsSDK.CallLogsRequest.CallLogsBuilder {
            self.callRequestBuilder = callRequestBuilder
        }
        return self
    }
    
    @discardableResult
    public func set(outgoingCallConfiguration: OutgoingCallConfiguration) -> Self {
        self.outgoingCallConfiguration = outgoingCallConfiguration
        return self
    }
    
    
    //MARK: Events
    /// Get Callback when any error occurs in this ViewController
    /// - Parameter onError: Error closure returns error of type CometChatCallsSDK.CometChatCallException, typecast it to CometChatCallsSDK.CometChatCallException for accessing it
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(onError: ((_ error : Any) -> ())?) -> Self {
        self.onError = onError
        return self
    }
    
    /// Get Callback when list of CometChatCallsSDK.CallLog is fetched and going to get displayed on the screen
    /// - Parameter onLoad: onLoad closure returns array of CometChatCallsSDK.CallLog in Any type, typecast it to CometChatCallsSDK.CallLog and access it
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(onLoad: @escaping (([Any]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }
    
    @discardableResult
    public func set(onEmpty: @escaping (() -> Void)) -> Self {
        self.onEmpty = onEmpty
        return self
    }
    
    /// Get Callback when a call item is clicked by the user
    /// - Parameter onItemClick: onItemClick closure returns clicked CometChatCallsSDK.CallLog in Any type,  typecast it to CometChatCallsSDK.CallLog and access it
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(onItemClick: ((_ callLog : Any) -> ())?) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    /// Get Callback when a call item is long pressed by the user
    /// - Parameter onItemLongClick: onItemLongClick closure returns long pressed CometChatCallsSDK.CallLog in Any type,  typecast it to CometChatCallsSDK.CallLog and access it
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(onItemLongClick: ((_ callLog : Any, _ indexPath: IndexPath) -> ())?) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    //MARK: Configurations
    /// Set a custom date pattern for displaying call log dates
    /// - Parameter datePattern: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and returns a formatted date string
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(datePattern: @escaping ((_ callLog: Any) -> String)) -> Self {
        self.datePattern = datePattern
        return self
    }
    
    /// Set custom options for a call log
    /// - Parameter options: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and returns an array of `CometChatCallOption`
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(options: ((_ callLog: Any) -> [CometChatCallOption])?) -> Self {
      self.options = options
      return self
    }
    
    /// Add additional options to the existing options for a call log
    /// - Parameter options: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and returns an array of `CometChatCallOption`
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func add(options: ((_ callLog: Any) -> [CometChatCallOption])?) -> Self {
      self.addOptions = options
      return self
    }
    
    
    //MARK: UI updates
    /// Set a custom subtitle view for a call log
    /// - Parameter subtitleView: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and returns a `UIView`
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(subtitleView: ((_ callLog : Any) -> UIView)?) -> Self {
        self.subtitleView = subtitleView
        return self
    }
    
    /// Set a custom trailing view for a call log
    /// - Parameter trailView: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and returns a `UIView`
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(trailView: ((_ callLog : Any) -> UIView)?) -> Self {
        self.trailView = trailView
        return self
    }
    
    /// Set a custom title view for a call log
    /// - Parameter titleView: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and returns a `UIView`
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(titleView: ((_ callLog : Any) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }
    
    /// Set a custom list item view for a call log
    /// - Parameter listItemView: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and returns a `UIView`
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(listItemView: ((_ callLog : Any) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    /// Set a callback for when the call button is clicked
    /// - Parameter onCallButtonClicked: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and performs an action
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(onCallButtonClicked: ((Any) -> Void)?) -> Self {
        self.onCallButtonClicked = onCallButtonClicked
        return self
    }
    
    /// Set a custom leading view for a call log
    /// - Parameter leadingView: A closure that takes a CometChatCallsSDK.CallLog of type `Any` and returns a `UIView`
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(leadingView: ((_ callLog : Any) -> UIView)?) -> Self {
        self.leadingView = leadingView
        return self
    }
    
    /// Set a callback for navigating to the call log detail view
    /// - Parameter goToCallLogDetail: A closure that takes a CometChatCallsSDK.CallLog of type `Any`, a `User`, and a `Group`, and performs navigation
    /// - Returns: CometChatCallLogs (Self)
    @discardableResult
    public func set(goToCallLogDetail: ((_ callLog: Any, _ user: User?, _ group: Group?) -> Void)?) -> Self {
        self.goToCallLogDetail = goToCallLogDetail
        return self
    }
    
    
}
#endif
