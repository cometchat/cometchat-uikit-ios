//
//  NotificationFeedShimmerView.swift
//  CometChatUIKitSwift
//
//  Created by CometChat on 14/05/26.
//

import UIKit

open class NotificationFeedShimmerView: CometChatShimmerView {
    
    public var cellCount = 4
    var cellCountManager = 0
    
    open override func buildUI() {
        super.buildUI()
        backgroundColor = UIColor(hex: "#FAFAFA")
        tableView.backgroundColor = UIColor(hex: "#FAFAFA")
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ShimmerCell")
    }
    
    open override func startShimmer() {
        cellCountManager = cellCount
        tableView.reloadData()
    }
    
    open override func stopShimmer() {
        cellCountManager = 0
        tableView.reloadData()
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCountManager
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 174 // Fixed height: 150 card + 8 top + 8 bottom + 8 spacing
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShimmerCell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // Card shimmer container
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 12
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(hex: "#E9EAEB").cgColor
        cardView.clipsToBounds = true
        cell.contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8)
        ])
        
        // Title shimmer bar
        let titleView = UIView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.layer.cornerRadius = 4
        cardView.addSubview(titleView)
        
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleView.widthAnchor.constraint(equalToConstant: 160),
            titleView.heightAnchor.constraint(equalToConstant: 16)
        ])
        addShimmer(view: titleView, size: CGSize(width: 160, height: 16))
        
        // Subtitle shimmer bar
        let subtitleView = UIView()
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        subtitleView.layer.cornerRadius = 4
        cardView.addSubview(subtitleView)
        
        NSLayoutConstraint.activate([
            subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            subtitleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            subtitleView.widthAnchor.constraint(equalToConstant: 100),
            subtitleView.heightAnchor.constraint(equalToConstant: 14)
        ])
        addShimmer(view: subtitleView, size: CGSize(width: 100, height: 14))
        
        // Description line shimmer
        let descView = UIView()
        descView.translatesAutoresizingMaskIntoConstraints = false
        descView.layer.cornerRadius = 4
        cardView.addSubview(descView)
        
        NSLayoutConstraint.activate([
            descView.topAnchor.constraint(equalTo: subtitleView.bottomAnchor, constant: 8),
            descView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            descView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -40),
            descView.heightAnchor.constraint(equalToConstant: 12)
        ])
        addShimmer(view: descView, size: CGSize(width: 250, height: 12))
        
        // Button row shimmer
        let btn1 = UIView()
        btn1.translatesAutoresizingMaskIntoConstraints = false
        btn1.layer.cornerRadius = 6
        cardView.addSubview(btn1)
        
        let btn2 = UIView()
        btn2.translatesAutoresizingMaskIntoConstraints = false
        btn2.layer.cornerRadius = 6
        cardView.addSubview(btn2)
        
        NSLayoutConstraint.activate([
            btn1.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            btn1.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            btn1.heightAnchor.constraint(equalToConstant: 32),
            btn1.widthAnchor.constraint(equalToConstant: 100),
            
            btn2.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            btn2.leadingAnchor.constraint(equalTo: btn1.trailingAnchor, constant: 8),
            btn2.heightAnchor.constraint(equalToConstant: 32),
            btn2.widthAnchor.constraint(equalToConstant: 80)
        ])
        addShimmer(view: btn1, size: CGSize(width: 100, height: 32))
        addShimmer(view: btn2, size: CGSize(width: 80, height: 32))
        
        return cell
    }
}
