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
    case writeboard
    case profile
}

class CometChatWebView: UIViewController , WKNavigationDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    
     var url: String?
     var webViewType: WebViewType = .whiteboard
     var user: CometChatPro.User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        switch webViewType {
        case .whiteboard:
            self.set(title: "WHITEBOARD".localized(), mode: .never)
        case .writeboard:
            self.set(title: "DOCUMENT".localized(), mode: .never)
        case .profile:
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
        case .writeboard:
            if let url = url {
                let link = URL(string: url)!
                let request = URLRequest(url: link)
                webView.load(request)
            }
        case .profile:
            if let currentLink = user?.link {
                let link = URL(string: currentLink)!
                let request = URLRequest(url: link)
                webView.load(request)
            }
        }
      
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.scrollView.zoomScale = 5.0

    }
    
    override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatWebView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
        self.navigationController?.navigationBar.tintColor = UIKitSettings.primaryColor
    }
    
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = title.localized()
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
    }

    private func setupNavigationBar(){
        if navigationController != nil{
            // NavigationBar Appearance
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
        }}
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        CometChatSnackBoard.display(message: error.localizedDescription, mode: .error, duration: .short)
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
     
      CometChatSnackBoard.display(message: error.localizedDescription , mode: .error, duration: .short)
//      self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
//        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        self.dismiss(animated: true, completion: nil)
    }
}
