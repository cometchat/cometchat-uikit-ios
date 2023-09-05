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
}

class CometChatWebView: CometChatListBase , WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
     var url: String?
     var webViewType: WebViewType = .whiteboard
     var user: User?
    
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch webViewType {
        case .whiteboard:
            self.set(title: "WHITEBOARD".localize(), mode: .never)
        case .document:
            self.set(title: "DOCUMENT".localize(), mode: .never)
        case .userProfile:
            if let name = user?.name {
                self.set(title: name, mode: .never)
            }
        }
        DispatchQueue.global(qos: .background).async {
            switch self.webViewType {
            case .whiteboard:
                if let url = self.url {
                    let link = URL(string: url)!
                    let request = URLRequest(url: link)
                    DispatchQueue.main.async {
                        self.webView.load(request)
                    }
                }
            case .document:
                if let url = self.url {
                    let link = URL(string: url)!
                    let request = URLRequest(url: link)
                    DispatchQueue.main.async {
                        self.webView.load(request)
                    }
                }
            case .userProfile:
                if let currentLink = self.user?.link {
                    let link = URL(string: currentLink)!
                    let request = URLRequest(url: link)
                    DispatchQueue.main.async {
                        self.webView.load(request)
                    }
                }
            }
        }
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.scrollView.zoomScale = 5.0
        show(backButton: true)
    }
    
    override func onSearch(state: SearchState, text: String) {
        
    }
    
    override func onBackCallback() {
        self.navigationController?.popViewController(animated: true)
    }
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view = contentView
        }
        self.navigationController?.navigationBar.tintColor = CometChatTheme.palatte.primary
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
       
     
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
     
     

    }
    
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {

    }
    
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
     
    }
    
    
}
