//
//  CometChatMessageHover.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 27/01/22.
//

import UIKit
import CometChatPro

public enum  MessageHover {
    
    case edit
    case delete
    case share
    case copy
    case forward
    case reply
    case reply_in_thread
    case reaction
    case translate
    case messageInfo
    
}

protocol CometChatMessageHoverDelegate: class {
    func onItemClick(messageHover: MessageHover, forMessage: BaseMessage?, indexPath: IndexPath?)
}


class CometChatMessageHover: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var messageHovers: [MessageHover]?
    var reactionTitles: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSuperview()
        setupCollectionView()
        
    }

    public func set(messageHovers: [MessageHover]) {
        self.messageHovers = messageHovers
    }

    private func setupSuperview() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatMessageHover", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.view  = view
        preferredContentSize = CGSize(width: 375, height: 30)
        self.navigationController?.navigationBar.isHidden = true
       
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let reactionCell = UINib(nibName: "CometChatMessageHoverItem", bundle: CometChatUIKit.bundle)
        collectionView.register(reactionCell, forCellWithReuseIdentifier: "CometChatMessageHoverItem")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }

    
    
}


extension CometChatMessageHover: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messageHovers?.count ?? 0
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CometChatMessageHoverItem", for: indexPath) as? CometChatMessageHoverItem {
            cell.messageHover = messageHovers?[safe: indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if  let cell = collectionView.cellForItem(at: indexPath) as? CometChatMessageHoverItem, let hover = cell.messageHover {
            self.dismiss(animated: true) {
                CometChatMessageHover.messageHoverDelegate?.onItemClick(messageHover: hover, forMessage: nil, indexPath: indexPath)
            }
           
        }
    }
}

extension CometChatMessageHover: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 58, height: 85)
    }
}

extension CometChatMessageHover {
    static var messageHoverDelegate: CometChatMessageHoverDelegate?
}

