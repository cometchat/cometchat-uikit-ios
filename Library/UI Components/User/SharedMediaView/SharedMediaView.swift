//  SupportView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


// MARK: - Declaration of Protocols.

protocol SharedMediaDelegate: class {
    
    func didPhotoSelected(photo: MediaMessage)
    func didVideoSelected(video: MediaMessage)
    func didDocumentSelected(document: MediaMessage)
    
}

/*  ----------------------------------------------------------------------------------------- */

class SharedMediaView: UITableViewCell {
    
    // MARK: - Declaration of Outlets.
    
    @IBOutlet weak var mediaSelection: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Declaration of Variables.
    
    var mediaMessageRequest: MessagesRequest?
    var photos: [MediaMessage] = [MediaMessage]()
    var videos: [MediaMessage] = [MediaMessage]()
    var docs: [MediaMessage] = [MediaMessage]()
    var entity: AppEntity?
    var activityIndicator:UIActivityIndicatorView?
    weak var sharedMediaDelegate: SharedMediaDelegate?
    
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setupCollectionView()
    }
    
    // MARK: - Private Instance methods
    
    /**
     This method setup the collectionView for  SharedMediaView.
     - Parameter group: This specifies `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     */
    private func setupCollectionView() {
        
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        let SharedMediaCell = UINib(nibName: "SharedMediaCell", bundle: UIKitSettings.bundle)
        collectionView.register(SharedMediaCell, forCellWithReuseIdentifier: "sharedMediaCell")
    }
    
    
    /**
     This method fetches the media messages for SharedMediaView.
     - Parameters:
     - entity: This specifies the entity for which messages are being fetched.
     - type: This specifies the type of entity for which messages are being fetched.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     */
    func refreshMediaMessages(for entity: AppEntity, type: CometChat.ReceiverType) {
        self.entity = entity
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.startAnimating()
            self?.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self?.collectionView.bounds.width ?? 0, height: CGFloat(44))
            self?.collectionView.backgroundView = self?.activityIndicator
            self?.collectionView.backgroundView?.isHidden = false
        }
        switch type {
        case .user:
            if let user = entity as? User {
                switch mediaSelection.selectedSegmentIndex {
                case 0:
                    mediaMessageRequest = MessagesRequest.MessageRequestBuilder().set(uid: user.uid ?? "").set(limit:  20).set(categories: ["message"]).set(types: ["image"]).build()
                case 1:
                    mediaMessageRequest = MessagesRequest.MessageRequestBuilder().set(uid: user.uid ?? "").set(limit:  20).set(categories: ["message"]).set(types: ["video"]).build()
                case 2:
                    mediaMessageRequest = MessagesRequest.MessageRequestBuilder().set(uid: user.uid ?? "").set(limit:  20).set(categories: ["message"]).set(types: ["file"]).build()
                default: break
                }
                mediaMessageRequest?.fetchPrevious(onSuccess: { (mediaMessages) in
                    guard let fetchedMessages = mediaMessages?.filter({
                        (($0 as? MediaMessage)?.attachment != nil)}) else {
                            return }
                    if let messages = fetchedMessages as? [MediaMessage] {
                        DispatchQueue.main.async { [weak self] in
                            switch self?.mediaSelection.selectedSegmentIndex {
                            case 0: self?.photos = messages
                            case 1: self?.videos = messages
                            case 2: self?.docs = messages
                            default: break
                            }
                            self?.activityIndicator?.stopAnimating()
                            self?.collectionView.backgroundView?.isHidden = true
                            self?.collectionView.reloadData()
                        }
                    }
                }, onError: { (error) in
                    DispatchQueue.main.async { [weak self] in
                        if let errorMessage = error?.errorDescription {
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                            snackbar.show()
                            self?.activityIndicator?.stopAnimating()
                            self?.collectionView.backgroundView?.isHidden = true
                            self?.collectionView.reloadData()
                        }
                    }
                })
            }
        case .group:
            if let group = entity as? Group {
                switch mediaSelection.selectedSegmentIndex {
                case 0:
                    mediaMessageRequest = MessagesRequest.MessageRequestBuilder().set(guid: group.guid ).set(limit: 20).set(categories: ["message"]).set(types: ["image"]).build()
                case 1:
                    mediaMessageRequest = MessagesRequest.MessageRequestBuilder().set(guid: group.guid ).set(limit:  20).set(categories: ["message"]).set(types: ["video"]).build()
                case 2:
                    mediaMessageRequest = MessagesRequest.MessageRequestBuilder().set(guid: group.guid ).set(limit:  20).set(categories: ["message"]).set(types: ["file"]).build()
                default: break
                }
                mediaMessageRequest?.fetchPrevious(onSuccess: { (mediaMessages) in
                    guard let fetchedMessages = mediaMessages?.filter({
                        (($0 as? MediaMessage)?.attachment != nil)}) else {
                            return }
                    if let messages = fetchedMessages as? [MediaMessage] {
                        DispatchQueue.main.async {  [weak self] in
                            switch self?.mediaSelection.selectedSegmentIndex {
                            case 0: self?.photos = messages
                            case 1: self?.videos = messages
                            case 2: self?.docs = messages
                            default: break
                            }
                            self?.activityIndicator?.stopAnimating()
                            self?.collectionView.backgroundView?.isHidden = true
                            self?.collectionView.reloadData()
                        }
                    }
                }, onError: { (error) in
                    DispatchQueue.main.async {  [weak self] in
                        if let errorMessage = error?.errorDescription {
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                            snackbar.show()
                            self?.activityIndicator?.stopAnimating()
                            self?.collectionView.backgroundView?.isHidden = true
                            self?.collectionView.reloadData()
                        }
                    }
                })
            }
        @unknown default:
            break
        }
    }
    
    /**
     This method fetches the previous media messages for SharedMediaView.
     - Parameters:
     - entity: This specifies the entity for which messages are being fetched.
     - type: This specifies the type of entity for which messages are being fetched.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     */
    func fetchMediaMessages(for entity: AppEntity, type: CometChat.ReceiverType) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.startAnimating()
            self?.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self?.collectionView.bounds.width ?? 0, height: CGFloat(44))
            self?.collectionView.backgroundView = self?.activityIndicator
            self?.collectionView.backgroundView?.isHidden = false
        }
        switch type {
        case .user:
            mediaMessageRequest?.fetchPrevious(onSuccess: { (mediaMessages) in
                guard let fetchedMessages = mediaMessages?.filter({
                    (($0 as? MediaMessage)?.attachment != nil)}) else {
                        return }
                if let messages = fetchedMessages as? [MediaMessage] {
                    DispatchQueue.main.async { [weak self] in
                        switch self?.mediaSelection.selectedSegmentIndex {
                        case 0: self?.photos.append(contentsOf: messages)
                        case 1: self?.videos.append(contentsOf: messages)
                        case 2: self?.docs.append(contentsOf: messages)
                        default: break
                        }
                        self?.activityIndicator?.stopAnimating()
                        self?.collectionView.backgroundView?.isHidden = true
                        self?.collectionView.reloadData()
                    }
                }
             
            }, onError: { (error) in
                DispatchQueue.main.async { [weak self] in
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                        self?.activityIndicator?.stopAnimating()
                        self?.collectionView.backgroundView?.isHidden = true
                        self?.collectionView.reloadData()
                    }
                }
            })
        case .group:
            mediaMessageRequest?.fetchPrevious(onSuccess: { (mediaMessages) in
                guard let fetchedMessages = mediaMessages?.filter({
                    (($0 as? MediaMessage)?.attachment != nil)}) else {
                        return }
                if let messages = fetchedMessages as? [MediaMessage] {
                    DispatchQueue.main.async { [weak self] in
                        switch self?.mediaSelection.selectedSegmentIndex {
                        case 0: self?.photos.append(contentsOf: messages)
                        case 1: self?.videos.append(contentsOf: messages)
                        case 2: self?.docs.append(contentsOf: messages)
                        default: break
                        }
                        self?.activityIndicator?.stopAnimating()
                        self?.collectionView.backgroundView?.isHidden = true
                        self?.collectionView.reloadData()
                    }
                }
            }, onError: { (error) in
                DispatchQueue.main.async { [weak self] in
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                        self?.activityIndicator?.stopAnimating()
                        self?.collectionView.backgroundView?.isHidden = true
                        self?.collectionView.reloadData()
                    }
                }
            })
        @unknown default:break
        }
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    /**
     This method triggers when user changes the segment for media selection.
     - Parameter sender: A horizontal control made of multiple segments, each segment functioning as a discrete button.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     */
    @IBAction func didMediaSelectionPressed(_ sender: UISegmentedControl) {
        if let entity = entity {
            if let user = entity as? User {
                refreshMediaMessages(for: user, type: .user)
            }
            if let group = entity as? Group {
                refreshMediaMessages(for: group, type: .group)
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CollectionView Delegate


extension SharedMediaView : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// This method specifies number of items in collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.mediaSelection.selectedSegmentIndex {
        case 0:
            if photos.isEmpty  {
                self.collectionView.setEmptyMessage(NSLocalizedString("NO_PHOTOS", bundle: UIKitSettings.bundle, comment: ""))
            } else{
                self.collectionView.restore()
            }
            return photos.count
        case 1:
            if videos.isEmpty  {
                self.collectionView.setEmptyMessage(NSLocalizedString("NO_VIDEOS", bundle: UIKitSettings.bundle, comment: ""))
            } else{
                self.collectionView.restore()
            }
            return videos.count
        case 2:
            if docs.isEmpty  {
                self.collectionView.setEmptyMessage(NSLocalizedString("NO_DOCUMENTS", bundle: UIKitSettings.bundle, comment: ""))
            } else{
                self.collectionView.restore()
            }
            return docs.count
        default: break
        }
        return 0
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharedMediaCell", for: indexPath) as! SharedMediaCell
        switch self.mediaSelection.selectedSegmentIndex {
        case 0:
            if let photo = photos[safe:indexPath.row]{
                cell.message = photo
            }
        case 1:
            if let video = videos[safe:indexPath.row]{
                cell.message = video
            }
        case 2:
            if let file = docs[safe:indexPath.row]{
                cell.message = file
            }
        default: break
        }
        return cell
    }
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let seletedMedia = collectionView.cellForItem(at: indexPath) as? SharedMediaCell {
            switch self.mediaSelection.selectedSegmentIndex {
            case 0: sharedMediaDelegate?.didPhotoSelected(photo: seletedMedia.message)
            case 1: sharedMediaDelegate?.didVideoSelected(video: seletedMedia.message)
            case 2: sharedMediaDelegate?.didDocumentSelected(document: seletedMedia.message)
            default: break
            }
        }
    }
    
    
    /// Tells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - cell: A single data item when that item is within the collection view’s visible bounds.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastSectionIndex = collectionView.numberOfSections - 1
        let lastRowIndex = collectionView.numberOfItems(inSection: lastSectionIndex)  - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            if let user = entity as? User {
                self.fetchMediaMessages(for: user, type: .user)
            }
            if let group = entity as? Group {
                self.fetchMediaMessages(for: group, type: .group)
            }
        }
    }
    
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - collectionViewLayout: An abstract base class for generating layout information for a collection view.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        return CGSize(width: screenWidth/2 - 30, height: 120)
    }
}


/*  ----------------------------------------------------------------------------------------- */
