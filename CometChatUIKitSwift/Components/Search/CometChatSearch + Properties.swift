//
//  CometChatSearch + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 08/12/25.
//

import Foundation
import UIKit
import CometChatSDK

extension CometChatSearch {
    public func set(searchFilters: [SearchFilter], initialFilter: SearchFilter? = nil) {
        self.searchFilters = searchFilters
        self.initialSearchFilter = initialFilter
        
        // Convert enum filters into FilterItem for UI
        self.filterItems = searchFilters.map { SearchUtils.filterItem(for: $0) }
        originalFilterItems = self.filterItems
        
        // Apply initial filter if provided
        if let initial = initialFilter {
            self.selectedFilters = [SearchUtils.filterItem(for: initial)]
            applyFilterForCurrentSelection() // ensure results refresh
        }
        
        // Reload filter UI
        self.filterCollectionView.reloadData()
    }
    
    public func set(searchIn: [SearchScope]) {
        self.searchScopes = searchIn
        self.originalScopes = searchIn
        self.viewModel.activeScopes = searchIn

        if searchIn.count == 1, searchIn.contains(.messages) {

            originalFilterItems.removeAll(where: { $0.title == "Groups" || $0.title == "Unread" })

            filterCollectionView.reloadData()

        } else {
            filterItems = originalFilterItems
            filterCollectionView.reloadData()
        }

        tableView.reloadData()
    }
    
    @discardableResult
    public func set(loadingView: UIView) -> Self {
        self.loadingView = loadingView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView) -> Self {
        self.errorStateView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView) -> Self {
        self.emptyStateView = loadingView
        return self
    }
    
    @discardableResult
    public func set(listItemViewForMessage: @escaping ((_ message: BaseMessage) -> UIView)) -> Self {
        self.listItemViewForMessage = listItemViewForMessage
        return self
    }
    
    @discardableResult
    public func set(listItemViewForConversation: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.listItemViewForConversation = listItemViewForConversation
        return self
    }
    
    @discardableResult
    public func set(listItemViewForImage: @escaping ((_ message: MediaMessage) -> UIView)) -> Self {
        self.listItemViewForImage = listItemViewForImage
        return self
    }
    
    @discardableResult
    public func set(listItemViewForVideo: @escaping ((_ message: MediaMessage) -> UIView)) -> Self {
        self.listItemViewForVideo = listItemViewForVideo
        return self
    }
    
    @discardableResult
    public func set(listItemViewForAudio: @escaping ((_ message: MediaMessage) -> UIView)) -> Self {
        self.listItemViewForAudio = listItemViewForAudio
        return self
    }
    
    @discardableResult
    public func set(listItemViewForDocument: @escaping ((_ message: MediaMessage) -> UIView)) -> Self {
        self.listItemViewForDocument = listItemViewForDocument
        return self
    }
    
    @discardableResult
    public func set(listItemViewForLink: @escaping ((_ message: MediaMessage) -> UIView)) -> Self {
        self.listItemViewForLink = listItemViewForLink
        return self
    }

    @discardableResult
    public func setMentionAllLabel(_ id: String, _ label: String)  -> Self{
        if let mentionFormatter = textFormatters.first(where: { $0 is CometChatMentionsFormatter }) as? CometChatMentionsFormatter {
            mentionFormatter.setMentionAllLabel(id: id, label: label)
        }
        return self
    }
}
