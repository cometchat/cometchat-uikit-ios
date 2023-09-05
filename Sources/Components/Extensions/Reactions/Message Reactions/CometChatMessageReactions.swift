
//  CometChatMessageComposer.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import Foundation
import CometChatSDK


// MARK: - Declaration of Protocol

protocol CometChatMessageReactionsDelegate: AnyObject {
    func didReactionPressed(reaction:CometChatMessageReaction)
    func didNewReactionPressed()
    func didlongPressOnCometChatMessageReactions(reactions: [CometChatMessageReaction])
}

/*  ----------------------------------------------------------------------------------------- */

@IBDesignable public class CometChatMessageReactions: UIStackView {
    
    // MARK: - Declaration of Variables
    var message: BaseMessage?
    weak var controller: UIViewController?
    var reactions = [CometChatMessageReaction]()
    var messageReactionsConfiguration: MessageReactionsConfiguration?
    var collectionView: UICollectionView?
    var onClick: ((_ reaction:  CometChatMessageReaction) -> Void)?
    var addReaction: (() -> Void)?
    
    // MARK: - Declaration of IBOutlet
    
    // MARK: - Initialization of required Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupCollectionView(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        if let messageReactionsConfiguration = messageReactionsConfiguration {
            if let messageReactionsStyle = messageReactionsConfiguration.style {
                set(style: messageReactionsStyle)
            }
        } else {
            set(style: MessageReactionStyle())
        }
    }
    
    private func set(style: MessageReactionStyle) {}
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func setOnClick(onClick: @escaping (_ reaction: CometChatMessageReaction) -> Void) -> Self {
        self.onClick = onClick
        return self
    }
    
    @discardableResult
    public func didAddReaction(addReaction: @escaping () -> Void) -> Self {
        self.addReaction = addReaction
        return self
    }
    
    private func setupCollectionView(frame: CGRect) {
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: UICollectionViewFlowLayout())
        if let collectionView = self.collectionView {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
            collectionView.collectionViewLayout = layout
            self.addArrangedSubview(collectionView)
            collectionView.isScrollEnabled = false
            collectionView.dataSource = self
            collectionView.delegate = self
            self.backgroundColor = .clear
            collectionView.backgroundColor = .clear
            collectionView.showsHorizontalScrollIndicator = false
            let reactionIndicatorCell = UINib(nibName: "ReactionCountCell", bundle: CometChatUIKit.bundle)
            collectionView.register(reactionIndicatorCell, forCellWithReuseIdentifier: "reactionCountCell")
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressed))
            collectionView.addGestureRecognizer(longPressRecognizer)
        }
    }
    
    private func calculateHeightForReactions() {
        /// Count the number of reactions.
        let count = self.reactions.count
        /// numberOfItemInARow. MaxWidth is 228 and one item width is 45.
        let numberOfItemInRow = Int(228 / 45)
        if count > 0 {
            /// calculate the number of rows.
            let row = count % numberOfItemInRow != 0 ? count / numberOfItemInRow + 1 : count / numberOfItemInRow
            self.isHidden = false
            /// Calculate the height of the message reactions, and one row height is 32.
            self.heightAnchor.constraint(equalToConstant: CGFloat(row * 32)).isActive = true
        } else {
            /// when reactions count is zero.
            self.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.isHidden = true
        }
    }
    
    func calculateHeight() -> CGFloat{
        let reactionsCount = self.reactions.count
        if reactionsCount == 0 {
            self.widthAnchor.constraint(equalToConstant: 0).isActive = true
            self.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.isHidden = true
            return 0
        } else {
            self.isHidden = false
            self.widthAnchor.constraint(equalToConstant: 228).isActive = true
            if reactionsCount <= 4 {
                return 35.0
            } else if reactionsCount%4 == 0 {
                return CGFloat(reactionsCount/4 * 30) + 10
            } else if  reactionsCount%4 != 0 {
                return  CGFloat(reactionsCount/4 * 30) + 40
            }
        }
        return 0.0
    }
    
    func parseMessageReactionForMessage(message: BaseMessage) -> UIStackView? {
        self.message = message
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let reactionsDictionary = cometChatExtension[ExtensionConstants.reactions] as? [String : Any] {
            var currentReactions = [CometChatMessageReaction]()
            reactionsDictionary.forEach { (reaction, reactors) in
                if reaction != nil {
                    if let reactors = reactors as? [String: Any] {
                        var currentReactors = [CometChatMessageReactor]()
                        reactors.forEach { (uid,user) in
                            let name = (user as? [String:Any])?["name"] as? String ?? ""
                            let avatar = (user as? [String:Any])?["avatar"]  as? String ?? ""
                            let reactor = CometChatMessageReactor(uid: uid, name: name, avatar: avatar)
                            currentReactors.insert(reactor, at: 0)
                        }
                        let reaction = CometChatMessageReaction(title: reaction, name: reaction, messageId: message.id, reactors: currentReactors)
                        currentReactions.insert(reaction, at: 0)
                    }
                    set(width: 200, height: 100)
                }
            }
            //TODO: - Should add default reaction
            self.reactions.append(contentsOf: currentReactions.map{$0})
            if !reactions.isEmpty {
                self.reactions.append(CometChatMessageReaction(title: "", name: "add", messageId: 111111, reactors: []))
            }
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            return self
        } else {
            return nil
        }
    }
    
    @discardableResult
    public func set(width: CGFloat, height: CGFloat) -> Self {
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(greaterThanOrEqualToConstant: height),
            self.widthAnchor.constraint(equalToConstant: width),
        ])
        return self
    }
    
    @objc func didLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            CometChatMessageReactions.cometChatMessageReactionsDelegate?.didlongPressOnCometChatMessageReactions(reactions: reactions)
        }
    }
    
}

// MARK: - CollectionView Delegate Methods

extension CometChatMessageReactions: UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactions.count
    }
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reactionCountCell", for: indexPath) as! ReactionCountCell
        let reaction = reactions[safe: indexPath.row]
        if reactions.count == indexPath.row + 1 && reactions.count > 1 {
            cell.addReactionsIcon.isHidden = false
            cell.reactionLabel.isHidden = true
            cell.addReactionsIcon.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(onAddReactionsClick))
            tap.numberOfTapsRequired = 1
            cell.addReactionsIcon.addGestureRecognizer(tap)
        } else if reactions.count > 0 {
            cell.addReactionsIcon.isHidden = true
            cell.reactionLabel.isHidden = false
        }
        cell.reaction = reaction
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ReactionCountCell, let reaction = cell.reaction {
            onClick?(reaction)
        }
    }
    
    @objc func onAddReactionsClick() {
        addReaction?()
    }
}

extension CometChatMessageReactions: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 42, height: 30)
    }
}

extension CometChatMessageReactions {
    static var cometChatMessageReactionsDelegate: CometChatMessageReactionsDelegate?
}
