//
//  SceneDelegate.swift
//  CometChatAISampleApp
//
//  Copied from master-app; only the post-init routing target changes
//  (AI Agents home instead of the tabbed home / split view).
//

import UIKit
import FirebaseAuth
import CometChatUIKitSwift
import CometChatSDK

var userLoggedIn = false
func isUserLoggedIn() -> Bool{
    if let loggedInUser = CometChatUIKit.getLoggedInUser(),
       let currentUser = Auth.auth().currentUser,
       loggedInUser.uid != currentUser.uid {
        userLoggedIn = true  // User is logged in
    } else {
        userLoggedIn = false // User is not logged in
    }
    return userLoggedIn
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var currentScene: UIScene?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        currentScene = scene

        initialisationCometChatUIKit(completion: {
            if CometChat.getLoggedInUser() != nil {
                self.setRootViewController(UINavigationController(rootViewController: AIAgentsHomeViewController()))
            } else {

                if AppConstants.APP_ID.isEmpty || AppConstants.AUTH_KEY.isEmpty || AppConstants.REGION.isEmpty {
                    self.setRootViewController(ChangeAppCredentialsVC())
                } else {
                    self.setRootViewController(LoginWithUidVC())
                }
            }
        })
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }

    func setRootViewController(_ viewController: UIViewController){

      guard let scene = (currentScene as? UIWindowScene) else { return }

        UIView.animate(withDuration: 0.2) {  [weak self] in
            guard let self else { return }
            window = UIWindow(frame: scene.coordinateSpace.bounds)
            window?.tintColor = CometChatTheme.primaryColor
            window?.windowScene = scene

            //adding fade transition
            let transition = CATransition()
            transition.type = .fade
            transition.duration = 0.3 // Adjust the duration for smoother or faster transitions
            window?.layer.add(transition, forKey: kCATransition)

            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
        }

    }

    func initialisationCometChatUIKit(completion: @escaping () -> ()) {

        AppConstants.retrieveAppConstants()

        if AppConstants.APP_ID.isEmpty || AppConstants.AUTH_KEY.isEmpty || AppConstants.REGION.isEmpty {
            print("Incorrect App Constants")
            completion()
        } else {

            let uikitSettings = UIKitSettings()
            uikitSettings.set(appID: AppConstants.APP_ID)
                .set(authKey: AppConstants.AUTH_KEY)
                .set(region: AppConstants.REGION)
                .subscribePresenceForAllUsers()
                .enable(inAppIncomingCall: false)
                .build()

            CometChatUIKit.init(uiKitSettings: uikitSettings, result: { result in
                switch result {
                case .success(_):
                    CometChat.setSource(resource: "uikit-v5", platform: "ios", language: "swift")
                    completion()
                case .failure(let error):
                    print("Initialization Error: \(error.localizedDescription)")
                    completion()
                }
            })
        }
    }
}
