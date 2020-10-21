
//  SmartRepliesView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import Foundation
import CometChatPro

// MARK: - Importing Protocols.

protocol SmartRepliesViewDelegate: class {
    func didSendButtonPressed(title: String)
}

/*  ----------------------------------------------------------------------------------------- */

@IBDesignable class SmartRepliesView: UIView {
    
    // MARK: - Declaration of Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Declaration of Variables
    var view:UIView!
    var buttontitles: [String] = [String]()
    weak var smartRepliesDelegate: SmartRepliesViewDelegate?
    
    
    // MARK: - Public instance Methods
    
    /**
    This method set the array of titles for smart replies view.
     - Parameter sender: This specifies an user who is pressing this button
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc  func set(titles : [String]){
        buttontitles = titles
        collectionView.reloadData()
    }
    
     // MARK: - Initialization of required Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func draw(_ rect: CGRect) {
        collectionView.showsHorizontalScrollIndicator = false
        setupCollectionView()
    }
    
   // MARK: - Private instance Methods
    
    /// This method will setup the collection view for smart replies
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let SmartReplyCell = UINib(nibName: "SmartReplyCell", bundle: UIKitSettings.bundle)
        collectionView.register(SmartReplyCell, forCellWithReuseIdentifier: "smartReplyCell")
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CollectionView Delegate Methods

extension SmartRepliesView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttontitles.count
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "smartReplyCell", for: indexPath) as! SmartReplyCell
        cell.delegate = self
        let title = buttontitles[safe: indexPath.row]
        cell.smartReplyButton.setTitle(title, for: .normal)
        return cell
    }
}


/*  ----------------------------------------------------------------------------------------- */

// MARK: - SmartReplyCell Delegate Method

extension SmartRepliesView: SmartReplyCellDelegate {
    
    /// This method will trigger when user tap on button in smart replies view.
    /// - Parameters:
    ///   - title: Specifies a string value
    ///   - sender: Specifies a sender of the button.
    func didSendButtonPressed(title: String, sender: UIButton) {
        smartRepliesDelegate?.didSendButtonPressed(title: title)
    }
}

/*  ----------------------------------------------------------------------------------------- */
