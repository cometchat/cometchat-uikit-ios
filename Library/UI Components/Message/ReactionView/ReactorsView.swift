//
//  ReactorsView.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 25/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit

class ReactorsView: UITableViewController {
        
    var reactors = [MessageReaction]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        set(title: "Reactions", mode: .always)
    }
    
    func set(reactors: [MessageReaction]) {
        self.reactors = reactors
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = NSLocalizedString(title, bundle: UIKitSettings.bundle, comment: "")
            navigationItem.largeTitleDisplayMode = mode
            switch mode {
            case .automatic:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .always:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .never:
                navigationController?.navigationBar.prefersLargeTitles = false
            @unknown default:break }
        }
    }
    
    private func setupTableView() {
        let CometChatUserView  = UINib.init(nibName: "CometChatUserView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatUserView, forCellReuseIdentifier: "userView")
        self.tableView.tableFooterView = UIView(frame: .zero)
       
    }
    
    private func setupNavigationBar(){
        if navigationController != nil{
            // NavigationBar Appearance
            self.addCloseButton(bool: true)
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font:UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
        }}
    
    private func addCloseButton(bool: Bool){
        if bool == true {
            let closeButton = UIBarButtonItem(title: NSLocalizedString("CLOSE", bundle: UIKitSettings.bundle, comment: ""), style: .plain, target: self, action: #selector(didCloseButtonPressed))
            closeButton.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    @objc func didCloseButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return reactors.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return reactors[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reactors[safe:section]?.reactors?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let staticCell = UITableViewCell()
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userView", for: indexPath) as? CometChatUserView {
            let user = reactors[safe: indexPath.section]?.reactors?[safe:indexPath.row]
            cell.userName.text = user?.name
            cell.userAvatar.set(image: user?.avatar ?? "", with: user?.name ?? "")
            return cell
        }
        return staticCell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
