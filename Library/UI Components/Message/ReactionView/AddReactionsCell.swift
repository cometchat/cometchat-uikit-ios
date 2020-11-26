import UIKit




class AddReactionsCell: UITableViewCell {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var reactionTitles: [String] = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.showsHorizontalScrollIndicator = false
        setupCollectionView()
        reactionTitles = ["😊","☹️","😂","😍","😭","🎉","👍","🚀","❤️", "✅"]
        
        collectionView.reloadData()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
    
    }
    
    /// This method will setup the collection view for smart replies
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let reactionCell = UINib(nibName: "ReactionCell", bundle: UIKitSettings.bundle)
        collectionView.register(reactionCell, forCellWithReuseIdentifier: "reactionCell")
        
    }

   
}

// MARK: - CollectionView Delegate Methods

extension AddReactionsCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    /// Asks your data source object for the number of items in the specified section.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - section: A signed integer value type.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactionTitles.count
    }
    
    
    /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
    /// - Parameters:
    ///   - collectionView: An object that manages an ordered collection of data items and presents them using customizable layouts.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reactionCell", for: indexPath) as! ReactionCell
        cell.delegate = self
        let title = reactionTitles[safe: indexPath.row]
        cell.reactionBtn.setTitle(title, for: .normal)
        return cell
    }
    
}

extension AddReactionsCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 65, height: 65)
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - SmartReplyCell Delegate Method

extension AddReactionsCell: ReactionCellDelegate {
    
    func didAddNewReactionPressed(reaction: String) {
        let reaction = MessageReaction(title: reaction, name: reaction, messageId: 0, reactors: [])
        ReactionView.reactionViewDelegate?.didReactionPressed(reaction: reaction)
    }
}

/*  ----------------------------------------------------------------------------------------- */
