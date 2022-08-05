//
//  CollaborativeViewViewController.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro
import WebKit

enum WebViewType {
    case whiteboard
    case document
    case userProfile
}

class CometChatWebView: CometChatListBase , WKNavigationDelegate, CometChatListBaseDelegate {
    

    
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
        
        switch webViewType {
        case .whiteboard:
            if let url = url {
                let link = URL(string: url)!
                let request = URLRequest(url: link)
                webView.load(request)
            }
        case .document:
            if let url = url {
                let link = URL(string: url)!
                let request = URLRequest(url: link)
                webView.load(request)
            }
        case .userProfile:
            if let currentLink = user?.link {
                let link = URL(string: currentLink)!
                let request = URLRequest(url: link)
                webView.load(request)
            }
        }
      
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.scrollView.zoomScale = 5.0
        
        show(backButton: true)
        self.cometChatListBaseDelegate = self
    }
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view = contentView
        }
        self.navigationController?.navigationBar.tintColor = CometChatTheme.palatte?.primary
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
       
     
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
     
     

    }
    
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {

    }
    
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
     
    }
    
    func onSearch(state: SearchState, text: String) {
        
    }
    
    func onBack() {
        self.navigationController?.popViewController(animated: true)
    }
}
