//
//  CometChatListBase.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

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

// MARK: - Declaration of Protocols

/**
 `CometChatListBaseDelegate` is an protocol  which provides the delegate methods for CometChatListBase.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
public protocol CometChatListBaseDelegate: NSObject {
    
    /**
     This method will tigger when any events happens with Seach bar in `CometChatListBase`
     - Parameters:
     - `SearchState`: Specifies an enum value where in this case seach bar will be empty or in active state
     - `text`:  Specifies an text which user has entered in the search bar.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    func onSearch(state: SearchState, text: String)
    
    /**
     This method will tigger when user presses an back button  in `CometChatListBase`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    func onBack()
}


/**
 `CometChatListBase` is a subclass of UIViewController which will be the base class for all list controllers. Other view controllers will inherit this class to use their methods & properties. .
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
open class CometChatListBase: UIViewController {
    
    private var search: UISearchController = UISearchController(searchResultsController: nil)
    private var titleColor: UIColor = .black
    private var largeTitleFont: UIFont = CometChatTheme.typography?.Heading ?? UIFont.systemFont(ofSize: 22, weight: .bold)
    private var titleFont: UIFont = CometChatTheme.typography?.Title2 ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
    private var backIcon = UIImage(named: "cometchatlistbase-back.png", in: CometChatUIKit.bundle, compatibleWith: nil)
    private var backButton: UIBarButtonItem?
    private var searchCancelButtonFont: UIFont?
    private var hideSearch: Bool = false
    private var backButtonTitle: String?
    private var backButtonFont: UIFont = CometChatTheme.typography?.Title2 ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
    private var backButtonColor: UIColor = CometChatTheme.palatte?.primary ?? .blue
   // static private var observer = [String: CometChatListBaseEvents]()
    weak var cometChatListBaseDelegate: CometChatListBaseDelegate?
    
    
    open override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
    }
    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatListBase`.
     - Parameters:
     - background: This method will set the background color for CometChatListBase, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatListBase`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult public func set(background: [Any]?) ->  CometChatListBase {
        if let backgroundColors = background as? [CGColor] {
            if backgroundColors.count == 1 {
                self.view.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                if let colors = background as? [CGColor] {
                    setGradientBackground(withColors: colors)
                }
            }
        }
        search.searchBar.layer.borderWidth = 1
        search.searchBar.layer.borderColor = UIColor.clear.cgColor
        return self
    }
    
    private func setGradientBackground(withColors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = withColors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    /**
     The back button is the `UIBarButtonItem` which the user can show if he wishes to in `CometChatListBase`.
     - Parameters:
     - backButton: This specifies an `boolean` which is being used for hide/show back button
     - Returns: This method will return `CometChatListBase`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult public func show(backButton: Bool) ->  CometChatListBase {
        if backButton == true {
            if backButtonTitle != nil {
                self.backButton = UIBarButtonItem(title: backButtonTitle, style: .plain, target: self, action: #selector(self.onBackButtonTriggered))
                self.backButton?.setTitleTextAttributes([NSAttributedString.Key.font: backButtonFont], for: .normal)
            }else{
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
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult public func set(backButtonTitle: String?) ->  CometChatListBase {
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
    @discardableResult public func set(backButtonTitleColor: UIColor) ->  CometChatListBase {
        self.backButtonColor = backButtonTitleColor
        return self
    }
    
    @discardableResult public func set(backButtonFont: UIFont?) ->  CometChatListBase {
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
    @discardableResult public func set(backButtonTint: UIColor) ->  CometChatListBase {
        self.backButton?.tintColor = backButtonTint
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
    @discardableResult public func set(backButtonIcon: UIImage) ->  CometChatListBase {
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
    @discardableResult @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode) ->  CometChatListBase {
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
    public func set(titleColor: UIColor) ->  CometChatListBase {
        self.titleColor = titleColor
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
    public func set(largeTitleFont: UIFont) ->  CometChatListBase {
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
    public func set(titleFont: UIFont) ->  CometChatListBase {
        self.titleFont = titleFont
        setupNavigationBar()
        return self
    }
    
    
    
    /**
     This method specifies the search  bar color  for `CometChatListBase`.
     - Parameters:
     - `searchBackground`: This takes the `UIColor` to set  title font for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @available(iOS 13.0, *)
    @discardableResult
    public func set(searchBackground: UIColor) -> CometChatListBase {
        self.search.searchBar.searchTextField.backgroundColor = searchBackground
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): CometChatTheme.palatte?.primary ?? UIColor.clear], for: .normal)
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
    public func set(searchCornerRadius: CGFloat) -> CometChatListBase {
        self.search.searchBar.searchTextField.layer.cornerRadius = searchCornerRadius
        self.search.searchBar.searchTextField.layer.masksToBounds = true
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
    public func set(searchPlaceholder: String) -> CometChatListBase {
        search.searchBar.placeholder =  searchPlaceholder
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
    public func set(searchPlaceholderColor: UIColor) -> CometChatListBase {
        search.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: search.searchBar.placeholder!, attributes: [NSAttributedString.Key.foregroundColor : searchPlaceholderColor])
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
    public func set(searchTextColor: UIColor) -> CometChatListBase {
        search.searchBar.searchTextField.textColor = searchTextColor
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
    public func set(searchTextFont: UIFont) -> CometChatListBase {
        search.searchBar.searchTextField.font = searchTextFont
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
    public func set(searchBorderWidth: CGFloat) -> CometChatListBase {
        if let searchTextfield = search.searchBar.value(forKey: "searchField") as? UITextField  {
            searchTextfield.layer.borderWidth = searchBorderWidth
        }
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
    public func set(searchBorderColor: UIColor) -> CometChatListBase {
        if let searchTextfield = search.searchBar.value(forKey: "searchField") as? UITextField  {
            searchTextfield.layer.borderColor = searchBorderColor.cgColor
        }
        return self
    }
    
    /**
     This method specifies the search  bar cancel button color  for `CometChatListBase`.
     - Parameters:
     - `searchCancelButtonColor`: This takes the `UIColor` to search  bar  cancel button color  for `CometChatListBase`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    
    @discardableResult
    public func set(searchCancelButtonFont: UIFont, searchCancelButtonColor: UIColor) -> CometChatListBase {
        
        let attributes:[NSAttributedString.Key: Any] = [
            .foregroundColor: searchCancelButtonColor,
            .font: searchCancelButtonFont
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
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
    public func hide(search: Bool) -> CometChatListBase {
        self.hideSearch = search
        setupSearch()
        return self
    }
    
    private func setupNavigationBar(){
        self.navigationController?.navigationBar.largeTitleTextAttributes =  [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font: largeTitleFont]
        
        self.navigationController?.navigationBar.titleTextAttributes =  [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font: titleFont]
    }
    
    private func setupSearch(){
        // SearchBar Apperance
        
        if hideSearch == false {
            search.searchBar.layer.borderWidth = 1
            search.searchBar.layer.borderColor = UIColor.clear.cgColor
            search.searchResultsUpdater = self
            search.obscuresBackgroundDuringPresentation = false
            definesPresentationContext = true
            search.searchBar.delegate = self
            if #available(iOS 13.0, *) {
                search.searchBar.barTintColor = .systemBackground
            } else {}
            if #available(iOS 11.0, *) {
                if navigationController != nil{
                    self.navigationItem.searchController = self.search
                }else{
                    if let textfield = search.searchBar.value(forKey: "searchField") as? UITextField {
                        if #available(iOS 13.0, *) {textfield.textColor = .label } else {}
                        if let backgroundview = textfield.subviews.first{
                            backgroundview.backgroundColor = .white
                            backgroundview.layer.cornerRadius = 10
                            backgroundview.clipsToBounds = true
                        }
                    }
                }} else {}
            set(searchTextColor: CometChatTheme.palatte?.accent600 ?? UIColor.gray)
            set(searchTextFont: CometChatTheme.typography?.Body ?? UIFont.systemFont(ofSize: 17, weight: .regular))
           
        }
    }
    
    
    
    private func searchIsEmpty() -> Bool {
        return search.searchBar.text?.isEmpty ?? true
    }
    
    private func isSearching() -> Bool {
        let searchBarScopeIsFiltering = search.searchBar.selectedScopeButtonIndex != 0
        return search.isActive && (!searchIsEmpty() || searchBarScopeIsFiltering)
    }
    
    @objc func onBackButtonTriggered() {
       cometChatListBaseDelegate?.onBack()
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
        if let text = searchController.searchBar.text {
            if text.isEmpty {
                cometChatListBaseDelegate?.onSearch(state: .clear, text: "")
            }else{
                cometChatListBaseDelegate?.onSearch(state: .filter, text: text)
            }
        }
    }
}
