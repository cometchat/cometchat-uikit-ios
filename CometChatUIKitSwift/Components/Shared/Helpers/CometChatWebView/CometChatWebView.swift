//
//  CollaborativeViewViewController.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit
import CometChatSDK
import WebKit

enum WebViewType {
    case whiteboard
    case document
    case userProfile
    case none
}

class CometChatWebView: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    var url: String?
    var webViewType: WebViewType = .whiteboard
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize and configure the WKWebView
        webView = WKWebView().withoutAutoresizingMaskConstraints()
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.zoomScale = 5.0
        
        // Add webView as a subview and set up constraints
        view.backgroundColor = CometChatTheme.backgroundColor01
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        setupTitleAndLoadContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func setupTitleAndLoadContent() {
        // Set the title based on webViewType
        switch webViewType {
        case .whiteboard:
            self.title = "WHITEBOARD".localize()
        case .document:
            self.title = "DOCUMENT".localize()
        case .userProfile:
            if let name = user?.name {
                self.title = name
            }
        case .none:
            break
        }
        
        // Load content asynchronously
        DispatchQueue.global(qos: .background).async {
            var request: URLRequest?
            switch self.webViewType {
            case .whiteboard, .none:
                if let urlString = self.url, let link = URL(string: urlString) {
                    request = URLRequest(url: link)
                }
            case .document:
                if let urlString = self.url?.trimmingCharacters(in: .whitespacesAndNewlines), let link = URL(string: urlString) {
                    request = URLRequest(url: link)
                }
            case .userProfile:
                if let userLink = self.user?.link, let link = URL(string: userLink) {
                    request = URLRequest(url: link)
                }
            }
            
            // Load the request in the webView
            if let request = request {
                DispatchQueue.main.async {
                    self.webView.load(request)
                }
            }
        }
    }
    
    // MARK: - Configuration Methods
    
    @discardableResult
    @objc public func set(url: String) -> Self {
        self.url = url
        return self
    }
    
    @discardableResult
    public func set(webViewType: WebViewType) -> Self {
        self.webViewType = webViewType
        return self
    }
    
    @discardableResult
    @objc public func set(user: User) -> Self {
        self.user = user
        return self
    }
    
    @discardableResult
    @objc public func set(title: String) -> Self {
        self.title = title
        return self
    }
    
    public override func loadView() {
        self.view = UIView()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // Handle navigation failure
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // Handle provisional navigation failure
    }
    
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        // Handle when the navigation starts
    }
    
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        // Handle when the navigation finishes
    }
}
