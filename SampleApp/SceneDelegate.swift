//
//  SceneDelegate.swift
//  Sample App v5
//
//  Created by Suryansh on 17/10/24.
//

import UIKit
import CometChatUIKitSwift
import CometChatSDK
import CometChatCardsSwift

var userLoggedIn = false
func isUserLoggedIn() -> Bool{
    if CometChatUIKit.getLoggedInUser() != nil {

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
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        currentScene = scene
        #if DEBUG
        injectTestCredentialsIfNeeded()
        #endif
        routeAfterInit()
    }

    private func routeAfterInit() {
        initialisationCometChatUIKit(completion: {
            #if DEBUG
            if self.shouldForceLoggedOutForUITest {
                self.setRootViewController(UINavigationController(rootViewController: LoginWithUidVC()))
                return
            }
            #endif
            if CometChat.getLoggedInUser() != nil {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.setRootViewController(SplitViewController())
                } else {
                    self.setRootViewController(UINavigationController(rootViewController: HomeScreenViewController()))
                }
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
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("Badge count cleared")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
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
                .setExtensionGroupID(id: "group.com.cometchat.internal.swift.notification")
                .subscribePresenceForAllUsers()
//                .overrideAdminHost("\(AppConstants.APP_ID).api-\(AppConstants.REGION).cometchat-staging.com")
//                .overrideClientHost("\(AppConstants.APP_ID).apiclient-\(AppConstants.REGION).cometchat-staging.com")
                .enable(inAppIncomingCall: false)
                .build()
            
            CometChatUIKit.init(uiKitSettings: uikitSettings, result: { result in
                switch result {
                case .success(_):
                    CometChat.setSource(resource: "uikit-v5", platform: "ios", language: "swift")
                    // Register card action listener for debugging
                    CometChatCardEvents.addListener("sample-app-card-listener", CardActionHandler.shared)
                    #if DEBUG
                    self.loginTestUserIfNeeded(completion: completion)
                    #else
                    completion()
                    #endif
                case .failure(let error):
                    print("Initialization Error: \(error.localizedDescription)")
                    completion()
                }
            })
        }
    }
}

#if DEBUG

extension SceneDelegate {

    /// When set, UI tests want a logged-out start: route to Login regardless of any persisted
    /// session, without uninstalling (used by `launchToLogin`).
    var shouldForceLoggedOutForUITest: Bool {
        ProcessInfo.processInfo.arguments.contains("-UITestStartLoggedOut")
    }

    private func injectTestCredentialsIfNeeded() {
        let args = ProcessInfo.processInfo.arguments
        guard args.contains("-UITestMode") else { return }

        func arg(after flag: String) -> String? {
            guard let idx = args.firstIndex(of: flag), args.index(after: idx) < args.endIndex else { return nil }
            return args[args.index(after: idx)]
        }

        if let appId = arg(after: "-UITestAppID") { AppConstants.APP_ID = appId }
        if let authKey = arg(after: "-UITestAuthKey") { AppConstants.AUTH_KEY = authKey }
        if let region = arg(after: "-UITestRegion") { AppConstants.REGION = region }
        AppConstants.saveAppConstants()

        if let uid = arg(after: "-UITestUID") {
            UserDefaults.standard.set(uid, forKey: "uitest_uid")
        }
    }

    /// Auto-login the injected test UID if no user is logged in, then route.
    private func loginTestUserIfNeeded(completion: @escaping () -> ()) {
        guard ProcessInfo.processInfo.arguments.contains("-UITestMode"),
              CometChat.getLoggedInUser() == nil,
              let uid = UserDefaults.standard.string(forKey: "uitest_uid") else {
            completion()
            return
        }

        CometChatUIKit.login(uid: uid) { _ in
            DispatchQueue.main.async { completion() }
        }
    }
}

#endif

