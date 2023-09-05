
//  StickerKeyboard.swift
//  Created by admin on 04/11/22.

import UIKit
import CometChatSDK

protocol  StickerViewDelegate {
    func didStickerSelected(sticker: CometChatSticker)
    func didStickerSetSelected(stickerSet: CometChatStickerSet)
    func didClosePressed()
}

protocol StickerkeyboardDelegate {
    func showStickerKeyboard(status: Bool)
}

@objc @IBDesignable public class CometChatStickerKeyboard: UIView {
    
    @IBOutlet weak var stickerSetCollectionVew: UICollectionView!
    @IBOutlet weak var stickersCollectionView: UICollectionView!
    @IBOutlet weak var stickerBackgroundView: UIView!
    @IBOutlet weak var stickerKeyboardSeparator: UIView!
    
    var emptyStateView: UIView?
    var errorStateView: UIView?
    var loadingStateView: UIView?
    var errorStateText: String?
    var emptyStateText: String?
    var keyboardStyle: StickerKeyboardStyle? 
    var allstickers = [CometChatSticker]()
    var stickers = [CometChatSticker]()
    var stickersForPreview = [CometChatSticker]()
    var stickerSet = [CometChatStickerSet]()
    var activityIndicator:UIActivityIndicatorView?
    var onStickerTap: ((_ sticker: CometChatSticker) -> Void)?
    var onStickerSetSelected: ((_ sticker: CometChatStickerSet) -> Void)?
    var onClose: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
            setupCollectionView()
            fetchStickers()
        }
    
    
    private func setupCollectionView() {
        
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        
        stickerBackgroundView.backgroundColor = CometChatTheme.palatte.background
        activityIndicator?.color = CometChatTheme.palatte.accent600
        stickerKeyboardSeparator.backgroundColor = CometChatTheme.palatte.accent100
        stickersCollectionView.showsVerticalScrollIndicator = false
        stickersCollectionView.showsHorizontalScrollIndicator = false
        stickersCollectionView.isPagingEnabled = true
        stickersCollectionView.dataSource = self
        stickersCollectionView.delegate = self
        stickerSetCollectionVew.showsVerticalScrollIndicator = false
        stickerSetCollectionVew.showsHorizontalScrollIndicator = false
        stickerSetCollectionVew.dataSource = self
        stickerSetCollectionVew.delegate = self
        let CometChatStickerKeyboardItem = UINib(nibName: "CometChatStickerKeyboardItem", bundle: CometChatUIKit.bundle)
        stickersCollectionView.register(CometChatStickerKeyboardItem, forCellWithReuseIdentifier: "CometChatStickerKeyboardItem")
        stickerSetCollectionVew.register(CometChatStickerKeyboardItem, forCellWithReuseIdentifier: "CometChatStickerKeyboardItem")
    }
    
    
    public func fetchStickers() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.startAnimating()
            self?.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self?.stickersCollectionView.bounds.width ?? 0, height: CGFloat(44))
            self?.stickersCollectionView.backgroundView = self?.activityIndicator
            self?.stickersCollectionView.backgroundView?.isHidden = false
        }
        self.stickerSet.removeAll()
        self.stickersForPreview.removeAll()
        self.allstickers.removeAll()
        self.stickers.removeAll()
        CometChat.callExtension(slug: ExtensionConstants.stickers, type: .get, endPoint: "v1/fetch", body: nil, onSuccess: { (response) in
            if let response = response {
                
                self.parseStickersSet(forData: response) { (result) in
                    result.forEach { (arg0) in
                        let (key, value) = arg0
                        let stickerSet = CometChatStickerSet(order: value.first?.setOrder ?? 0, id: value.first?.setID ?? "", thumbnail: value.first?.url ?? "", name: value.first?.setName ?? "", stickers: value)
                        
                        self.stickerSet.append(stickerSet)
                    }
                    
                    self.stickerSet = self.stickerSet.sorted {$0.order ?? 0 < $1.order ?? 0}
                    self.stickersForPreview = self.allstickers.filter({ ($0.setID == self.stickerSet.first?.id)})
                    DispatchQueue.main.async {
                        self.activityIndicator?.stopAnimating()
                        self.stickersCollectionView.backgroundView?.isHidden = true
                        self.stickersCollectionView.reloadData()
                        self.stickerSetCollectionVew.reloadData()
                    }
                }
            }
        }) { (error) in
            if let error = error {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.set(error: CometChatServerError.get(error: error))
                confirmDialog.open(onConfirm: { [weak self] in
                    guard let strongSelf = self else { return }
                    // Referesh list
                    strongSelf.stickerSetCollectionVew.reloadData()
                    strongSelf.stickersCollectionView.reloadData()
                })
            }
            print("Error with fetching stickers: \(String(describing: error?.errorDescription))")
        }
    }
    
    
    
    private func parseStickersSet(forData response: [String:Any]?, onSuccess:@escaping (_ success: [String? : [CometChatSticker]])-> Void) {
        
        if let response = response, let defaultStickerSet = response["defaultStickers"] as? NSArray, let customStickerSet = response["customStickers"] as? NSArray {
            
            for sticker in (defaultStickerSet as? [[String:Any]])! {
                
                let sticker = CometChatSticker(id: sticker["id"] as? String ?? "", name: sticker["stickerName"] as? String ?? "" , order: sticker["stickerOrder"] as? Int ?? 0, setID: sticker["stickerSetId"] as? String ?? "", setName: sticker["stickerSetName"] as? String ?? "", setOrder: sticker["stickerSetOrder"] as? Int ?? 0, url: sticker["stickerUrl"] as? String ?? "")
                
                stickers.append(sticker)
                allstickers.append(sticker)
            }
            
            for sticker in (customStickerSet as? [[String:Any]])! {
                
                let sticker = CometChatSticker(id: sticker["id"] as? String ?? "", name: sticker["stickerName"] as? String ?? "" , order: sticker["stickerOrder"] as? Int ?? 0, setID: sticker["stickerSetId"] as? String ?? "", setName: sticker["stickerSetName"] as? String ?? "", setOrder: sticker["stickerSetOrder"] as? Int ?? 0, url: sticker["stickerUrl"] as? String ?? "")
                
                stickers.append(sticker)
                allstickers.append(sticker)
            }
            
            let dictionary = Dictionary(grouping: stickers, by: { (element: CometChatSticker) in
                return element.setName
            })
            onSuccess(dictionary)
        }
    }
    
    
    @discardableResult
    public func setOnStickerTap(onStickerTap: @escaping (_ sticker: CometChatSticker) -> Void) -> Self {
        self.onStickerTap = onStickerTap
        return self
    }
    
    @discardableResult
    public func setOnStickerSetSelected(onStickerSetSelected: @escaping (_ stickerSet: CometChatStickerSet) -> Void) -> Self {
        self.onStickerSetSelected = onStickerSetSelected
        return self
    }
}


// MARK: - CollectionView Delegate


extension CometChatStickerKeyboard : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// This method specifies number of items in collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.stickerSetCollectionVew {
            return stickerSet.count
        }else if collectionView == self.stickersCollectionView {
            return stickersForPreview.count
        } else {
            return 0
        }
        
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sticketSetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CometChatStickerKeyboardItem", for: indexPath) as! CometChatStickerKeyboardItem
        if collectionView == self.stickersCollectionView {
            if stickersForPreview.count != 0 {
                if let sticker = stickersForPreview[safe: indexPath.row] {
                    sticketSetCell.sticker = sticker
                }
            }
        }else if collectionView == self.stickerSetCollectionVew {
            if stickerSet.count != 0 {
                let stickerCollection = stickerSet[safe: indexPath.row]
                sticketSetCell.stickerSet = stickerCollection
            }
        }
        return sticketSetCell
    }
    
    
    /// Tells the delegate that the item at the specified index path was selected.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.stickerSetCollectionVew {
            if let cell = collectionView.cellForItem(at: indexPath) as? CometChatStickerKeyboardItem, let stickerSet = cell.stickerSet, let stickers = stickerSet.stickers {
                self.stickersForPreview.removeAll()
                self.stickersForPreview = stickers
                for sticker in stickers {
                    self.stickersForPreview.append(sticker)
                }
                DispatchQueue.main.async {
                    self.stickersCollectionView.reloadData()
                    self.stickersCollectionView.setContentOffset(CGPoint.zero, animated: true)
                }
                onStickerSetSelected?(stickerSet)
                CometChatStickerKeyboard.stickerDelegate?.didStickerSetSelected(stickerSet: stickerSet)
            }
            
        }else if collectionView == self.stickersCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? CometChatStickerKeyboardItem, let sticker = cell.sticker {
                onStickerTap?(sticker)
                CometChatStickerKeyboard.stickerDelegate?.didStickerSelected(sticker: sticker)
                CometChatStickerKeyboard.stickerkeyboardDelegate?.showStickerKeyboard(status: false)
            }
        }
    }
    
    
    /// Tells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - cell: A single data item when that item is within the collection view’s visible bounds.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.stickerSetCollectionVew {
            
            
        }else if collectionView == self.stickersCollectionView {
            
            
        }
    }
    
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - collectionViewLayout: An abstract base class for generating layout information for a collection view.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.stickersCollectionView {
            return CGSize(width: 90, height: 90)
        }else if collectionView == self.stickerSetCollectionVew {
            return CGSize(width: 40, height: 40)
        }
        return CGSize(width: 0, height: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == stickersCollectionView {
            return 0
        } else {
            return 10
        }
        
    }
}

extension CometChatStickerKeyboard {
    static var stickerDelegate: StickerViewDelegate?
    static var stickerkeyboardDelegate: StickerkeyboardDelegate?
}
