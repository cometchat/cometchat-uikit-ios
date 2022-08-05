//
//  CometChatEmojiKeyboard.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 08/06/22.
//

import UIKit
import CometChatPro

protocol CometChatEmojiKeyboardPresentable {
   var string: String { get }
   var rowVC: UIViewController & PanModalPresentable { get }
}

protocol CometChatEmojiKeyboardDelegate: AnyObject {
    func onEmojiClick(emoji: CometChatEmoji, message: BaseMessage?)
}

class CometChatEmojiKeyboard: UIViewController, PanModalPresentable {
    
    // MARK: - Pan Model Presentable.
    var panScrollable: UIScrollView?
    var shortFormHeight: PanModalHeight {
        return .contentHeight(CGFloat(400.0))
    }
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var emojiSetCollectionView: UICollectionView!
    var emojiCategories: [CometChatEmojiCategory] = []
    var message: BaseMessage?
    
    static var emojiKeyboardDelegate: CometChatEmojiKeyboardDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchEmojis()
    }

    override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.backgroundColor = CometChatTheme.palatte?.background
            self.view = contentView
            self.view.backgroundColor = CometChatTheme.palatte?.background
            self.header.textColor = CometChatTheme.palatte?.accent
            self.cancel.setTitleColor(CometChatTheme.palatte?.primary, for: .normal)
        }
    }
    
    private func setupCollectionView() {
        emojiCollectionView.backgroundColor = CometChatTheme.palatte?.background
        emojiSetCollectionView.backgroundColor = CometChatTheme.palatte?.background
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiSetCollectionView.delegate = self
        emojiSetCollectionView.dataSource = self
        let headerNib = UINib(nibName: "CometChatEmojiHeader", bundle: CometChatUIKit.bundle)
        emojiCollectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CometChatEmojiHeader.identifier)
        let nib = UINib(nibName: "CometChatEmojiKeyboardItem", bundle: CometChatUIKit.bundle)
        emojiCollectionView.register(nib, forCellWithReuseIdentifier: CometChatEmojiKeyboardItem.idetifier)
        emojiSetCollectionView.register(nib, forCellWithReuseIdentifier: CometChatEmojiKeyboardItem.idetifier)
       
    }
    
    @discardableResult
    public func set(message: BaseMessage) -> Self {
        self.message = message
        return self
    }
    
    private func fetchEmojis() {
        
        CometChatEmojiCategoryJSON.getEmojis { [weak self] data in
            guard let strongSelf = self else { return }
            do {
                strongSelf.emojiCategories = try JSONDecoder().decode(CometChatEmojiCategories.self, from: data).emojiCategory
                DispatchQueue.main.async {
                    strongSelf.emojiCollectionView.reloadData()
                    strongSelf.emojiSetCollectionView.reloadData()
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func onCancelClick(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension CometChatEmojiKeyboard: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == emojiCollectionView {
            return emojiCategories.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojiCategories[section].emojis.count
        }
        return emojiCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CometChatEmojiKeyboardItem.idetifier, for: indexPath) as! CometChatEmojiKeyboardItem
            cell.emojiIcon.image = emojiCategories[indexPath.section].emojis[indexPath.row].emoji.textToImage()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CometChatEmojiKeyboardItem.idetifier, for: indexPath) as! CometChatEmojiKeyboardItem

        cell.emojiIcon.image =   UIImage(named: emojiCategories[indexPath.row].symbol, in: CometChatUIKit.bundle, compatibleWith: nil)
        cell.emojiIcon.tintColor = CometChatTheme.palatte?.accent600
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CometChatEmojiKeyboardItem else { return }
        cell.backgroundColor = .lightGray.withAlphaComponent(0.2)
        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                cell.backgroundColor = .clear
            }
        }
        if collectionView == emojiCollectionView {
            CometChatEmojiKeyboard.emojiKeyboardDelegate?.onEmojiClick(emoji: emojiCategories[indexPath.section].emojis[indexPath.row], message: message)
            
        } else if collectionView == emojiSetCollectionView {
            let index = IndexPath(row: emojiCategories.count - 1, section: indexPath.row)
            emojiCollectionView.scrollToItem(at: index, at: .centeredVertically, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == emojiCollectionView {
            return CGSize(width: 30, height: 30)
        }
        return CGSize(width: UIScreen.main.bounds.width / 8 * 0.75, height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == emojiCollectionView {
           return UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
        }
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == emojiCollectionView {
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CometChatEmojiHeader.identifier, for: indexPath) as! CometChatEmojiHeader
                headerView.category.text = emojiCategories[indexPath.section].name
                return headerView
            default:
                print("Either footer or default.")
            }
        }
        return UICollectionReusableView(frame: .zero)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == emojiCollectionView {
            return CGSize(width: emojiCollectionView.frame.width, height: 30)
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            self.emojiSetCollectionView.scrollToItem(at: IndexPath(row: indexPath.section, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        /*
        if collectionView == emojiCollectionView {
            let section = indexPath.section
            if let cell = emojiSetCollectionView.cellForItem(at: indexPath) as? CometChatEmojiKeyboardItem {
                if section == 0 {
                    cell.emojiIcon.tintColor = .green
                } else {
                    cell.emojiIcon.tintColor = .blue
                }
                
            }
        }*/
    }

}

// TODO: - This extension should be in separate file.
extension String {
    func textToImage() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 30) // font.
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) // begin image context.
        UIColor.clear.set() // clear background
        
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect.
        
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}
