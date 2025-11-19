



import Foundation

public struct ExtensionConstants {
  static var  extensions = "extensions"
  static var  linkPreview = "link-preview"
  static var  smartReply = "smart-reply"
  static var  messageTranslation = "message-translation"
  static var  profanityFilter = "profanity-filter"
  static var  imageModeration = "image-moderation"
  static var  thumbnailGeneration = "thumbnail-generation"
  static var  sentimentalAnalysis = "sentiment-analysis"
  static var  polls = "polls"
  static var  reactions = "reactions"
  static var  whiteboard = "whiteboard"
  static var  document = "document"
  static var  dataMasking = "data-masking"
  static var  stickers = "stickers"
  static var  xssFilter = "xss-filter"
  static var  saveMessage = "save-message"
  static var  pinMessage = "pin-message"
  static var  voiceTranscription = "voice-transcription"
  static var  richMedia = "rich-media"
  static var  malwareScanner = "virus-malware-scanner"
  static var  mentions = "mentions"
  static var  customStickers = "customStickers"
  static var  defaultStickers = "defaultStickers"
  static var  stickerUrl = "stickerUrl"
  static var  emailReplies = "email-replies"
  static var  emojis = "emojis"
  static var  aiSmartReply = "smart-replies"
  static var  aiConversationSummary = "conversation-summary"
  static var  aiExtension = "ai-extension"
  static var aiConversationStarter = "conversation-starter"
  static var aiAssistBot = "bots"
}

class ExtensionUrls {
  static var  reaction = "v1/react"
  static var  stickers = "v1/fetch"
  static var  document = "v1/create"
  static var  whiteboard = "v1/create"
  static var  votePoll = "v2/vote"
  static var  createPoll = "v2/create"
  static var  translate = "v2/translate"
}

class ExtensionType {
  static var  extensionPoll = "extension_poll"
  static var  location = "location"
  static var  sticker = "extension_sticker"
  static var  document = "extension_document"
  static var  whiteboard = "extension_whiteboard"
}

public struct AIConstants {
    static var smartRepliesText = "SUGGEST_A_REPLY".localize()
    
}

enum AIExtension {
    case smartReplies
    
    static func fromKey(_ key: String) -> AIExtension? {
        switch key {
        case AIConstants.smartRepliesText:
            return .smartReplies
        default:
            return nil
        }
    }
}


extension UIViewController {

    /// Ensures the presented controller matches the current VC's interface style.
    func presentWithInheritedInterfaceStyle(_ viewControllerToPresent: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        if #available(iOS 13.0, *) {
            let style = traitCollection.userInterfaceStyle
            viewControllerToPresent.overrideUserInterfaceStyle = style
        }

        present(viewControllerToPresent, animated: animated) {
            if #available(iOS 13.0, *) {
                // Delay to ensure the window is attached
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                     let style = self.traitCollection.userInterfaceStyle
                        viewControllerToPresent.view.overrideUserInterfaceStyle = style
                }
            }
            completion?()
        }
    }
}
