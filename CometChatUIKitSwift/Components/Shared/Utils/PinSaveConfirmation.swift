//
//  PinSaveConfirmation.swift
//  CometChatUIKitSwift
//

import UIKit

/// The confirmation prompts shown before an unpin or unsave.
///
/// Only the removing half of each toggle confirms — pin and save stay one-tap. Removing
/// is the side a mis-tap cannot undo without re-finding the message, so it is the side
/// worth a prompt.
public enum PinSaveConfirmation {

    /// The three prompts, each carrying its own copy and confirm-button caption.
    public enum Kind {
        case unpinMessage
        case unsaveMessage
        case unpinConversation

        var title: String {
            switch self {
            case .unpinMessage: return "UNPIN_MESSAGE_CONFIRM_TITLE".localize()
            case .unsaveMessage: return "UNSAVE_MESSAGE_CONFIRM_TITLE".localize()
            case .unpinConversation: return "UNPIN_CONVERSATION_CONFIRM_TITLE".localize()
            }
        }

        var body: String {
            switch self {
            case .unpinMessage: return "UNPIN_MESSAGE_CONFIRM_BODY".localize()
            case .unsaveMessage: return "UNSAVE_MESSAGE_CONFIRM_BODY".localize()
            case .unpinConversation: return "UNPIN_CONVERSATION_CONFIRM_BODY".localize()
            }
        }

        var confirmTitle: String {
            switch self {
            case .unpinMessage, .unpinConversation: return "UNPIN_ACTION".localize()
            case .unsaveMessage: return "UNSAVE_ACTION".localize()
            }
        }
    }

    /// Presents the prompt on `controller`, running `onConfirm` only if the user confirms.
    ///
    /// The confirm button is `.default`, not `.destructive`: unpinning and unsaving remove
    /// a bookmark, not the message, so the red treatment reserved for delete would overstate
    /// them. Nothing runs on cancel — callers must not begin their in-flight guard or mutate
    /// state until `onConfirm` fires.
    public static func present(_ kind: Kind,
                               on controller: UIViewController?,
                               onConfirm: @escaping () -> Void) {
        guard let controller else { return }

        let alert = UIAlertController(title: kind.title,
                                      message: kind.body,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "CANCEL".localize(), style: .cancel))
        let confirm = UIAlertAction(title: kind.confirmTitle, style: .default) { _ in
            onConfirm()
        }
        alert.addAction(confirm)
        alert.preferredAction = confirm

        controller.present(alert, animated: true)
    }
}
