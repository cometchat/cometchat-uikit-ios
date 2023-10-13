//
//  AIMessagesListView.swift
//  
//
//  Created by SuryanshBisen on 13/09/23.
//

import Foundation
import UIKit

class SelfSizingTableView: UITableView {
    var maxHeight = CGFloat.infinity

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = min(maxHeight, contentSize.height)
        return CGSize(width: contentSize.width, height: height)
    }
}

public class AIRepliesListView: UIStackView {
    
    var tableView = SelfSizingTableView()
    var aiMessagesList = [String]()
    var onAiMessageClicked: ((_ selectedReply: String) -> ())?
    var smartRepliesStyle: AISmartRepliesStyle?
    var enablerStyle: AIEnableStyle?
    var conversationStartersStyle: AIConversationStartersStyle?
    var isPresentForEmptyMessages = false
    var estimatedCellHeight = 70
    var selfHeightAnchor: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        fatalError("init(coder:) has not been implemented")
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        commonInit()
//    }
    
    func commonInit() {
        setUpDelegate()
        buildUI()
    }
    
    private func setUpDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "AIRepliesCell", bundle: CometChatUIKit.bundle)
        tableView.register(nib, forCellReuseIdentifier: "AIRepliesCell")
    }
    
    private func buildUI() {
        
        selfHeightAnchor = self.heightAnchor.constraint(equalToConstant: 200)
        selfHeightAnchor?.isActive = true
        
        tableView.estimatedRowHeight = CGFloat(estimatedCellHeight)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isUserInteractionEnabled = true
        tableView.backgroundColor = .clear
        
        self.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
                
    }
    
    //table view cell needs to start filling from the bottom for empty message view
    func configureForEmptyMessageView() {
        tableView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        selfHeightAnchor?.isActive = false
    }
    
    @discardableResult
    @objc public func set(isForEmptyMessages: Bool) -> Self {
        self.isPresentForEmptyMessages = isForEmptyMessages
        configureForEmptyMessageView()
        return self
    }
    
    
    @discardableResult
    @objc public func set(aiMessageOptions: [String]) -> Self {
        self.aiMessagesList = aiMessageOptions
        return self
    }
    
    @discardableResult
    @objc public func onMessageClicked(onAiMessageClicked: @escaping ((_ selectedReply: String) -> ())) -> Self {
        self.onAiMessageClicked = onAiMessageClicked
        return self
    }
    
    @discardableResult
    @objc public func set(tableViewStyle: UITableViewCell.SeparatorStyle) -> Self {
        self.tableView.separatorStyle = tableViewStyle
        return self
    }
    
    @discardableResult
    @objc public func set(backgroundColour: UIColor) -> Self {
        self.backgroundColor = backgroundColour
        return self
    }
    
    @discardableResult
    public func set(smartRepliesStyle: AISmartRepliesStyle?) -> Self {
        self.smartRepliesStyle = smartRepliesStyle
        
        if let backgroundColor = smartRepliesStyle?.repliesViewBackgroundColour {
            set(backgroundColour: backgroundColor)
        }
        
        if let separatorStyle = smartRepliesStyle?.repliesTableViewSeparatorStyle {
            set(tableViewStyle: separatorStyle)
        }
        
        return self
    }
    
    @discardableResult
    public func set(enablerStyle: AIEnableStyle?) -> Self {
        self.enablerStyle = enablerStyle
        
        if let backgroundColor = enablerStyle?.repliesViewBackgroundColour {
            set(backgroundColour: backgroundColor)
        }
        
        if let separatorStyle = enablerStyle?.repliesTableViewSeparatorStyle {
            set(tableViewStyle: separatorStyle)
        }
        
        return self
    }
    
    @discardableResult
    public func set(conversationStartersStyle: AIConversationStartersStyle?) -> Self {
        self.conversationStartersStyle = conversationStartersStyle
        
        if let backgroundColor = conversationStartersStyle?.repliesViewBackgroundColour {
            set(backgroundColour: backgroundColor)
        }
        
        if let separatorStyle = conversationStartersStyle?.repliesTableViewSeparatorStyle {
            set(tableViewStyle: separatorStyle)
        }
        
        return self
    }


}


//table view
extension AIRepliesListView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aiMessagesList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AIRepliesCell") as? AIRepliesCell {
            
            cell.set(title: aiMessagesList[indexPath.row])
            
            cell.set(onButtonClick: onAiMessageClicked)
            
            if enablerStyle != nil {
                cell.set(style: enablerStyle)
            }
            
            if smartRepliesStyle != nil {
                cell.set(style: smartRepliesStyle)
            }
            
            if conversationStartersStyle != nil {
                cell.set(style: conversationStartersStyle)
            }
            
            if isPresentForEmptyMessages {
                cell.set(buttonBorder: 2)
                cell.set(corner: CometChatCornerStyle(cornerRadius: 15))
                cell.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            
            return cell
            
        }
        
        return UITableViewCell()
    }
}
