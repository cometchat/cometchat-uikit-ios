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

class CollaborativeView: UIViewController , WKNavigationDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    
     var collaborativeURL: String?
     var collaborativeType: CollaborativeType = .whiteboard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        switch collaborativeType {
        case .whiteboard:
            self.set(title: "Whiteboard", mode: .never)
        case .writeboard:
            self.set(title: "Document", mode: .never)
        }
        if let url = collaborativeURL {
            let link = URL(string: url)!
            let request = URLRequest(url: link)
            webView.load(request)
        }
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        self.webView.scrollView.zoomScale = 5.0
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CollaborativeView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = NSLocalizedString(title, bundle: UIKitSettings.bundle, comment: "")
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
        
      
        let snackbar = CometChatSnackbar(message: error.localizedDescription, duration: .short)
        snackbar.show()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
     
        let snackbar = CometChatSnackbar(message: error.localizedDescription, duration: .short)
        snackbar.show()
    }
    
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func webView(_: WKWebView, didFinish _: WKNavigation!) {
        self.dismiss(animated: true, completion: nil)
    }
}
