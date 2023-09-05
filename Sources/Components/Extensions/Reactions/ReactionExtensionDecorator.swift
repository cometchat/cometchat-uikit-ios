//
//  ProfanityDataMaskingExtensionDecorator.swift
//  
//
//  Created by Pushpsen Airekar on 21/02/23.
//
import Foundation
import CometChatSDK

public class ReactionExtensionDecorator: DataSourceDecorator {
    
    struct CometChatEmojiKeyboardGroup: CometChatEmojiKeyboardPresentable {
        let string: String = "Select Emoji"
        let rowVC: PanModalPresentable.LayoutType = CometChatEmojiKeyboard()
    }
    
    override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getBottomView(message: BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment) -> UIView? {
        return getReactionsContainer(message: message, controller: controller, alignment: alignment)
    }
    
    public func getReactionsContainer(message: BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment) -> UIStackView? {
        return set(reactions: message, with: alignment, controller: controller)
    }
    
    public func set(reactions forMessage: BaseMessage, with alignment: MessageBubbleAlignment, controller: UIViewController?) -> UIStackView? {
        let stackView = UIStackView()
        let messageReactions = CometChatMessageReactions()
        if let reactionView = messageReactions.parseMessageReactionForMessage(message: forMessage) {
            let height = messageReactions.calculateHeight()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.heightAnchor.constraint(equalToConstant: height).isActive = true
            stackView.addArrangedSubview(reactionView)
            messageReactions.setOnClick { reaction in
                if let title = reaction.title {
                    CometChat.callExtension(slug: ExtensionConstants.reactions, type: .post, endPoint: "v1/react", body: ["msgId": forMessage.id , "emoji": title], onSuccess: { (success) in
                        print("Success: \(String(describing: success))")
                    }) { (error) in
                        
                        if let error = error {
                            print(error)
                        }
                    }
                }
            }
            
            messageReactions.didAddReaction {
                let emojiKeyboard = CometChatEmojiKeyboard()
                emojiKeyboard.setOnClick { emoji in
                    CometChat.callExtension(slug: ExtensionConstants.reactions, type: .post, endPoint: "v1/react", body: ["msgId":forMessage.id , "emoji":emoji.emoji], onSuccess: { (success) in
                        print("Success: \(String(describing: success))")
                    }) { (error) in
                        if let error = error {
                            print(error)
                        }
                    }
                }
                
                controller?.presentPanModal(emojiKeyboard, backgroundColor: CometChatTheme.palatte.background)
            }
            return stackView
        } else {
            return nil
        }
        
    }
    
    public override func getCommonOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption] {
        var messageOptions = super.getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
        if let index = messageOptions.firstIndex(where: {$0.id ==  MessageOptionConstants.deleteMessage}) {
            messageOptions.insert(getOption(controller: controller, message: messageObject), at: index + 1)
        } else if let index = messageOptions.firstIndex(where: {$0.id ==  MessageOptionConstants.messagePrivately}) {
            messageOptions.insert(getOption(controller: controller, message: messageObject), at: index + 1)
        } else if let index = messageOptions.firstIndex(where: {$0.id ==  MessageOptionConstants.messageInformation}) {
            messageOptions.insert(getOption(controller: controller, message: messageObject), at: index + 1)
        }
        return messageOptions
    }
    
    public func getOption(controller: UIViewController?, message: BaseMessage) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.reactToMessage, title: "ADD_REACTION".localize(), icon: UIImage(named: "add-reaction.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withTintColor(CometChatTheme.palatte.accent700)) { message in
            if let controller = controller {
                let emojiKeyboard = CometChatEmojiKeyboard()
                emojiKeyboard.setOnClick { emoji in
                    CometChat.callExtension(slug: ExtensionConstants.reactions, type: .post, endPoint: "v1/react", body: ["msgId":message?.id ?? "", "emoji":emoji.emoji], onSuccess: { (success) in
                        print("Success: \(String(describing: success))")
                    }) { (error) in
                        if let error = error {
                            print(error)
                        }
                    }
                }
                controller.presentPanModal(emojiKeyboard, backgroundColor: CometChatTheme.palatte.background)
            }
        }
    }
    
    public override func getId() -> String {
        return "reactions"
    }
}
