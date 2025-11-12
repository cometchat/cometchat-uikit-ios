//
//  SplitScreenViewController.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 17/05/25.
//

import CometChatUIKitSwift

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    private lazy var homeScreenViewController: HomeScreenViewController = {
        let vc = HomeScreenViewController()
        vc.splitScreenCallBack = { [weak self] viewController in
            if let messagesVC = viewController as? MessagesVC {
                messagesVC.headerView.hideBackButton = true
            }
            DispatchQueue.main.async {
                self?.secondaryNavigationController.setViewControllers([viewController], animated: false)
            }
        }
        return vc
    }()
    
    private lazy var secondaryNavigationController: UINavigationController = {
        let nvc = UINavigationController(rootViewController: ConversationsWelcomeViewController())
        return nvc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.viewControllers = [homeScreenViewController, secondaryNavigationController]
        self.delegate = self
        self.preferredDisplayMode = .allVisible // .allVisible, .oneOverSecondary, etc.
    }
}

class ConversationsWelcomeViewController: UIViewController {

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        // Use a similar SF Symbol icon for chat bubbles
        let config = UIImage.SymbolConfiguration(pointSize: 60, weight: .regular)
        imageView.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: config)
        imageView.tintColor = CometChatTheme.textColorSecondary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to your Conversations"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = CometChatTheme.textColorPrimary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a chat from the list to start exploring your messages or begin a new conversation"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = CometChatTheme.textColorSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Background color - dark style similar to screenshot
        view.backgroundColor = CometChatTheme.backgroundColor01

        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Center icon horizontally and vertically with an offset upwards
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),

            // Title below icon with spacing
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            // Subtitle below title with spacing
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

