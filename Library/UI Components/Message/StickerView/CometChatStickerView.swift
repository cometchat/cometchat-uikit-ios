//
//  CometChatStickerView.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 05/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro

protocol  StickerViewDelegate {
     func didStickerSelected(sticker: Sticker)
     func didStickerSetSelected(stickerSet: StickerSet)
     func didClosePressed()
}



class CometChatStickerView: UIViewController {

    @IBOutlet weak var stickersCollectionView: UICollectionView!
    @IBOutlet weak var stickerSetCollectionVew: UICollectionView!
    @IBOutlet weak var stickerBackgroundView: UIView!
    
    var allstickers = [Sticker]()
    var stickers = [Sticker]()
    var stickersForPreview = [Sticker]()
    var stickerSet = [StickerSet]()
    var activityIndicator:UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackgroundView()
        self.setupCollectionView()
        self.fetchStickers()
        
    }
    
    override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatStickerView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    private func setupBackgroundView(){
        stickerBackgroundView.roundViewCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
    }
    
    private func setupCollectionView() {
        
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        stickersCollectionView.showsVerticalScrollIndicator = false
        stickersCollectionView.showsHorizontalScrollIndicator = false
        stickersCollectionView.isPagingEnabled = true
        stickersCollectionView.dataSource = self
        stickersCollectionView.delegate = self
        stickerSetCollectionVew.showsVerticalScrollIndicator = false
        stickerSetCollectionVew.showsHorizontalScrollIndicator = false
        stickerSetCollectionVew.dataSource = self
        stickerSetCollectionVew.delegate = self
        let StickerCell = UINib(nibName: "StickerCell", bundle: UIKitSettings.bundle)
        stickersCollectionView.register(StickerCell, forCellWithReuseIdentifier: "stickerCell")
        stickerSetCollectionVew.register(StickerCell, forCellWithReuseIdentifier: "stickerCell")
    }
    
    private func fetchStickers() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator?.startAnimating()
            self?.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self?.stickersCollectionView.bounds.width ?? 0, height: CGFloat(44))
            self?.stickersCollectionView.backgroundView = self?.activityIndicator
            self?.stickersCollectionView.backgroundView?.isHidden = false
        }
        CometChat.callExtension(slug: "stickers", type: .get, endPoint: "v1/fetch", body: nil) { (response) in
            if let response = response {
               
                 self.parseStickersSet(forData: response) { (result) in
                    result.forEach { (arg0) in
                        let (key, value) = arg0
                        let stickerSet = StickerSet(order: value.first?.setOrder ?? 0, id: value.first?.setID ?? "", thumbnail: value.first?.url ?? "", name: value.first?.setName ?? "", stickers: value)
                        
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
           
        } onError: { (error) in
            print("Error with fetching stickers: \(String(describing: error?.errorDescription))")
        }
    }
    
    private func parseStickersSet(forData response: [String:Any]?, onSuccess:@escaping (_ success: [String? : [Sticker]])-> Void) {
        
        if let response = response, let defaultStickerSet = response["defaultStickers"] as? NSArray, let customStickerSet = response["customStickers"] as? NSArray {
            
            for sticker in (defaultStickerSet as? [[String:Any]])! {
                
                let sticker = Sticker(id: sticker["id"] as? String ?? "", name: sticker["stickerName"] as? String ?? "" , order: sticker["stickerOrder"] as? Int ?? 0, setID: sticker["stickerSetId"] as? String ?? "", setName: sticker["stickerSetName"] as? String ?? "", setOrder: sticker["stickerSetOrder"] as? Int ?? 0, url: sticker["stickerUrl"] as? String ?? "")
               
                stickers.append(sticker)
                allstickers.append(sticker)
            }
            
            for sticker in (customStickerSet as? [[String:Any]])! {
                print("custom stickers: \(sticker)")
                let sticker = Sticker(id: sticker["id"] as? String ?? "", name: sticker["stickerName"] as? String ?? "" , order: sticker["stickerOrder"] as? Int ?? 0, setID: sticker["stickerSetId"] as? String ?? "", setName: sticker["stickerSetName"] as? String ?? "", setOrder: sticker["stickerSetOrder"] as? Int ?? 0, url: sticker["stickerUrl"] as? String ?? "")
               
                stickers.append(sticker)
                allstickers.append(sticker)
            }
            
            let dictionary = Dictionary(grouping: stickers, by: { (element: Sticker) in
                return element.setName
            })
            onSuccess(dictionary)
        }
    }

    @IBAction func didCloseButtonPressed(_ sender: Any) {
        CometChatStickerView.stickerDelegate?.didClosePressed()
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - CollectionView Delegate


extension CometChatStickerView : UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// This method specifies number of items in collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.stickerSetCollectionVew {
            return stickerSet.count
        }else if collectionView == self.stickersCollectionView {
            return stickersForPreview.count
        }else {
            return 0
        }
        
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sticketSetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerCell
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.stickerSetCollectionVew {
            if let cell = collectionView.cellForItem(at: indexPath) as? StickerCell, let stickerSet = cell.stickerSet, let stickers = stickerSet.stickers {
                self.stickersForPreview.removeAll()
                self.stickersForPreview = stickers
                for sticker in stickers {
                    self.stickersForPreview.append(sticker)
                }
                DispatchQueue.main.async {
                    self.stickersCollectionView.reloadData()
                    self.stickersCollectionView.setContentOffset(CGPoint.zero, animated: true)
                }
                CometChatStickerView.stickerDelegate?.didStickerSetSelected(stickerSet: stickerSet)
            }
            
        }else if collectionView == self.stickersCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? StickerCell, let sticker = cell.sticker {
                CometChatStickerView.stickerDelegate?.didStickerSelected(sticker: sticker)
            }
        }
    }
    
    
    /// Tells the delegate that the specified cell is about to be displayed in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - cell: A single data item when that item is within the collection view’s visible bounds.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.stickerSetCollectionVew {
            
            
        }else if collectionView == self.stickersCollectionView {
            
            
        }
    }
    
    
    
    /// Asks the delegate for the size of the specified item’s cell.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - collectionViewLayout: An abstract base class for generating layout information for a collection view.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.stickersCollectionView {
            
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            return CGSize(width: 90, height: 90)
            
        }else if collectionView == self.stickerSetCollectionVew {
            
            let screenSize = UIScreen.main.bounds
            let screenWidth = screenSize.width
            return CGSize(width: 60, height: 60)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
        {
        return UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        }
}

extension CometChatStickerView {
    static var stickerDelegate: StickerViewDelegate?
}
