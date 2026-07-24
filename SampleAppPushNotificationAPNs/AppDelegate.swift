//
//  AppDelegate.swift
//  CometChatPushNotificationSampleApp
//
//  Push Notification Sample App — master-app UI + CometChatPushNotifications SDK.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import CometChatUIKitSwift
import CometChatSDK
import CometChatPushNotificationsSwift
#if canImport(CometChatCallsSDK)
import CometChatCallsSDK
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase is used for Google login only (Auth) — not for push/FCM.
        FirebaseApp.configure()
        setupPushNotifications()
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: - Push notifications setup

    private func setupPushNotifications() {
        let config = CometChatPushNotificationsConfig(
            providerId: AppConstants.PROVIDER_ID,
            enableBadgeCount: true,
            showInAppNotifications: true,
            foregroundCallPresentation: .inApp
        )
        CometChatPushNotifications.shared.initialize(config: config)
        CometChatPushNotifications.shared.delegate = self
        CometChatPushNotifications.shared.registerForVoIPPushes()
    }

    // MARK: - APNs callbacks (UIApplicationDelegate — the SDK can't intercept these, so forward them)

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CometChatPushNotifications.shared.registerDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        CometChatPushNotifications.shared.handleBackgroundNotification(userInfo: userInfo)
        completionHandler(.newData)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

// MARK: - CometChatPushNotificationsDelegate

extension AppDelegate: CometChatPushNotificationsDelegate {

    func navigateToChat(for user: CometChatSDK.User) { routeToMessages(user: user, group: nil) }

    func navigateToChat(for group: CometChatSDK.Group) { routeToMessages(user: nil, group: group) }

    func navigateToDefaultScreen() {
        DispatchQueue.main.async { self.topMostNavigationController()?.popToRootViewController(animated: true) }
    }

    #if canImport(CometChatCallsSDK)
    func presentCallScreen(for call: CometChatSDK.Call, sessionId: String) {
        presentOngoingCall(call: call, sessionId: sessionId)   // SDK already accepted — just present
    }
    #endif

    private func routeToMessages(user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        DispatchQueue.main.async {
            let messages = MessagesVC()          // master-app's v5 chat screen
            messages.user = user
            messages.group = group
            self.topMostNavigationController()?.pushViewController(messages, animated: true)
        }
    }

    #if canImport(CometChatCallsSDK)
    private func presentOngoingCall(call: CometChatSDK.Call, sessionId: String) {
        DispatchQueue.main.async {
            let ongoing = CometChatOngoingCall()
            var builder = CometChatCallsSDK.CallSettingsBuilder()
            builder = builder.setIsAudioOnly(call.callType == .audio)
            ongoing.set(callSettingsBuilder: builder)
            ongoing.set(callWorkFlow: .defaultCalling)
            ongoing.set(sessionId: sessionId)
            ongoing.modalPresentationStyle = .fullScreen
            ongoing.setOnCallEnded { _ in
                CometChatPushNotifications.shared.endCallKitSession()   // ALWAYS on call end
                ongoing.dismiss(animated: true)
            }
            self.topMostViewController()?.present(ongoing, animated: true)
        }
    }
    #endif

    // MARK: - Top-most view/navigation helpers

    private func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    private func topMostViewController() -> UIViewController? {
        var top = keyWindow()?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    private func topMostNavigationController() -> UINavigationController? {
        let top = topMostViewController()
        if let nav = top as? UINavigationController { return nav }
        if let nav = top?.navigationController { return nav }
        if let split = top as? UISplitViewController {
            return split.viewControllers.compactMap { $0 as? UINavigationController }.last
        }
        return nil
    }
}
