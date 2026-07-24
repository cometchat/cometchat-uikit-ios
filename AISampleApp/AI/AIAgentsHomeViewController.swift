//
//  AIAgentsHomeViewController.swift
//  CometChatAISampleApp
//
//  master-app's HomeScreenViewController.openAIAgents() promoted to the landing
//  screen, plus the avatar overflow menu (version / user / logout) from the same file.
//  Subclasses CometChatUsers so the component keeps full ownership of the
//  navigation bar, large title and search — exactly as when master-app pushes it.
//

import UIKit
import CometChatSDK
import CometChatUIKitSwift

class AIAgentsHomeViewController: CometChatUsers {

    init() {
        // Filter: ONLY AI agents (role == "@agentic"), limit 30 — exactly as master-app.
        let agenticUsersRequestBuilder = UsersRequest.UsersRequestBuilder()
            .set(limit: 30)
            .set(roles: ["@agentic"])
        super.init(usersRequestBuilder: agenticUsersRequestBuilder)

        title = "AI Assistants"

        // Configure navigation bar and search bar to match master-app's AI Agents screen.
        hideNavigationBar = false
        hideBackButton = true                  // this IS the home screen — nothing to go back to
        prefersLargeTitles = true
        searchController.hidesNavigationBarDuringPresentation = false

        set(onItemClick: { [weak self] user, _ in
            let chat = AIAgentChatViewController()
            chat.user = user
            self?.navigationController?.pushViewController(chat, animated: true)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatarMenu()
    }

    // MARK: - Avatar overflow menu (ported from HomeScreenViewController)

    private func setupAvatarMenu() {
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

        let avatarBarButtonItem = UIBarButtonItem(customView: customButton)

        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let menu = UIMenu(title: "\(appVersion ?? "v5.0.0")", children: [
            UIAction(title: "\(CometChat.getLoggedInUser()?.name ?? "")", image: UIImage(systemName: "person.circle"), handler: { _ in

            }),
            UIAction(title: "Logout", image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), attributes: .destructive, handler: { [weak self] _ in
                self?.logoutTapped()
            }),
        ])

        customButton.menu = menu
        customButton.showsMenuAsPrimaryAction = true

        avatarBarButtonItem.tintColor = CometChatTheme.primaryColor
        rightBarButtonItem = [avatarBarButtonItem]
    }

    // MARK: - Logout (ported from HomeScreenViewController)

    @objc private func logoutTapped() {
        if Reachability.isConnectedToNetwork() {
            performLogout()
        } else {
            // No internet connection
        }
    }

    private func performLogout() {
        CometChat.logout(onSuccess: { success in
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
}
