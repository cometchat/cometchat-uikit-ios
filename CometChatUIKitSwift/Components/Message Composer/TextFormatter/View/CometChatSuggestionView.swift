//
//  ComposerListView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 04/03/24.
//

import Foundation
import UIKit

public class CometChatSuggestionView: UIView {
    
    var suggestionItems = [SuggestionItem]()
    var tableView = UITableView()
    var onSelected: ((_: SuggestionItem) -> ())?
    var listScrolledToBottom: ((_: @escaping (_: [SuggestionItem]) -> Void ) -> Void)?
    var selfHeightAnchor: NSLayoutConstraint?
    var isAllItemsFetched = false
    var controller: UIViewController?
    
    //MARK: STYLING
    public static var style = SuggestionViewStyle() // global styling
    public static var avatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = {
        var statusIndicatorStyle = CometChatStatusIndicator.style
        statusIndicatorStyle.backgroundColor = CometChatTheme.successColor
        statusIndicatorStyle.borderWidth = 3
        statusIndicatorStyle.borderColor = CometChatSuggestionView.style.backgroundColor
        return statusIndicatorStyle
    }()
    
    public lazy var style = CometChatSuggestionView.style
    public lazy var avatarStyle = CometChatSuggestionView.avatarStyle
    public lazy var statusIndicatorStyle: StatusIndicatorStyle = CometChatSuggestionView.statusIndicatorStyle
        
    @discardableResult
    public func build() -> Self {
        setUpDelegate()
        buildUI()
        return self
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil{
            setupStyle()
        }
    }
    
    func setUpDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }
    
    func calculateHeight() {
        if self.tableView.contentSize.height > 200 {
            self.selfHeightAnchor?.constant = 200
        } else {
            self.selfHeightAnchor?.constant = CGFloat(Double((self.tableView.numberOfRows(inSection: 0) * 55)) + (2 * CometChatSpacing.Padding.p2))
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.controller?.view.layoutIfNeeded()
        }
    }
    
    open func buildUI() {
        selfHeightAnchor = heightAnchor.constraint(equalToConstant: 50)
        selfHeightAnchor?.isActive = true
        self.embed(tableView, insets: .init(
            top: CometChatSpacing.Padding.p2,
            leading: 0,
            bottom: CometChatSpacing.Padding.p2,
            trailing: 0
        )
        )
        tableView.separatorStyle = .none
        tableView.reloadData()
        calculateHeight()
    }
    
    open func setupStyle(){
        backgroundColor = style.backgroundColor
        tableView.backgroundColor = .clear
        borderWith(width: style.borderWidth)
        borderColor(color: style.borderColor)
        roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r4))
        applyCornerRadiusAndShadow(cornerRadius: style.cornerRadius?.cornerRadius ?? CometChatSpacing.Radius.r4)
    }
    
    func showIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.tableView.tableFooterView =  ActivityIndicator.show()
            this.calculateHeight()
        }
    }
    
    func hideIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            ActivityIndicator.hide()
            this.tableView.tableFooterView = nil
            this.calculateHeight()
        }
    }
    
    @discardableResult
    public func set(suggestionItems: [SuggestionItem]) -> Self {
        self.suggestionItems = suggestionItems
        tableView.reloadData()
        calculateHeight()
        tableView.setContentOffset(.zero, animated: false)
        isAllItemsFetched = false
        return self
    }
    
    @discardableResult
    public func set(style: SuggestionViewStyle?) -> Self {
        if let style = style {
            self.style = style
        }
        return self
    }
    
    @discardableResult
    public func set(onSelected: ((_: SuggestionItem) -> ())?) -> Self {
        self.onSelected = onSelected
        return self
    }
    
    @discardableResult
    public func set(listScrolledToBottom: ((_: @escaping (_: [SuggestionItem]) -> Void ) -> Void)?) -> Self {
        self.listScrolledToBottom = listScrolledToBottom
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
}

extension CometChatSuggestionView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionItems.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem {
            let data = self.suggestionItems[indexPath.row]
            
            listItem.layoutMargin = .init(
                top: CometChatSpacing.Padding.p2,
                leading: CometChatSpacing.Padding.p4,
                bottom: CometChatSpacing.Padding.p2,
                trailing: CometChatSpacing.Padding.p4
            )
            
            if let listItemStyle = data.listItemStyle { listItem.style = listItemStyle  }
            if let avatarStyle = data.leftIconStyle{
                listItem.avatar.style = avatarStyle
            }else{
                listItem.avatar.style = avatarStyle
            }
            
            listItem.set(title: data.name ?? "")
            listItem.hide(avatar: data.hideLeftIcon)
            listItem.allow(selection: false)
            
            //Setting Styling
            listItem.set(avatarURL: data.leftIconUrl ?? "", with: data.name) 
            if let avatarImage = data.leftIconImage { listItem.avatar.set(image: avatarImage) }
            
            listItem.titleLabel.font = style.textFont
            listItem.titleLabel.textColor = style.textColor
            
            if !data.hideLeftIcon {
                listItem.statusIndicator.style = statusIndicatorStyle
                listItem.statusIndicator.set(status: data.status)
            }
            
            return listItem
        }
        
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelected?(suggestionItems[indexPath.row])
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (suggestionItems.count - 1) && !isAllItemsFetched && (tableView.isDragging) {
            showIndicator()
            listScrolledToBottom?({ [weak self] suggestedItems in
                guard let self = self else { return }
                if suggestedItems.count == 0 { self.isAllItemsFetched = true }
                DispatchQueue.main.async {
                    self.suggestionItems.append(contentsOf: suggestedItems)
                    self.hideIndicator()
                    self.tableView.reloadData()
                }
            })
        }
    }
}
