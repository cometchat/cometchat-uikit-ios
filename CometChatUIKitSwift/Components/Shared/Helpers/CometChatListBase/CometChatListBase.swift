//
//  CometChatListBase.swift
//
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2024 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import Foundation
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
open class CometChatListBase: UIViewController, StateManagement {
    
    var listBaseStyle: ListBaseStyle = ConversationsStyle() //TODO FIX THIS
    var searchStyle: SearchBarStyle?
    public var tableView: UITableView!
    
    //MARK: - SEARCH CONTROLLER
    public lazy var searchController: UISearchController = {
        let searchBar = UISearchController(searchResultsController: nil)
        return searchBar
    }()
    var searchPlaceholderText: String = "SEARCH".localize()
    var searchIcon = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
    var searchClearIcon =  UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
    public var hideNavigationBar: Bool = false
    public var hideSearch: Bool = true {
        didSet {
            if hideSearch == false{
                setupSearchBar()
            }
        }
    }
    
    //MARK: - loading view
    public var loadingView: UIView!
    var isLoadingViewVisible = false
    
    //MARK: - Error Views
    public lazy var emptyStateView: UIView = {
        let stateView = StateView(title: emptyStateTitleText, subtitle: emptyStateSubTitleText, image: emptyStateImage)
        return stateView
    }()
    public var emptyStateImage: UIImage = UIImage() {
        didSet {
            (emptyStateView as? StateView)?.image = emptyStateImage
        }
    }
    public var emptyStateTitleText: String = "" {
        didSet {
            (emptyStateView as? StateView)?.title = emptyStateTitleText
        }
    }
    public var emptyStateSubTitleText: String = "" {
        didSet {
            (emptyStateView as? StateView)?.subtitle = emptyStateSubTitleText
        }
    }
    var isEmptyStateVisible = false
    public var disableEmptyState: Bool = false

    //MARK: - Empty Views
    public lazy var errorStateView: UIView = {
        let stateView = StateView(title: errorStateTitleText, subtitle: errorStateSubTitleText, image: errorStateImage, buttonText: "RETRY".localize())
        return stateView
    }()
    public var errorStateImage: UIImage = UIImage() {
        didSet {
            (errorStateView as? StateView)?.image = errorStateImage
        }
    }
    public var errorStateTitleText: String = "" {
        didSet {
            (errorStateView as? StateView)?.title = errorStateTitleText
        }
    }
    public var errorStateSubTitleText: String = "" {
        didSet {
            (errorStateView as? StateView)?.subtitle = errorStateSubTitleText
        }
    }
    public var hideErrorView: Bool = false
    public var isErrorStateVisible: Bool = false
    
    //MARK: - Other Public Variables
    var hideSeparator = false {
        didSet {
            tableView.separatorStyle = hideSeparator ? .none : .singleLine
        }
    }
    public var selectionMode: SelectionMode = .none {
        didSet {
            if let tableView = tableView, let selectedRows = tableView.indexPathsForSelectedRows {
                for indexPath in selectedRows { tableView.deselectRow(at: indexPath, animated: true) }
                tableView.reloadData()
            }
        }
    }
    public var leftBarButtonItem: [UIBarButtonItem] = []
    public var rightBarButtonItem: [UIBarButtonItem] = []
    public var navigationTitleText = ""
    public var isNavigationTranslucent = true
    public var hideBackButton = true
    public var hideLoadingState: Bool = false
    public var prefersLargeTitles = true
    private var searchWorkItem: DispatchWorkItem? = nil
    public lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshControlTriggered), for: .valueChanged)
        return refreshControl
    }()
    
    var onBack: (() -> Void)?

    
    //MARK: - LIFE CYCLE FUNCTION
    open override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !hideNavigationBar{
            setupNavigationBar()
        }else{
            if let navigationController = navigationController{
                self.navigationController?.navigationBar.isHidden = true
            }
        }
        
        if !hideSearch {
            setupSearchBar()
        }
        setupStyle()
    }
    
    open func buildUI() {
        setupTableView(style: .plain)
    }
    
    open func onSearch(state: SearchState, text: String)  {
        
    }
    
    open func reload() {
        tableView.reloadData()
    } 
    
    open func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
    open func setupTableView(style: UITableView.Style = .plain, withRefreshControl: Bool = false) {
        if let tableView = tableView { tableView.removeFromSuperview() }
        tableView = UITableView(frame: .zero, style: style)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        if withRefreshControl {
            tableView.refreshControl = refreshControl
        }
        view.embed(tableView)
    }
    
    @objc func onRefreshControlTriggered() { }
    
    open func setGradientBackground(withColors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = withColors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    open func showFooterIndicator() {
        tableView.tableFooterView = ActivityIndicator.show()
        tableView.tableFooterView?.isHidden = false
    }
    
    open func hideFooterIndicator() {
        ActivityIndicator.hide()
        tableView.tableFooterView?.isHidden = true
    }
    
    open func showLoadingView() {
        if hideLoadingState { return }
        guard let loadingView = loadingView else { return }

        (loadingView as? CometChatShimmerView)?.startShimmer()
        isLoadingViewVisible = true

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            loadingView.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.leadingAnchor.pin(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.pin(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.pin(equalTo: view.bottomAnchor)
        ])
    }
    
    open func removeLoadingView() {
        (loadingView as? CometChatShimmerView)?.stopShimmer()
        isLoadingViewVisible = false
        loadingView?.removeFromSuperview()
    }
    
    /// This Function will show empty view
    open func showEmptyView() {
        if disableEmptyState { return }
        isEmptyStateVisible = true
        view.addSubview(emptyStateView)
        emptyStateView.pin(anchors: [.centerX, .centerY], to: view)
    }
    
    /// This Function will show error view
    open func showErrorView() {
        if hideErrorView { return }
        isErrorStateVisible = true
        view.addSubview(errorStateView)
        errorStateView.pin(anchors: [.centerX, .centerY], to: view)
    }
    
    /// This Function will hide error view
    open func removeErrorView() {
        isErrorStateVisible = false
        errorStateView.removeFromSuperview()
    }
    
    /// This Function will hide empty view
    open func removeEmptyView() {
        isEmptyStateVisible = false
        emptyStateView.removeFromSuperview()
    }
    
    /// This function will set style from the component's style variable
    open func setupStyle() {
        tableView.backgroundColor = listBaseStyle.backgroundColor
        tableView.borderWith(width: listBaseStyle.borderWidth)
        tableView.borderColor(color: listBaseStyle.borderColor)
        tableView.roundViewCorners(corner: listBaseStyle.cornerRadius)
        
        if let errorStateView = errorStateView as? StateView {
            errorStateView.subtitleLabel.font = listBaseStyle.errorSubTitleFont
            errorStateView.subtitleLabel.textColor = listBaseStyle.errorSubTitleTextColor
            errorStateView.titleLabel.font = listBaseStyle.errorTitleTextFont
            errorStateView.titleLabel.textColor = listBaseStyle.errorTitleTextColor
            errorStateView.imageView.tintColor = CometChatTheme.neutralColor300
        }
        
        if let emptyStateView = emptyStateView as? StateView {
            emptyStateView.subtitleLabel.font = listBaseStyle.emptySubTitleFont
            emptyStateView.subtitleLabel.textColor = listBaseStyle.emptySubTitleTextColor
            emptyStateView.titleLabel.font = listBaseStyle.emptyTitleTextFont
            emptyStateView.titleLabel.textColor = listBaseStyle.emptyTitleTextColor
            emptyStateView.imageView.tintColor = CometChatTheme.neutralColor300
        }
        
        styleSearchBar()
        styleNavigationBar()
    }
    
    /// This function will set style for search bar from the component's style variable
    open func styleSearchBar() {
      
        if hideSearch { return }


        if let searchTintColor = searchStyle?.searchTintColor{
            searchController.searchBar.tintColor = searchTintColor
        }

        if let searchBarTintColor = searchStyle?.searchBarTintColor{
            searchController.searchBar.barTintColor = searchBarTintColor
        }
        
        if let searchBarStyle = searchStyle?.searchBarStyle{
            searchController.searchBar.searchBarStyle = searchBarStyle
        }
        
        if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {

            let placeholderText = searchTextField.placeholder ?? ""
            
            if let placeholderTextColor = searchStyle?.searchBarPlaceholderTextColor{
                let placeholderAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: placeholderTextColor]
                searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
            }
            
            if let placeholderTextFont = searchStyle?.searchBarPlaceholderTextFont{
                let placeholderAttributes: [NSAttributedString.Key: Any] = [
                    .font: placeholderTextFont
                ]
                searchTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
            }
            
            if let searchBarTextColor = searchStyle?.searchBarTextColor{
                searchTextField.textColor = searchBarTextColor
            }
            

            if let searchBarTextFont = searchStyle?.searchBarTextFont{
                searchTextField.font = searchBarTextFont
            }
            
            if let searchBarBackgroundColor = searchStyle?.searchBarBackgroundColor{
                searchTextField.backgroundColor = searchBarBackgroundColor
            }
        }

        if let searchIconView = searchController.searchBar.searchTextField.leftView as? UIImageView, let searchIconTintColor = searchStyle?.searchIconTintColor{
            searchIconView.image = searchIcon // Set the custom image for the search icon.
            searchIconView.tintColor = searchIconTintColor // Set the tint color for the search icon.
        }

        if let clearButton = searchController.searchBar.searchTextField.value(forKey: "clearButton") as? UIButton, let searchBarCrossIconTintColor = searchStyle?.searchBarCrossIconTintColor{
            clearButton.setImage(searchClearIcon, for: .normal) // Set the custom image for the clear button.
            clearButton.tintColor = searchBarCrossIconTintColor // Set the tint color for the clear button.
        }

        if let cancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton, let searchBarCancelIconTintColor = searchStyle?.searchBarCancelIconTintColor {
            cancelButton.setTitleColor(searchBarCancelIconTintColor, for: .normal)
            cancelButton.setTitle("CANCEL".localize(), for: .normal)
        }
    }
    
    /// This will set up search bar for the component
    open func setupSearchBar() {
        if navigationController != nil {
            searchController.searchBar.placeholder = searchPlaceholderText
            searchController.searchResultsUpdater = self
            searchController.searchBar.delegate = self
            if #available(iOS 16,*){
                self.navigationItem.preferredSearchBarPlacement = .stacked
            }
            self.navigationItem.searchController = self.searchController
            self.navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    /// This will set up navigation bar for the component
    open func setupNavigationBar() {
        if let navigationController = navigationController {
            navigationController.title = navigationTitleText
            navigationController.navigationBar.isTranslucent = isNavigationTranslucent
            navigationItem.hidesBackButton = hideBackButton
            navigationItem.rightBarButtonItems = rightBarButtonItem
            navigationItem.leftBarButtonItems = leftBarButtonItem
            if !hideBackButton{
                if #available(iOS 16.0, *) {
                    navigationItem.backAction = UIAction { [weak self] _ in
                        self?.onBack?()
                    }
                } else {
                    navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(addBackPress))
                }
            }
            if prefersLargeTitles {
                navigationController.navigationBar.prefersLargeTitles = true
                navigationItem.largeTitleDisplayMode = .always
            } else {
                navigationController.navigationBar.prefersLargeTitles = false
                navigationItem.largeTitleDisplayMode = .never
            }
        }
    }
    
   @objc func addBackPress(){
       self.onBack?()
    }
    
    /// This will all add style in navigation bar for the component
    open func styleNavigationBar() {
        if let navigationController = navigationController {
            if let navigationBarTintColor = listBaseStyle.navigationBarTintColor {
                navigationController.navigationBar.barTintColor = navigationBarTintColor
            }
            
            if let navigationBarItemsTintColor = listBaseStyle.navigationBarItemsTintColor {
                navigationController.navigationBar.tintColor = navigationBarItemsTintColor
            }
            
            var titleTextAttributes = [NSAttributedString.Key : Any]()
    
            if let titleColor = listBaseStyle.titleColor {
                titleTextAttributes.append(with: [NSAttributedString.Key.foregroundColor: titleColor])
            }
            
            if let titleFont = listBaseStyle.titleFont {
                titleTextAttributes.append(with: [NSAttributedString.Key.font: titleFont])
            }
            
            if !titleTextAttributes.isEmpty {
                navigationController.navigationBar.titleTextAttributes = titleTextAttributes
            }
            
            var largeTitleAttributes = [NSAttributedString.Key : Any]()
            
            if let largeTitleFont = listBaseStyle.largeTitleFont {
                largeTitleAttributes.append(with: [NSAttributedString.Key.font: largeTitleFont])
            }
            
            if let largeTitleColor = listBaseStyle.largeTitleColor {
                largeTitleAttributes.append(with: [NSAttributedString.Key.foregroundColor: largeTitleColor])
            }
            
            if !largeTitleAttributes.isEmpty {
                navigationController.navigationBar.largeTitleTextAttributes = largeTitleAttributes
            }
        }
    }

}

extension CometChatListBase : UISearchBarDelegate, UISearchResultsUpdating {
    
    /**
     This method update the list of conversations as per string provided in search bar
     - Parameter searchController: The UISearchController object used as the search bar.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    open func updateSearchResults(for searchController: UISearchController) {
        searchWorkItem?.cancel()
        let dataSearchItem = DispatchWorkItem
        { [weak self] in
            if let text = searchController.searchBar.text {
                if text.isEmpty {
                    self?.onSearch(state: .clear, text: "")
                 } else {
                    self?.onSearch(state: .filter, text: text)
                }
            }
        }
        searchWorkItem = dataSearchItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: dataSearchItem)
    }
    
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async { [weak self] in
            if let cancelButton = self?.searchController.searchBar.value(forKey: "cancelButton") as? UIButton, let searchBarCancelIconTintColor = self?.searchStyle?.searchBarCancelIconTintColor {
                cancelButton.setTitleColor(searchBarCancelIconTintColor, for: .normal)
            }
        }
    }
}

extension CometChatListBase: UITableViewDelegate, UITableViewDataSource {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 10.0
    }
    
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
    
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {}
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {}
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {  }
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {  }
    
    
    // called on start of dragging (may require some time and or distance to move)
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
    
    // called when scroll view grinds to a halt
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}

    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}

    // return a view that will be scaled. if delegate returns nil, nothing happens
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? { return nil }

    // called before the scroll view begins zooming its content
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {}

    // scale between minimum and maximum. called after any 'bounce' animations
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {}

    
    // return a yes if you want to scroll to the top. if not defined, assumes YES
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }

    // called when scrolling animation finished. may be called immediately if already at top
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {}

    
    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {}
    
}

//
extension CometChatListBase {
    
    public func searchIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    public func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchIsEmpty() || searchBarScopeIsFiltering)
    }
    
    @discardableResult
    public func set(selectionMode: SelectionMode) -> Self {
        self.selectionMode = selectionMode
      return self
    }
    
    @discardableResult
    public func set(loadingView: UIView) -> Self {
        self.loadingView = loadingView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView) -> Self {
        self.errorStateView = errorView
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView) -> Self {
        self.emptyStateView = emptyView
        return self
    }
    
    @discardableResult
    public func set(onBack: @escaping (() -> Void)) -> Self {
        self.onBack = onBack
        return self
    }
    
}


public protocol StateManagement {
    func showLoadingView()
    func showErrorView()
    func showEmptyView()
    
    func removeLoadingView()
    func removeErrorView()
    func removeEmptyView()
}

extension StateManagement {
    public func showLoadingView() { }
    public func showErrorView() { }
    public func showEmptyView() { }
    
    public func removeLoadingView() { }
    public func removeErrorView() { }
    public func removeEmptyView() { }
}
