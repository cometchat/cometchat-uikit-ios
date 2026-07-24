//
//  CardActionHandler.swift
//  Sample App v5
//
//  Sample app handler for card action events (§2.9.8).
//  Subscribes to ccCardActionClicked and shows a toast with action details.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift
import CometChatCardsSwift

class CardActionHandler: CometChatCardEventListener {

    static let shared = CardActionHandler()
    private init() {}

    func ccCardActionClicked(message: BaseMessage, action: CometChatCardActionEvent) {
        DispatchQueue.main.async {
            let toastMessage = """
            Action: \(action.action)
            Element: \(action.elementId)
            Message ID: \(message.id)
            """
            Self.showToast(message: toastMessage)
        }
    }

    // MARK: - Toast

    private static func showToast(message: String) {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return }

        let toastView = UIView()
        toastView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        toastView.layer.cornerRadius = 12
        toastView.clipsToBounds = true
        toastView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = message
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false

        toastView.addSubview(label)
        window.addSubview(toastView)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -12),

            toastView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 24),
            toastView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -24),
            toastView.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        toastView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toastView.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            UIView.animate(withDuration: 0.3, animations: {
                toastView.alpha = 0
            }) { _ in
                toastView.removeFromSuperview()
            }
        }
    }
}
