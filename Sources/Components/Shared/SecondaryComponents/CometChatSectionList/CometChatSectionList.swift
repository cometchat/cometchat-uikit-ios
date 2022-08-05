//
//  CometChatConversations.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro


public protocol CometChatSectionListDelegate  {
    
    func onItemClick(actionItem: ActionItem)
}

 public struct SectionData {
    var title: String?
    var actionItems: [ActionItem]?
    var sectionSeperator: Bool?
    var itemSeparator: Bool?
    var titleFont: UIFont?
    var titleColor: UIColor?
    var sectionSeparatorColor: UIColor?
    var itemSeparatorColor: UIColor?
    var user: User?
     var group: Group?
     
    init() {}
     
     init(title: String, actionItems: [ActionItem]?) {
         self.title = title
         self.actionItems = actionItems
     }
     
     
     init(title: String, user: User?) {
         self.title = title
         self.user = user
     }
     
     init(title: String, group: Group?) {
         self.title = title
         self.group = group
     }
     
     init(title: String, actionItems: [ActionItem]?, sectionSeparator: Bool, itemSeparator: Bool) {
         self.title = title
         self.actionItems = actionItems
         self.itemSeparator = itemSeparator
         self.sectionSeperator = sectionSeparator
     }
     
     init(title: String, actionItems: [ActionItem]?, sectionSeparator: Bool, itemSeparator: Bool, titleFont: UIFont, titleColor: UIColor, sectionSeparatorColor: UIColor, itemSeparatorColor: UIColor) {
         self.title = title
         self.actionItems = actionItems
         self.itemSeparator = itemSeparator
         self.sectionSeperator = sectionSeparator
         self.itemSeparatorColor = itemSeparatorColor
         self.titleFont = titleFont
         self.titleColor = titleColor
         self.sectionSeparatorColor = sectionSeparatorColor
     }
     
     
 }
     

/**
 `CometChatSectionList` is a subclass of `UIView` which internally uses a 0 and reusable cell i.e `CometChatSectionListItem` which forms a list of recent conversations as per the data coming from the server.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
@IBDesignable public final class CometChatSectionList: UIView , NibLoadable {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var tableView: UITableView!
    
    
    public static var sectionListDelegate: CometChatSectionListDelegate?
    
    //MARK: - Declaration of Variables
    var safeArea: UILayoutGuide!
    var activityIndicator:UIActivityIndicatorView?
    var sectionTitle : UILabel?
    var sections = [String]()
    var controller: UIViewController?
    var isSearching: Bool = false
    var sectionData: [SectionData]?
    var headerBackground: UIColor?
    var headerTextColor: UIColor?
    var headerTextFont: UIFont?
    var hideSectionHeader: Bool? = false
    var configurations: [CometChatConfiguration]?
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatSectionList {
        self.configurations = configurations
        return self
    }
    
    @discardableResult
    public func set(sectionData: [SectionData]?) -> CometChatSectionList {
        self.sectionData = sectionData
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        return self
    }


    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatSectionList`.
     - Parameters:
     - background: This method will set the background color for CometChatSectionList, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatSectionList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatSectionList {
        if let backgroundColors = background as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: background)
            }
        }
        return self
    }
    
    /**
     This method will set the instance of the view controller from which the `CometChatSectionList` is presented. This method is mandatory to call when the conversation list is presented.
     - Parameters:
     - controller: This method will set the instance of the view controller from which the `CometChatSectionList` is presented. This method is mandatory to call when the conversation list is presented.
     - Returns: This method will return `CometChatSectionList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatSectionList {
        self.controller = controller
        return self
    }
    
    @discardableResult
    @objc public func set(sectionHeaderTextFont: UIFont) -> CometChatSectionList {
        self.headerTextFont = sectionHeaderTextFont
        return self
    }
    
    @discardableResult
    @objc public func set(sectionHeaderTextColor: UIColor) -> CometChatSectionList {
        self.headerTextColor = sectionHeaderTextColor
        return self
    }
    
    @discardableResult
    @objc public func set(sectionHeaderBackground: UIColor) -> CometChatSectionList {
        self.headerBackground = sectionHeaderBackground
        return self
    }
    
   
    @discardableResult
    public func hide(sectionHeader: Bool) -> CometChatSectionList {
        self.hideSectionHeader = sectionHeader
        return self
    }
    

    @discardableResult
    public func set(style: Style) -> CometChatSectionList {
        self.set(background: [style.background?.cgColor ?? UIColor.systemBackground.cgColor])
        return self
    }
    
    
    // MARK: - Instance Methods
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    private func commonInit() {
        print(" CometChatSectionList configurations: \(configurations)")
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
        setuptTableView()
        registerCells()
        configureDetailList()
    }
    
    
    
    
   private func configureDetailList() {
       if let configurations = configurations {
           let currentConfigurations = configurations.filter{ $0 is UserListConfiguration }
           if let configuration = currentConfigurations.last as? UserListConfiguration {
              
           }
       }
    }
    
 
    
    fileprivate func setuptTableView() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
        
    }
    
    
    fileprivate func registerCells() {
        self.registerCellWith(title: "CometChatDataItem")
        self.registerCellWith(title: "CometChatActionItem")
    }
    
    private func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
    
}


extension CometChatSectionList: UITableViewDelegate, UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of Conversations.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData?.count ?? 0
    }
    
    /// This method specifies height for section in CometChatSectionList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            if hideSectionHeader == false {
                return 25
            }else{
                return 0
            }
        }
    }
    
    /// This method specifiesnumber of rows in CometChatSectionList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if (sectionData?[section].user) != nil || (sectionData?[section].group) != nil  {
                return 1
            }else{
                return 0
            }
        } else {
            return sectionData?[section].actionItems?.count ?? 0
        }
        
    }
    
    
    /// This method specifies the height for row in CometChatSectionList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for user  in CometChatSectionList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        print("sectionData?[indexPath.section].user: \(sectionData?[indexPath.section].user)")
        if let user = sectionData?[indexPath.section].user {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cell.set(user: user)
                return cell
            }
        }
        
        if let group = sectionData?[indexPath.section].group {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatDataItem", for: indexPath) as? CometChatDataItem {
                cell.set(group: group)
                return cell
            }
        }
        
        if let actionItem = sectionData?[indexPath.section].actionItems?[indexPath.row] {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionItem", for: indexPath) as? CometChatActionItem {
                cell.set(actionItem: actionItem)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    
    
    /// This method triggers when particulatr cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        if let cell = tableView.cellForRow(at: indexPath) as? CometChatActionItem, let actionItem = cell.actionItem {
            CometChatSectionList.sectionListDelegate?.onItemClick(actionItem: actionItem)
        }
      
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: contentView.frame.size.width - 20, height: 25))
        sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: returnedView.frame.size.width, height: 25))
        sectionTitle?.text = sectionData?[section].title
        if #available(iOS 13.0, *) {
            sectionTitle?.textColor = headerTextColor
            sectionTitle?.font = headerTextFont
            returnedView.backgroundColor = headerBackground
        } else {}
        returnedView.addSubview(sectionTitle!)
        return returnedView
    }
    
}

/*  ----------------------------------------------------------------------------------------- */

