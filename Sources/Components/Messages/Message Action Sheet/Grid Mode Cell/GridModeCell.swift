import UIKit

protocol GridModeDelegate: NSObject {
    func didTapOnAction(action: ActionItem)
}


class GridModeCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var gridDelegate: GridModeDelegate?
    
    var actionsItems: [ActionItem]?
    var cellsAcross: CGFloat = 2
    var reactionTitles: [String] = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        setupCollectionView()
        
        collectionView.reloadData()
    }
    
    func set(actionsItems: [ActionItem]) {
        self.actionsItems = actionsItems
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
    
    }
    
    /// This method will setup the collection view for smart replies
    private func setupCollectionView() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let gridView = UINib(nibName: "GridView", bundle: CometChatUIKit.bundle)
        collectionView.register(gridView, forCellWithReuseIdentifier: "GridView")
        
    }

   
}

// MARK: - CollectionView Delegate Methods

extension GridModeCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionsItems?.count ?? 0
    }
    
    
    private func configureCell(withTitle: String, icon: UIImage, tintColor: UIColor, forIndexPath: IndexPath) -> UICollectionViewCell {
     
        if let gridView = collectionView.dequeueReusableCell(withReuseIdentifier: "GridView", for: forIndexPath) as? GridView, let actionItem = self.actionsItems?[safe: forIndexPath.row] {
            gridView.set(actionItem: actionItem)
            return gridView
        }
        
        return UICollectionViewCell()
    }
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let actionItem = actionsItems?[safe: indexPath.row] {
            
            return configureCell(withTitle: actionItem.text ?? "" , icon: actionItem.startIcon ?? UIImage(), tintColor: .white, forIndexPath: indexPath)
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let actions = actionsItems {
            gridDelegate?.didTapOnAction(action: actions[indexPath.row])
        }
    }
}

extension GridModeCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width/cellsAcross - 2, height: 100)
    }
}


