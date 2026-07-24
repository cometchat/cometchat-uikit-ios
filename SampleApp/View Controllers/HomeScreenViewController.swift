//
//  HomeScreen.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 17/10/24.
//

import UIKit
import AVFoundation
import CometChatUIKitSwift
import CometChatSDK
import FirebaseAuth
import SystemConfiguration

class HomeScreenViewController: UITabBarController {
    
    lazy var conversations: CometChatConversations = {
        let conversations = CometChatConversations()
        conversations.hideSearch = false
        conversations.set(onItemClick: { [weak self] conversation, indexPath in
            let messages = MessagesVC()
            messages.group = (conversation.conversationWith as? Group)
            messages.user = (conversation.conversationWith as? CometChatSDK.User)
            
            if let splitScreenCallBack = self?.splitScreenCallBack {
                splitScreenCallBack(messages)
            } else {
                self?.navigationController?.pushViewController(messages, animated: true)
            }
        })
        
        conversations.onSearchClick = {
            let searchVC = CometChatSearch()
            searchVC.hidesBottomBarWhenPushed = true
            
            searchVC.onConversationClicked = { [weak self] conversation, indexPath in
                    let messages = MessagesVC()
                    messages.group = (conversation.conversationWith as? Group)
                    messages.user = (conversation.conversationWith as? CometChatSDK.User)
                    
                    if let splitScreenCallBack = self?.splitScreenCallBack {
                        splitScreenCallBack(messages)
                    } else {
                        self?.navigationController?.pushViewController(messages, animated: true)
                    }
            }
            searchVC.onMessageClicked = { [weak self] message in
                let loggedInUID = CometChat.getLoggedInUser()?.uid
                if message.parentMessageId > 0{
                    CometChat.getMessageDetails(message.parentMessageId) { parentMessage in
                        let threadedView = ThreadedMessagesVC()
                        threadedView.parentMessage = parentMessage
                        threadedView.parentMessageView.controller = self
                        threadedView.targetMessageId = message.id
                        threadedView.parentMessageView.set(parentMessage: parentMessage)
                        self?.navigationController?.pushViewController(threadedView, animated: true)
                    } onError: { error in
                    }
                } else {
                    let messagesVC = MessagesVC() // or your custom MessageViewController
                    
                    if message.receiverType == .user {
                        if loggedInUID == message.sender?.uid {
                            messagesVC.user = message.receiver as? CometChatSDK.User
                        } else {
                            messagesVC.user = message.sender
                        }
                    } else if message.receiverType == .group {
                        messagesVC.group = message.receiver as? Group
                    }
                    messagesVC.targetMessageId = message.id

                    self?.navigationController?.pushViewController(messagesVC, animated: true)
                }
            }
            self.navigationController?.pushViewController(searchVC, animated: false)
        }
        return conversations
    }()
    
    #if canImport(CometChatCallsSDK)
    lazy var calls: CometChatCallLogs = {
        let calls = CometChatCallLogs()
        calls.set(goToCallLogDetail: { [weak self] callLog, user, group in
            if let callLog = callLog as? CometChatCallsSDK.CallLog {
                let callDetails = CallLogDetailsVC()
                callDetails.currentUser = user
                callDetails.currentGroup = group
                callDetails.callLog = callLog
                callDetails.dateTimeFormatter = calls.dateTimeFormatter
                if let splitScreenCallBack = self?.splitScreenCallBack {
                    splitScreenCallBack(callDetails)
                } else {
                    self?.navigationController?.pushViewController(callDetails, animated: true)
                }
            }
        })
        return calls
    }()
    #endif
    
    lazy var users: CometChatUsers = {
        let users = CometChatUsers()
        users.hideSearch = false
        users.set(onItemClick: { [weak self] users, indexPath in
            let messages = MessagesVC()
            messages.user = users
            if let splitScreenCallBack = self?.splitScreenCallBack {
                splitScreenCallBack(messages)
            } else {
                self?.navigationController?.pushViewController(messages, animated: true)
            }
        })
        return users
    }()
        
    lazy var groups: CometChatGroups = {
                
        let groups = CometChatGroups()
        groups.hideSearch = false
        
        if #available(iOS 26, *) {
            // iOS 26 fix: Use custom button to prevent inverted colors
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "groups-create")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = CometChatTheme.primaryColor
            button.addTarget(self, action: #selector(tapCreate), for: .touchUpInside)
            groups.rightBarButtonItem = [UIBarButtonItem(customView: button)]
        } else {
            groups.rightBarButtonItem = [
                UIBarButtonItem(
                    image: UIImage(named: "groups-create"),
                    style: .done,
                    target: self,
                    action: #selector(tapCreate)
                )
            ]
        }
        groups.joinPasswordProtectedGroup = { [weak self] group in
            let joinGroupVC = JoinPasswordProtectedGroupVC()
            joinGroupVC.group = group
            joinGroupVC.onGroupJoined = { [weak joinGroupVC] group in
                joinGroupVC?.dismiss(animated: true)
                let messages = MessagesVC()
                messages.group = group
                self?.navigationController?.pushViewController(messages, animated: true)
            }
            if let self = self {
                presentViewControllerBottomSheet(from: self, to: joinGroupVC, height: 378)
            }
        }
        groups.set(onItemClick: { [weak self] group, indexPath in
            let messages = MessagesVC()
            messages.group = group
            if let splitScreenCallBack = self?.splitScreenCallBack {
                splitScreenCallBack(messages)
            } else {
                self?.navigationController?.pushViewController(messages, animated: true)
            }
        })


        return groups
    }()
    
    lazy var lastSelectedIndex = 0
    var splitScreenCallBack: ((_ viewController: UIViewController) -> Void)?
    var loggedInUserAvatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = CometChatTheme.backgroundColor01.withAlphaComponent(0.5)
        self.tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            self.tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        
        super.viewWillAppear(animated)
        
        buildAvatarBarButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if lastSelectedIndex == self.selectedIndex {
            #if canImport(CometChatCallsSDK)
            switch self.selectedIndex {
            case 0:
                if let table = conversations.tableView, table.numberOfSections > 0{
                    if table.numberOfRows(inSection: 0) > 0{
                        table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                }
            case 1:
                if let table = calls.tableView, table.numberOfSections > 0{
                    if table.numberOfRows(inSection: 0) > 0{
                        table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                }
            case 2:
                if let table = users.tableView, table.numberOfSections > 0{
                    if table.numberOfRows(inSection: 0) > 0{
                        table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                }
            case 3:
                if let table = groups.tableView, table.numberOfSections > 0{
                    if table.numberOfRows(inSection: 0) > 0{
                        table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                }
            default:
                break
            }
            #else
            switch self.selectedIndex {
            case 0:
                if conversations.tableView.numberOfRows(inSection: 0) > 0{
                    conversations.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            case 1:
                if users.tableView.numberOfRows(inSection: 0) > 0{
                    users.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            case 2:
                if groups.tableView.numberOfRows(inSection: 0) > 0{
                    groups.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            default:
                break
            }
            #endif
        } else {
            lastSelectedIndex = self.selectedIndex
        }
    }
    
    func buildAvatarBarButtonItem() {
        
        let customButton = UIButton(type: .custom)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customButton.widthAnchor.constraint(equalToConstant: 30),
            customButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let avatarURLString = CometChat.getLoggedInUser()?.avatar ?? ""
        
        // Renders any image into a 30x30 circle with aspect-fill and transparent background
        let makeCircularImage: (UIImage) -> UIImage = { image in
            let size = CGSize(width: 30, height: 30)
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { _ in
                let rect = CGRect(origin: .zero, size: size)
                UIBezierPath(ovalIn: rect).addClip()
                // Aspect-fill: scale to fill the square, crop overflow
                let imageSize = image.size
                let scale = max(size.width / imageSize.width, size.height / imageSize.height)
                let drawWidth = imageSize.width * scale
                let drawHeight = imageSize.height * scale
                let drawRect = CGRect(
                    x: (size.width - drawWidth) / 2,
                    y: (size.height - drawHeight) / 2,
                    width: drawWidth,
                    height: drawHeight
                )
                image.draw(in: drawRect)
            }
        }
        
        // Helper to generate initials placeholder
        let makePlaceholder: () -> UIImage? = {
            let placeholderView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            return AvatarUtils.setImageSnap(
                text: CometChat.getLoggedInUser()?.name ?? "",
                color: CometChatTheme.primaryColor,
                textAttributes: [
                    .font: CometChatTypography.Caption1.medium,
                    .foregroundColor: CometChatTheme.white
                ],
                view: placeholderView
            )
        }
        
        // Set placeholder
        if let placeholder = makePlaceholder() {
            customButton.setImage(makeCircularImage(placeholder), for: .normal)
        }
        customButton.imageView?.contentMode = .scaleAspectFit
        
        if let imageURL = URL(string: avatarURLString), !avatarURLString.isEmpty {
            URLSession.shared.dataTask(with: imageURL) { data, response, error in
                if let data = data, error == nil, let downloadedImage = UIImage(data: data) {
                    let circularImage = makeCircularImage(downloadedImage)
                    DispatchQueue.main.async {
                        customButton.setImage(circularImage, for: .normal)
                        customButton.imageView?.contentMode = .scaleAspectFit
                    }
                }
            }.resume()
        }
        
        let logoutBarButtonItem = UIBarButtonItem(customView: customButton)
    
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let menu = UIMenu(title: "\(appVersion ?? "v5.0.0")", children: [
            UIAction(title: "CREATE_CONVERSATION".localize(), image: UIImage(systemName: "plus.bubble"), handler: { _ in
                let startNewConversationNVC = CreateConversationVC()
                startNewConversationNVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(startNewConversationNVC, animated: true)
            }),
            UIAction(title: "\(CometChat.getLoggedInUser()?.name ?? "")", image: UIImage(systemName: "person.circle"), handler: { _ in

            }),
            UIAction(title: "LOGOUT".localize(), image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), attributes: .destructive, handler: { _ in
                self.logoutTapped()
            }),
        ])

        
        if #available(iOS 14.0, *) {
            customButton.menu = menu
            customButton.showsMenuAsPrimaryAction = true
        }
        
        logoutBarButtonItem.tintColor = CometChatTheme.primaryColor

        #if DEBUG
        // The avatar's `showsMenuAsPrimaryAction` pull-down isn't openable by XCUITest, so under
        // -UITestMode expose a plain bar button that invokes the same logout path (Apple Forums 690882).
        if ProcessInfo.processInfo.arguments.contains("-UITestMode") {
            let uiTestLogout = UIBarButtonItem(title: "uiTestLogout", style: .plain, target: self, action: #selector(logoutTapped))
            uiTestLogout.accessibilityIdentifier = "uiTestLogout"
            conversations.rightBarButtonItem = [logoutBarButtonItem, uiTestLogout]
            return
        }
        #endif

        conversations.rightBarButtonItem = [logoutBarButtonItem]
    }
    
    //Logging out
    @objc func logoutTapped() {
        if Reachability.isConnectedToNetwork(){
            performLogout()
        }else{
            // No internet connection
        }
    }
    
    private func performLogout() {
        CometChat.logout(onSuccess: { success in
            // Clear badge count
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
            
            UserDefaults.standard.removeObject(forKey: "appID")
            UserDefaults.standard.removeObject(forKey: "region")
            UserDefaults.standard.removeObject(forKey: "authKey")
            AppConstants.APP_ID = ""
            AppConstants.AUTH_KEY = ""
            AppConstants.REGION = ""
            
            //Changing root window
            DispatchQueue.main.async {
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
                sceneDelegate.setRootViewController(UINavigationController(rootViewController: LoginWithUidVC()))
            }
        }, onError: { error in
        })
    }
    
    @objc func tapCreate(){
        let vc = CreateGroupVC()
        vc.openGroupChat = { [weak self] group in
            let messages = MessagesVC()
            messages.group = group
            self?.navigationController?.pushViewController(messages, animated: true)
        }
        presentViewControllerBottomSheet(from: self, to: vc, height: 356)
    }
    
    
    lazy var notifications: CometChatNotificationFeed = {
        let feed = CometChatNotificationFeed()
        feed.set(showBackButton: false)
        feed.set(onItemClick: { [weak self] feedItem in
        })
        feed.set(onActionClick: { [weak self] feedItem, actionEvent in
            guard let self = self else { return }
            
            // Report engagement on any button click
            CometChat.reportFeedEngagement(feedItem, interactionString: "button_clicked", onSuccess: {
            }, onError: { error in
            })
            
            // Show toast with action details
            switch actionEvent.action {
            case .openUrl(let url, let label):
                let toastMessage = "Action: openUrl\nLabel: \(label ?? "N/A")\nURL: \(url)"
                self.showToast(message: toastMessage)
                
                if let linkURL = URL(string: url) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        UIApplication.shared.open(linkURL)
                    }
                }
            default:
                let toastMessage = "Action: \(actionEvent.action)"
                self.showToast(message: toastMessage)
            }
        })
        return feed
    }()
    
    private func showToast(message: String) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.textColor = .white
        toastLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        toastLabel.textAlignment = .left
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        let padding: CGFloat = 16
        let maxWidth = window.frame.width - 40
        let size = toastLabel.sizeThatFits(CGSize(width: maxWidth - (padding * 2), height: .greatestFiniteMagnitude))
        toastLabel.frame = CGRect(
            x: 20,
            y: window.frame.height - size.height - (padding * 2) - 100,
            width: maxWidth,
            height: size.height + (padding * 2)
        )
        
        // Add padding via text insets (using a wrapper)
        let containerView = UIView(frame: toastLabel.frame)
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        toastLabel.frame = CGRect(x: padding, y: padding, width: size.width, height: size.height)
        toastLabel.backgroundColor = .clear
        containerView.addSubview(toastLabel)
        containerView.frame.size = CGSize(width: maxWidth, height: size.height + (padding * 2))
        containerView.center.x = window.center.x
        containerView.frame.origin.y = window.frame.height - containerView.frame.height - 100
        containerView.alpha = 0
        
        window.addSubview(containerView)
        
        UIView.animate(withDuration: 0.3, animations: {
            containerView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseOut, animations: {
                containerView.alpha = 0.0
            }) { _ in
                containerView.removeFromSuperview()
            }
        }
    }
    
    func setupTabs() {
        conversations.tabBarItem = UITabBarItem(title: "CHATS".localize(), image: UIImage(systemName: "message"), tag: 0)
        conversations.tabBarItem.selectedImage = UIImage(systemName: "message.fill")
        
        #if canImport(CometChatCallsSDK) //if CometChatCalls SDK is not included
        calls.tabBarItem = UITabBarItem(title: "CALLS".localize(), image: UIImage(systemName: "phone"), tag: 0)
        calls.tabBarItem.selectedImage = UIImage(systemName: "phone.fill")
        #endif

        users.tabBarItem = UITabBarItem(title: "USERS".localize(), image: UIImage(systemName: "person"), tag: 1)
        users.tabBarItem.selectedImage = UIImage(systemName: "person.fill")

        groups.tabBarItem = UITabBarItem(title: "GROUPS".localize(), image: UIImage(systemName: "person.2"), tag: 1)
        groups.tabBarItem.selectedImage = UIImage(systemName: "person.2.fill")
        
        notifications.tabBarItem = UITabBarItem(title: "Notifications", image: UIImage(systemName: "bell"), tag: 4)
        notifications.tabBarItem.selectedImage = UIImage(systemName: "bell.fill")
        
        
        #if canImport(CometChatCallsSDK)
        viewControllers = [
            UINavigationController(rootViewController: conversations),
            UINavigationController(rootViewController: calls),
            UINavigationController(rootViewController: users),
            UINavigationController(rootViewController: groups),
            UINavigationController(rootViewController: notifications),
        ]
        #else
        viewControllers = [
            UINavigationController(rootViewController: conversations),
            UINavigationController(rootViewController: users),
            UINavigationController(rootViewController: groups),
            UINavigationController(rootViewController: notifications),
        ]
        #endif
        
        tabBar.tintColor = CometChatTheme.primaryColor
        tabBar.isTranslucent = true
    }
}

extension UIViewController {
    func presentViewControllerBottomSheet(from presentingVC: UIViewController, to viewControllerToPresent: UIViewController, height: Int) {
        if #available(iOS 15.0, *) {
            if let sheet = viewControllerToPresent.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return CGFloat(height)
                    }
                    sheet.detents = [customDetent]
                }
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            viewControllerToPresent.modalPresentationStyle = .pageSheet
        } else {
            viewControllerToPresent.modalPresentationStyle = .pageSheet
        }

        presentingVC.present(viewControllerToPresent, animated: true, completion: nil)
    }
}

public class Reachability {

    class func isConnectedToNetwork() -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}
