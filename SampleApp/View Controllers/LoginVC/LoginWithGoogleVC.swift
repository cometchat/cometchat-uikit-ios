//
//  LoginViewController.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 17/10/24.
//

import UIKit
import CometChatUIKitSwift
import FirebaseCore
import GoogleSignIn
import FirebaseAuth
import CometChatSDK
import CryptoKit

class LoginWithGoogleVC: UIViewController {
    
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cometchat_white")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = CometChatTheme.textColorPrimary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var cometchatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "CometChat"
        label.font = CometChatTypography.Heading1.bold
        label.textColor = CometChatTheme.textColorPrimary
        return label
    }()
    
    lazy var googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.addTarget(self, action: #selector(googleLogIn), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 300).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }()
    
    lazy var spinner = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.tintColor = CometChatTheme.primaryColor
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.topAnchor.constraint(equalTo: googleLoginButton.bottomAnchor, constant: 20),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func removeSpinner() {
        spinner.removeFromSuperview()
    }
    
    func buildUI() {
        self.view.backgroundColor = CometChatTheme.backgroundColor01
        
        //adding ComeChat text on the center of the screen
        view.addSubview(cometchatLabel)
        NSLayoutConstraint.activate([
            cometchatLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cometchatLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Add logo imageView
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.bottomAnchor.constraint(equalTo: cometchatLabel.topAnchor, constant: -10),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        // Add Google Login button
        view.addSubview(googleLoginButton)
        NSLayoutConstraint.activate([
            googleLoginButton.topAnchor.constraint(equalTo: cometchatLabel.bottomAnchor, constant: 20),
            googleLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func googleLogIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase Client ID not found.")
            return
        }

        // Create Google Sign-In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign-in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            if let error = error {
                print("Google Sign-In failed with error: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString,
                  let email = user.profile?.email else {
                print("Error retrieving user, ID token, or email.")
                return
            }            

            // Create credentials for Firebase authentication
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                self.addSpinner()
                if let error = error {
                    DispatchQueue.main.async {
                        self.removeSpinner()
                    }
                    print("Firebase sign-in failed: \(error.localizedDescription)")
                } else {
                    let uid = self.sha256(authResult?.user.email ?? "")
                    let newUser = User(uid: uid, name: authResult?.user.displayName ?? "")
                    self.loginOnCometChat(with: newUser)
                }
            }
        }
    }
    
    func loginOnCometChat(with user: CometChatSDK.User) {
        
        CometChatUIKit.login(uid: user.uid ?? "") { result in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.removeSpinner()
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        sceneDelegate.setRootViewController(SplitViewController())
                    } else {
                        sceneDelegate.setRootViewController(UINavigationController(rootViewController: HomeScreenViewController()))
                    }
                }
                break
            case .onError(let error):
                CometChat.createUser(user: user, authKey: AppConstants.AUTH_KEY) { user in
                    self.loginOnCometChat(with: user)
                } onError: { error in
                    //TODO: ADD ERROR VIEWE
                }
                break
            }
        }
    }
}

extension LoginWithGoogleVC{
    // Helper function to hash the email using SHA-256
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}
