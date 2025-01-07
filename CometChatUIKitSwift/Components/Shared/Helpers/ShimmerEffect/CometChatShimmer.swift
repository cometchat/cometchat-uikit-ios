//
//  CometChatShimmer.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 28/09/24.
//

import UIKit
import Foundation

open class CometChatShimmerView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    public var colorGradient1: UIColor = CometChatTheme.backgroundColor04
    public var colorGradient2: UIColor = CometChatTheme.backgroundColor03
    
    public lazy var tableView = {
        let tableView = UITableView(frame: .null, style: .plain).withoutAutoresizingMaskConstraints()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    public var animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }()
    
    public init() {
        super.init(frame: .zero)
        buildUI()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func startShimmer() { }
    
    open func stopShimmer() {  }
    
    open func addShimmer(view: UIView, size: CGSize) {
        view.startAnimating(animation: animation, gradientColorOne: colorGradient1, gradientColorTwo: colorGradient2, size: size)
    }
    
    open func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
    open func buildUI() {
        withoutAutoresizingMaskConstraints()
        embed(tableView)
        tableView.separatorStyle = .none
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
