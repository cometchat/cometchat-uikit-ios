//
//  CometChatListBase.swift
 
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatSDK

// MARK: - Declaration of Enum

/**
 `SearchState` is an enum which is being used for showing the state of the searchbar.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
public enum SearchState {
    /// Specifies an enum value where in this case seach bar will be empty
    case clear
    /// Specifies an enum value where in this case seach bar is active & searching
    case filter
}


/**
 `CometChatListBase` is a subclass of UIViewController which will be the base class for all list controllers. Other view controllers will inherit this class to use their methods & properties. .
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
open class CometChatListBase: UIViewController {
    
    // Title
    private(set) var titleColor: UIColor = .black
    private(set) var largeTitleColor: UIColor = .black
    private(set) var largeTitleFont: UIFont = CometChatTheme.typography.largeHeading
    private(set) var titleFont: UIFont = CometChatTheme.typography.title2
    //Search
    private(set) var search: UISearchController = UISearchController(searchResultsController: nil)
    private(set) var searchBackground: UIColor?
    private(set) var searchCornerRadius = CometChatCornerStyle(cornerRadius: 10)
    private(set) var searchPlaceholder: String = "SEARCH".localize()
    private(set) var searchPlaceholderColor: UIColor?
    private(set) var searchIconTint: UIColor?
    private(set) var searchClearIconTint: UIColor?
    private(set) var searchCancelButtonFont: UIFont = CometChatTheme.typography.name
    private(set) var searchCancelButtonTint: UIColor = CometChatTheme.palatte.primary
    private(set) var searchIcon = UIImage(systemName: "search")
    private(set) var searchClearIcon =  UIImage(systemName: "xmark.circle.fill")
    private(set) var searchTextColor: UIColor?
    private(set) var searchTextFont: UIFont?
    private(set) var searchBorderWidth: CGFloat = 0.0
    private(set) var searchBarHeight: CGFloat = 24.0
    private(set) var searchBorderColor: UIColor = .clear
    private(set) var hideSearch: Bool = true
    //Back
    private(set) var backButton: UIBarButtonItem?
    private(set) var backButtonTitle: String?
    private(set) var backButtonFont: UIFont = CometChatTheme.typography.title2
    private(set) var backButtonColor: UIColor = CometChatTheme.palatte.primary
    private(set) var backIcon = UIImage(named: "cometchatlistbase-back.png", in: CometChatUIKit.bundle, compatibleWith: nil)
    //Empty
    private(set) var emptyView: UIView?
    private(set) var emptyStateTextFont: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold)
    private(set) var emptyStateTextColor: UIColor = UIColor.gray
    //Error
    private(set) var errorView: UIView?
    private(set) var errorStateTextFont: UIFont?
    private(set) var errorStateTextColor: UIColor?
    private(set) var hideError: Bool = false
    private(set) var errorStateText: String = ""
    var emptyStateText: String = ""
    private(set) var loadingStateView: UIActivityIndicatorView.Style = .medium
    //Other
    private(set) var selectionMode: SelectionMode = .none
    private(set) var workItemReference: DispatchWorkItem? = nil
    
    var tableView: UITableView = {
        let table = UITableView()
        return table
    }()
    
    func onSearch(state: SearchState, text: String)  { }
    
    func onBackCallback() {}
    
    func setupTableView(style: UITableView.Style) {
        if style != .plain {
            tableView = UITableView(frame: .zero, style: style)
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setGradientBackground(withColors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = withColors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
    public func reload() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.tableView.reloadData()
        }
    }
    
    private func searchIsEmpty() -> Bool {
        return search.searchBar.text?.isEmpty ?? true
    }
    
    private func isSearching() -> Bool {
        let searchBarScopeIsFiltering = search.searchBar.selectedScopeButtonIndex != 0
        return search.isActive && (!searchIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func showIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.tableView.tableFooterView =  ActivityIndicator.show()
            this.tableView.tableFooterView?.isHidden = false
        }
    }
    
    func hideIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            ActivityIndicator.hide()
            this.tableView.tableFooterView?.isHidden = true
        }
    }
    
    @objc func onBackButtonTriggered() {
        onBackCallback()
    }
    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatListBase`.
     - Parameters:
     - background: This method will set the background color for CometChatListBase, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatListBase`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [CGColor]?) -> Self {
        if background?.count == 1 {
            if let first = background?.first {
                self.view.backgroundColor = UIColor(cgColor: first)
                if tableView.style == .plain {
                    self.tableView.backgroundColor = .clear
                } else {
                    self.tableView.backgroundColor = UIColor(cgColor: first).withAlphaComponent(0.1)
                }
            }
        } else {
            if let colors = background {
                setGradientBackground(withColors: colors)
            }
        }
        if navigationController != nil {
            let standard = UINavigationBarAppearance()
            standard.configureWithTransparentBackground()
            standard.backgroundColor = UIColor(cgColor: background?.first ?? UIColor.blue.cgColor)
            self.navigationController?.navigationBar.standardAppearance = standard
        }
        return self
    }
    
    @discardableResult
    public func set(loadingStateView: UIActivityIndicatorView.Style) -> Self {
        self.loadingStateView = loadingStateView
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        self.view.roundViewCorners(corner: corner)
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.view.borderWith(width: borderWidth)
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        self.view.borderColor(color: borderColor)
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView) -> Self {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView) -> Self {
        self.errorView = errorView
        return self
    }
    
    @discardableResult
    public func set(errorStateText: String) -> Self {
        self.errorStateText = errorStateText
        return self
    }
    
    @discardableResult
    public func hide(errorText: Bool) -> Self {
        self.hideError = errorText
        return self
    }
    
    @discardableResult
    public func set(emptyStateText: String) -> Self {
        self.emptyStateText = emptyStateText
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextFont: UIFont) -> Self {
        self.emptyStateTextFont = emptyStateTextFont
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextColor: UIColor) -> Self {
        self.emptyStateTextColor = emptyStateTextColor
        return self
    }
    
    @discardableResult
    public func set(errorStateTextFont: UIFont) -> Self {
        self.errorStateTextFont = errorStateTextFont
        return self
    }
    
    @discardableResult
    public func set(errorStateTextColor: UIColor) -> Self {
        self.errorStateTextColor = errorStateTextColor
        return self
    }
    
    @discardableResult
    public func hide(separator: Bool) -> Self {
        if separator {
            tableView.separatorColor = .clear
        } else {
            tableView.separatorStyle = .singleLine
        }
        return self
    }
    
    /**
     The back button is the `UIBarButtonItem` which the user can show if he wishes to in `CometChatListBase`.
     - Parameters:
     - backButton: This specifies an `boolean` which is being used for hide/show back button
     - Returns: This method will return `CometChatListBase`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func show(backButton: Bool) ->  Self {
        if backButton == true {
            if backButtonTitle != nil {
                self.backButton = UIBarButtonItem(title: backButtonTitle, style: .plain, target: self, action: #selector(self.onBackButtonTriggered))
                self.backButton?.setTitleTextAttributes([NSAttributedString.Key.font: backButtonFont], for: .normal)
             } else {
                self.backButton = UIBarButtonItem(image: backIcon, style: .plain, target: self, action: #selector(self.onBackButtonTriggered))
            }
            self.backButton?.tintColor = self.backButtonColor
            self.navigationItem.leftBarButtonItem = self.backButton
        }
        return self
    }
    
    /**
     This method is used for setting the color for back button in `CometChatListBase`.
     - Parameters:
     - backButtonTint: This specifies an `UIColor` which is being used for setting up the color for back button
     - Returns: This method will return `CometChatListBase`
     @objc  @objc  - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(backButtonTitle: String?) ->  Self {
        self.backButtonTitle = backButtonTitle
        return self
    }
    
    /**
     This method is used for setting the color for back button in `CometChatListBase`.
     - Parameters:
     - backButtonTint: This specifies an `UIColor` which is being used for setting up the color for back button
     - Returns: This method will return `CometChatListBase`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(backButtonTitleColor: UIColor) ->  Self {
        self.backButtonColor = backButtonTitleColor
        return self
    }
    
    @discardableResult
    public func set(backButtonFont: UIFont?) ->  Self {
        self.backButtonFont = backButtonFont ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        return self
    }
    
    /**
     This method is used for setting the color for back button in `CometChatListBase`.
     - Parameters:
     - backButtonTint: This specifies an `UIColor` which is being used for setting up the color for back button
     - Returns: This method will return `CometChatListBase`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(backButtonTint: UIColor) ->  Self {
        backButtonColor = backButtonTint
        return self
    }
    
    /**
     This method is used for setting the icon for back button in `CometChatListBase`.
     - Parameters:
     - backButtonIcon: This specifies an `UIImage` which is being used for setting up the image for back button
     - Returns: This method will return `CometChatListBase`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(backButtonIcon: UIImage) ->  Self {
        self.backIcon = backButtonIcon.withRenderingMode(.alwaysTemplate)
        return self
    }
    
    /**
     This method specifies the navigation bar title for `CometChatListBase`.
     - Parameters:
     - title: This takes the String to set title for `CometChatListBase`.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */

    @discardableResult
    public func set(title: String, mode: UINavigationItem.LargeTitleDisplayMode) ->  Self {
        if navigationController != nil{
            navigationItem.title = title.localize()
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
        return self
    }
    
    /**
     This method specifies the navigation bar title color  for `CometChatListBase`.
     - Parameters:
     - `titleColor`: This takes the UIColor to set title color for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(titleColor: UIColor) ->  Self {
        self.titleColor = titleColor
        setupNavigationBar()
        return self
    }
    
    @discardableResult
    public func set(largeTitleColor: UIColor) ->  Self {
        self.largeTitleColor = largeTitleColor
        setupNavigationBar()
        return self
    }
    
    /**
     This method specifies the navigation bar large  title font  for `CometChatListBase`.
     - Parameters:
     - `largeTitleFont`: This takes the `UIFont` to set large title font for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(largeTitleFont: UIFont) ->  Self {
        self.largeTitleFont = largeTitleFont
        setupNavigationBar()
        return self
    }
    
    /**
     This method specifies the navigation bar   title font  for `CometChatListBase`.
     - Parameters:
     - `titleFont`: This takes the `UIFont` to set  title font for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(titleFont: UIFont) ->  Self {
        self.titleFont = titleFont
        setupNavigationBar()
        return self
    }
    
    @discardableResult
    public func set(searchIcon: UIImage?) ->  Self {
        self.searchIcon = searchIcon
        return self
    }

    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchBackground: UIColor) -> Self {
        self.searchBackground = searchBackground
        return self
    }
    
    /**
     This method specifies the search  bar corner radius  for `CometChatListBase`.
     - Parameters:
     - `searchCornerRadius`: This takes the `CGFloat` to search  bar corner radius  for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchCornerRadius: CometChatCornerStyle) -> Self {
        self.searchCornerRadius = searchCornerRadius
        return self
    }
    
    /**
     This method specifies the search  bar placeholder  for `CometChatListBase`.
     - Parameters:
     - `searchPlaceholder`: This takes the `String` to search  bar placeholder  for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchPlaceholder: String) -> Self {
        self.searchPlaceholder = searchPlaceholder
        return self
    }
    
    /**
     This method specifies the search  bar placeholder  for `CometChatListBase`.
     - Parameters:
     - `searchPlaceholder`: This takes the `String` to search  bar placeholder  for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchPlaceholderColor: UIColor) -> Self {
        self.searchPlaceholderColor = searchPlaceholderColor
        return self
    }
    
    @discardableResult
    public func set(searchIcon: UIImage) -> Self {
        self.searchIcon = searchIcon
        return self
    }
    
    @discardableResult
    public func set(searchClearIcon: UIImage) -> Self {
        self.searchClearIcon = searchClearIcon
        return self
    }
    
    @discardableResult
    public func set(searchIconTint: UIColor) -> Self {
        self.searchIconTint = searchIconTint
        return self
    }
    
    @discardableResult
    public func set(searchClearIconTint: UIColor) -> Self {
        self.searchClearIconTint = searchClearIconTint
        return self
    }
    
    @discardableResult
    public func set(searchCancelButtonTint: UIColor) -> Self {
        self.searchCancelButtonTint = searchCancelButtonTint
        return self
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchCancelButtonFont: UIFont) -> Self {
        self.searchCancelButtonFont = searchCancelButtonFont
        return self
    }
    
    /**
     This method specifies the search  bar text color  for `CometChatListBase`.
     - Parameters:
     - `searchTextColor`: This takes the `UIColor` to search  bar  text color   for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchTextColor: UIColor) -> Self {
        self.searchTextColor = searchTextColor
        return self
    }
    
    /**
     This method specifies the search  bar text font  for `CometChatListBase`.
     - Parameters:
     - `searchTextFont`: This takes the `UIFont` to search  bar  text font   for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchTextFont: UIFont) -> Self {
        self.searchTextFont = searchTextFont
        return self
    }
    
    /**
     This method specifies the search  bar border width  for `CometChatListBase`.
     - Parameters:
     - `searchBorderWidth`: This takes the `CGFloat` to search  bar  border width  for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchBorderWidth: CGFloat) -> Self {
        self.searchBorderWidth = searchBorderWidth
        return self
    }
    
    @discardableResult
    public func set(searchBarHeight: CGFloat) -> Self {
        self.searchBarHeight = searchBarHeight
        return self
    }
    
    /**
     This method specifies the search  bar border color  for `CometChatListBase`.
     - Parameters:
     - `searchBorderColor`: This takes the `UIColor` to search  bar  border color  for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchBorderColor: UIColor) -> Self {
        self.searchBorderColor = searchBorderColor
        return self
    }
    
    /**
     This method specifies whether search bar should show or hide in  `CometChatListBase`.
     - Parameters:
     - `search`: This takes the `Bool` to hide/show search  bar   in `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func hide(search: Bool) -> Self {
        self.hideSearch = search
        setupSearch()
        return self
    }
    
    private func setupNavigationBar(){
        self.navigationController?.navigationBar.largeTitleTextAttributes =  [NSAttributedString.Key.foregroundColor: largeTitleColor, NSAttributedString.Key.font: largeTitleFont]
        
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font: titleFont]
    }
    
    private func setupSearch(){
        if hideSearch == false {
            //Search Background
            self.search.searchBar.searchTextField.backgroundColor = searchBackground
            
            //Search Placeholder & Color
            search.searchBar.placeholder =  searchPlaceholder
            search.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: search.searchBar.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : searchPlaceholderColor])
           
            //searchIconTint
            if let imageView = search.searchBar.searchTextField.leftView as? UIImageView {
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = searchIconTint
            }
            
            //searchClearIcon
            search.searchBar.setImage(searchClearIcon, for: .clear, state: .normal)
            
            if let searchTextField = search.searchBar.value(forKey: "searchField") as? UITextField, let clearButton = searchTextField.value(forKey: "clearButton") as? UIButton {
                let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
                clearButton.setImage(templateImage, for: .normal)
                
                //searchClearIconTint
                clearButton.tintColor = searchClearIconTint
                // Width
                searchTextField.layer.borderColor = searchBorderColor.cgColor
                searchTextField.layer.borderWidth = searchBorderWidth
            }
            //searchCancelButtonFont & searchCancelButtonTint
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): searchCancelButtonTint, NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): searchCancelButtonFont], for: .normal)

//            //Text Color & Font
            //search.searchBar.searchTextField.font = searchTextFont
            search.searchBar.searchTextField.textColor = searchTextColor
            
            //height and corner radius
           // search.searchBar.set(height: searchBarHeight, radius: searchCornerRadius.cornerRadius)
            if navigationController != nil {
                search.searchResultsUpdater = self
                search.searchBar.delegate = self
                
        
                search.searchBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 20)
                self.navigationItem.searchController = self.search
            }
           
        } else {
            search.searchBar.isHidden = true
        }
    }
    
    @discardableResult
    public func set(menus: [UIBarButtonItem]) -> Self {
       self.navigationItem.rightBarButtonItems = menus
        return self
    }
    
    @discardableResult
    public func selectionMode(mode: SelectionMode) -> Self {
        self.selectionMode = mode
        switch mode {
        case .single:
            self.tableView.allowsMultipleSelection = false
            self.tableView.allowsMultipleSelectionDuringEditing = false
        case .multiple:
            self.tableView.allowsMultipleSelection = true
            self.tableView.allowsMultipleSelectionDuringEditing = true
        case .none:
            self.tableView.allowsMultipleSelection = false
            self.tableView.allowsMultipleSelectionDuringEditing = false
        }
        return self
    }

}

extension CometChatListBase : UISearchBarDelegate, UISearchResultsUpdating {
    
    /**
     This method update the list of conversations as per string provided in search bar
     - Parameter searchController: The UISearchController object used as the search bar.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    public func updateSearchResults(for searchController: UISearchController) {
        workItemReference?.cancel()
        let dataSearchItem = DispatchWorkItem
        {
            if let text = searchController.searchBar.text {
                if text.isEmpty {
                    self.onSearch(state: .clear, text: "")
                 } else {
                    self.onSearch(state: .filter, text: text)
                }
            }
        }
        workItemReference = dataSearchItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: dataSearchItem)
    }
}

extension CometChatListBase: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 10.0
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {}

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {}
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    } 
}


