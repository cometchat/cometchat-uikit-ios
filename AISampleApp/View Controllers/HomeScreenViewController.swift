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
import SystemConfiguration

class HomeScreenViewController: UIViewController {

    // Split screen callback (if needed)
    var splitScreenCallBack: ((_ viewController: UIViewController) -> Void)?

    // MARK: - CometChatUsers
    private lazy var usersVC: CometChatUsers = {
        let users = CometChatUsers()

        // Set custom request builder to fetch only agentic users
        let builder = UsersRequest.UsersRequestBuilder()
            .set(roles: ["@agentic"])
        users.set(userRequestBuilder: builder)

        // Handle user tap
        users.set(onItemClick: { [weak self] user, indexPath in
            let messagesVC = MessagesVC()
            messagesVC.user = user

            if let splitScreenCallBack = self?.splitScreenCallBack {
                splitScreenCallBack(messagesVC)
            } else {
                self?.navigationController?.pushViewController(messagesVC, animated: true)
            }
        })

        return users
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUsersVC()
    }

    // MARK: - Setup Users VC
    private func setupUsersVC() {
        addChild(usersVC)
        view.addSubview(usersVC.view)
        usersVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            usersVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            usersVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            usersVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            usersVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        usersVC.didMove(toParent: self)
    }

    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        navigationItem.title = "Agents" // Or use localization
        navigationController?.navigationBar.prefersLargeTitles = true

        // Avatar Button
        let avatarButton = UIButton(type: .custom)
        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        avatarButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        avatarButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        avatarButton.layer.cornerRadius = 16
        avatarButton.clipsToBounds = true

        if let urlString = CometChat.getLoggedInUser()?.avatar, let url = URL(string: urlString) {
            UIImageView.downloaded(from: url) { image in
                if let image = image {
                    avatarButton.setImage(image, for: .normal)
                    avatarButton.imageView?.contentMode = .scaleAspectFill
                } else {
                    let fallback = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
                    avatarButton.setImage(AvatarUtils.setImageSnap(
                        text: CometChat.getLoggedInUser()?.name ?? "",
                        color: CometChatTheme.primaryColor,
                        textAttributes: [.font: CometChatTypography.Caption1.medium, .foregroundColor: CometChatTheme.white],
                        view: fallback
                    ), for: .normal)
                }
            }
        }

        // Menu (Create Conversation + Logout)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "v5.0.0"
        let menu = UIMenu(title: appVersion, children: [
            UIAction(title: "\(CometChat.getLoggedInUser()?.name ?? "")", image: UIImage(systemName: "person.circle"), handler: { _ in

            }),
            UIAction(title: "LOGOUT".localize(), image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), attributes: .destructive, handler: { [weak self] _ in
                self?.logoutTapped()
            })
        ])
        if #available(iOS 14.0, *) {
            avatarButton.menu = menu
            avatarButton.showsMenuAsPrimaryAction = true
        }

        let avatarBarButton = UIBarButtonItem(customView: avatarButton)
        navigationItem.rightBarButtonItem = avatarBarButton
    }

    // MARK: - Logout
    private func logoutTapped() {
        guard Reachability.isConnectedToNetwork() else {
            print("Internet not connected")
            return
        }

        CometChatNotifications.unregisterPushToken { _ in } onError: { error in
            print(error.errorDescription ?? "")
        }

        CometChat.logout { [weak self] _ in
            UserDefaults.standard.removeObject(forKey: "appID")
            UserDefaults.standard.removeObject(forKey: "region")
            UserDefaults.standard.removeObject(forKey: "authKey")
            AppConstants.APP_ID = ""
            AppConstants.AUTH_KEY = ""
            AppConstants.REGION = ""

            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
            sceneDelegate.setRootViewController(UINavigationController(rootViewController: LoginWithUidVC()))
        } onError: { error in
            print("Logout failed: \(error.errorDescription ?? "")")
        }
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
