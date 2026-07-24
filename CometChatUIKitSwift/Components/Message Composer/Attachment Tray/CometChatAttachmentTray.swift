//
//  CometChatAttachmentTray.swift
//  CometChatUIKitSwift
//
//  Horizontal strip of attachment preview tiles shown above the composer input while
//  the user is staging a multi-attachment message. Image/video render as 72×72
//  thumbnails; files/audio render as 200×72 chips (per the design system).
//

import UIKit

public final class CometChatAttachmentTray: UIView {

    /// Tapped the remove/cancel control on a tile.
    public var onRemove: ((AttachmentTile) -> Void)?
    /// Tapped retry on a failed tile.
    public var onRetry: ((AttachmentTile) -> Void)?
    /// Tapped the tile body (not a control) — used to open the media viewer.
    public var onTileTapped: ((AttachmentTile) -> Void)?

    private var tiles: [AttachmentTile] = []

    private let rowHeight: CGFloat = 72

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: CometChatSpacing.Padding.p3,
                                           bottom: 0, right: CometChatSpacing.Padding.p3)

        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.alwaysBounceHorizontal = true
        collection.clipsToBounds = false
        collection.register(CometChatAttachmentTileCell.self, forCellWithReuseIdentifier: CometChatAttachmentTileCell.reuseId)
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildUI() {
        backgroundColor = .clear
        clipsToBounds = false
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            // Top padding leaves room for the badge that overhangs the tile corner.
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            collectionView.heightAnchor.constraint(equalToConstant: rowHeight)
        ])
    }

    /// Replace the tray contents and reload.
    public func set(tiles: [AttachmentTile]) {
        self.tiles = tiles
        collectionView.reloadData()
    }

    /// Update a single tile in place (e.g. on progress) without a full reload.
    public func update(tile: AttachmentTile) {
        guard let index = tiles.firstIndex(where: { $0.fileId == tile.fileId }) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        if let cell = collectionView.cellForItem(at: indexPath) as? CometChatAttachmentTileCell {
            configure(cell, with: tiles[index])
        }
    }

    private func configure(_ cell: CometChatAttachmentTileCell, with tile: AttachmentTile) {
        cell.configure(with: tile)
        cell.onClose = { [weak self] in self?.onRemove?(tile) }
        cell.onRetry = { [weak self] in self?.onRetry?(tile) }
        cell.onTileTap = { [weak self] in self?.onTileTapped?(tile) }
    }
}

extension CometChatAttachmentTray: UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CometChatAttachmentTileCell.reuseId, for: indexPath)
        if let tileCell = cell as? CometChatAttachmentTileCell {
            configure(tileCell, with: tiles[indexPath.item])
        }
        return cell
    }
}

extension CometChatAttachmentTray: UICollectionViewDelegateFlowLayout {

    // Tile taps are routed through the cell (`onTileTap`) so the ✕ badge and the tile
    // body stay distinct; we don't use collection-view selection here.

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let kind = tiles[indexPath.item].kind
        switch kind {
        case .image, .video:
            return CometChatAttachmentTileCell.mediaSize
        case .audio, .file:
            return CometChatAttachmentTileCell.chipSize
        }
    }
}
