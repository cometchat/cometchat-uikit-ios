//
//  StartNewConversationVC.swift
//  Sample App v5
//
//  Created by Dawinder on 29/11/24.
//

import Foundation
import UIKit
import CometChatUIKitSwift
import CometChatSDK

open class CreateConversationVC: UIViewController {

    // MARK: - UI Elements
    public let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Users", "Groups"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        control.backgroundColor = CometChatTheme.backgroundColor02
        control.selectedSegmentTintColor = CometChatTheme.backgroundColor01
        control.setTitleTextAttributes([.foregroundColor: CometChatTheme.textColorPrimary, .font: CometChatTypography.Body.regular], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: CometChatTheme.textColorPrimary, .font: CometChatTypography.Body.medium], for: .selected)
        return control
    }()

    public lazy var pageViewController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()

    public lazy var usersViewController: CometChatUsers = {
        let vc = CometChatUsers()
        vc.setOnItemClick(onItemClick: { [weak self] users, indexPath in
            let messages = MessagesVC()
            messages.user = users
            self?.navigationController?.pushViewController(messages, animated: true)
        })
        return vc
    }()

    public lazy var groupsViewController: CometChatGroups = {
        let vc = CometChatGroups()
        vc.setOnItemClick(onItemClick: { [weak self] group, indexPath in
            let messages = MessagesVC()
            messages.group = group
            self?.navigationController?.pushViewController(messages, animated: true)
        })
        return vc
    }()

    public lazy var pages: [UIViewController] = [usersViewController, groupsViewController]

    // MARK: - Lifecycle Methods
    override public func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        setupPageViewController()

        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        self.navigationItem.searchController = usersViewController.searchController

    }

    // MARK: - Setup UI
    public func buildUI() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "New Chat"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = CometChatTheme.backgroundColor01
        view.addSubview(segmentedControl)
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        setupConstraints()
    }

    public func setupConstraints() {
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p2),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p2),
            segmentedControl.heightAnchor.constraint(equalToConstant: 28),

            // Page View Controller
            pageViewController.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: CometChatSpacing.Padding.p3),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    public func setupPageViewController() {
        pageViewController.setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }

    // MARK: - Actions
    @objc public func segmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        let direction: UIPageViewController.NavigationDirection = index == 0 ? .reverse : .forward
        if index == 0{
            self.navigationItem.searchController = usersViewController.searchController
        }else{
            self.navigationItem.searchController = groupsViewController.searchController
        }
        pageViewController.setViewControllers([pages[index]], direction: direction, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource
extension CreateConversationVC: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

// MARK: - UIPageViewControllerDelegate
extension CreateConversationVC: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: visibleViewController) {
            segmentedControl.selectedSegmentIndex = index
            groupsViewController.showSearch = false
            groupsViewController.navigationItem.searchController = nil
        }
    }
}
