//
//  ConversationsUtils.swift
//
//
//  Created by Pushpsen Airekar on 20/12/22.
//

import Foundation
import UIKit
import CometChatSDK

public class ConversationsUtils {
    
    public init() {}
    
    public func configureTailView(conversation: Conversation, badgeStyle: BadgeStyle,dateStyle: DateStyle, datePattern: String?) -> UIView {
        let tailView = UIStackView()
        tailView.distribution = .fill
        tailView.alignment = .trailing
        tailView.axis = .vertical
        tailView.spacing = 10
        
        let dateLabel = CometChatDate()
        if let datePattern = datePattern, !datePattern.isEmpty {
            dateLabel.text = datePattern
        } else {
            dateLabel.set(pattern: .dayDate)
            dateLabel.set(timestamp: Int(conversation.updatedAt))
        }
        
        dateLabel.textAlignment = .center
        dateLabel.font = dateStyle.titleFont
        dateLabel.textColor = dateStyle.titleColor
        
        let badgeCount = UILabel()
        badgeCount.text = "\(conversation.unreadMessageCount)"
        if conversation.unreadMessageCount == 0 {
            badgeCount.textColor = .clear
            badgeCount.backgroundColor = .clear
        } else {
            badgeCount.textColor = badgeStyle.textColor
            badgeCount.backgroundColor = CometChatTheme.palatte.primary
        }
        badgeCount.textAlignment = .center
        badgeCount.font = badgeStyle.textFont
        badgeCount.heightAnchor.constraint(equalToConstant: 20).isActive = true
        badgeCount.widthAnchor.constraint(equalToConstant: 30).isActive = true
        badgeCount.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 10))
        
        switch conversation.conversationType {
        case .user:
            guard let _ = conversation.conversationWith as? User else { return tailView }
        case .group:
            guard let _ = conversation.conversationWith as? Group else { return tailView }
        default: print("")
        }
        
        tailView.addArrangedSubview(dateLabel)
        tailView.addArrangedSubview(badgeCount)
        return tailView
    }
    
    public func configureSubtitleView(conversation: Conversation, isTypingEnabled: Bool, isHideDeletedMessages: Bool, sentIcon: UIImage?, deliveredIcon: UIImage?, readIcon: UIImage?, receiptStyle: ReceiptStyle?, disableReceipt: Bool) -> UIView {
        
        let subTitleView = UIStackView()
        subTitleView.alignment = .leading
        subTitleView.distribution = .fillProportionally
        subTitleView.axis = .vertical
        subTitleView.spacing = 10
        subTitleView.tag = 1000
        
        let typing = UILabel()
        if conversation.lastMessage?.receiverType == .user {
            typing.text = ConversationConstants.typingText
        } else {
            typing.text = ConversationConstants.isTyping
        }
        typing.tag = 1
        let threadIndicator = UILabel()
        threadIndicator.tag = 2
        threadIndicator.text = ConversationConstants.inAThread
        
        let lastStackView = UIStackView()
        lastStackView.alignment = .top
        lastStackView.distribution = .fill
        lastStackView.axis = .horizontal
        lastStackView.spacing = 2.0
        lastStackView.tag = 100
        
        let reciept = CometChatReceipt(image: UIImage(named: "messages-delivered" ,in: CometChatUIKit.bundle, with: nil))
        reciept.heightAnchor.constraint(equalToConstant: 20).isActive = true
        reciept.widthAnchor.constraint(equalToConstant: 20).isActive = true
        reciept.tag = 3
        
        let lastMessage = UILabel()
        lastMessage.font = CometChatTheme.typography.subtitle1
        lastMessage.textColor = CometChatTheme.palatte.accent700
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.numberOfLines = 2
        lastMessage.tag = 4
        
        let callIcon = UIImageView()
        callIcon.translatesAutoresizingMaskIntoConstraints = false
        callIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        callIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        callIcon.tintColor = CometChatTheme.palatte.accent500
        callIcon.tag = 5
        
        if let lastMessage = conversation.lastMessage {
                reciept.set(style: receiptStyle ?? ReceiptStyle())
                reciept.disable(receipt: disableReceipt)
                reciept.set(messageSentIcon: sentIcon).set(messageDeliveredIcon: deliveredIcon).set(messageReadIcon: readIcon)
                reciept.set(receipt: MessageReceiptUtils.get(receiptStatus: lastMessage))
           
        } else {
            reciept.isHidden = true
        }
        
        lastMessage.text = getLastMessage(conversation: conversation, isHideDeletedMessages: isHideDeletedMessages)
                
        if let call = conversation.lastMessage as? Call {
            switch call.callType {
            case .audio:
                callIcon.image = UIImage(named: "VoiceCall", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            case .video:
                callIcon.image = UIImage(named: "VideoCall", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
            @unknown default: break
                
            }
            
            lastStackView.addArrangedSubview(callIcon)
            
        } else {
            if let customMessage = conversation.lastMessage as? CustomMessage, customMessage.type == MessageTypeConstants.meeting {
                callIcon.image = UIImage(named: "VideoCall", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
                lastStackView.addArrangedSubview(callIcon)
            } else {
                if !disableReceipt {
                    if LoggedInUserInformation.isLoggedInUser(uid: conversation.lastMessage?.sender?.uid) {
                        lastStackView.addArrangedSubview(reciept)
                    }
                }
            }
        }
        
        lastStackView.addArrangedSubview(lastMessage)
        
        if isTypingEnabled {
            subTitleView.addArrangedSubview(typing)
        } else {
            if let lastMessage = conversation.lastMessage, lastMessage.parentMessageId != 0 {
                subTitleView.addArrangedSubview(threadIndicator)
            }
            subTitleView.addArrangedSubview(lastStackView)
        }
        
        return subTitleView
    }
    
    public func getLastMessage(conversation: Conversation, isHideDeletedMessages: Bool) -> String {
        var lastMessage = ""
        
        if let currentMessage = conversation.lastMessage {
            
            switch currentMessage.messageCategory {
            case .message:
                if currentMessage.deletedAt > 0.0 {
                    if isHideDeletedMessages {
                        lastMessage = ""
                    } else {
                        lastMessage = ConversationConstants.thisMessageDeleted
                    }
                } else {
                    switch currentMessage.messageType {
                    case .text where conversation.conversationType == .user:
                        if let textMessage = currentMessage as? TextMessage {
                            lastMessage =  ProfanityDataMaskingExtensionDecorator.getContentText(message: textMessage)
                        }
                    case .text where conversation.conversationType == .group:
                        if let textMessage = conversation.lastMessage as? TextMessage {
                            lastMessage = ProfanityDataMaskingExtensionDecorator.getContentText(message: textMessage)
                        }
                    case .image where conversation.conversationType == .user:
                        lastMessage = ConversationConstants.messageImage
                    case .image where conversation.conversationType == .group:
                        lastMessage = ConversationConstants.messageImage
                    case .video  where conversation.conversationType == .user:
                        lastMessage = ConversationConstants.messageVideo
                    case .video  where conversation.conversationType == .group:
                        lastMessage = ConversationConstants.messageVideo
                    case .audio  where conversation.conversationType == .user:
                        lastMessage = ConversationConstants.messageAudio
                    case .audio  where conversation.conversationType == .group:
                        lastMessage = ConversationConstants.messageAudio
                    case .file  where conversation.conversationType == .user:
                        lastMessage = ConversationConstants.messageFile
                    case .file  where conversation.conversationType == .group:
                        lastMessage = ConversationConstants.messageFile
                    case .custom where conversation.conversationType == .user:
                        
                        if let customMessage = conversation.lastMessage as? CustomMessage {
                            if customMessage.type == MessageTypeConstants.location {
                                lastMessage = ConversationConstants.customMessageLocation
                            } else if customMessage.type == MessageTypeConstants.poll {
                                lastMessage = ConversationConstants.customMessagePoll
                            } else if customMessage.type == MessageTypeConstants.sticker {
                                lastMessage = ConversationConstants.customMessageSticker
                            } else if customMessage.type == MessageTypeConstants.whiteboard {
                                lastMessage = ConversationConstants.customMessageWhiteboard
                            } else if customMessage.type == MessageTypeConstants.document {
                                lastMessage = ConversationConstants.customMessageDocument
                            } else if customMessage.type == MessageTypeConstants.meeting {
                                lastMessage = ConversationConstants.hasIntiatedGroupAudioCall
                            }
                            
                        } else {
                            if let pushNotificationTitle = currentMessage.metaData?["pushNotification"] as? String {
                                if !pushNotificationTitle.isEmpty {
                                    lastMessage = pushNotificationTitle
                                }
                            }
                        }
                    case .custom where conversation.conversationType == .group:
                        if let customMessage = conversation.lastMessage as? CustomMessage {
                            if customMessage.type == MessageTypeConstants.location {
                                lastMessage = ConversationConstants.customMessageLocation
                            } else if customMessage.type == MessageTypeConstants.poll {
                                lastMessage = ConversationConstants.customMessagePoll
                            } else if customMessage.type == MessageTypeConstants.sticker {
                                lastMessage = ConversationConstants.customMessageSticker
                            } else if customMessage.type == MessageTypeConstants.whiteboard {
                                lastMessage = ConversationConstants.customMessageWhiteboard
                            } else if customMessage.type == MessageTypeConstants.document {
                                lastMessage = ConversationConstants.customMessageDocument
                            } else if customMessage.type == MessageTypeConstants.meeting {
                                lastMessage = ConversationConstants.hasIntiatedGroupAudioCall
                            }
                        } else {
                            if let pushNotificationTitle = currentMessage.metaData?["pushNotification"] as? String {
                                if !pushNotificationTitle.isEmpty {
                                    lastMessage = pushNotificationTitle
                                }
                            }
                        }
                    case .groupMember, .text, .image, .video,.audio, .file,.custom: break
                    @unknown default: break
                    }
                }
            case .action:
                if let text = ((currentMessage as? ActionMessage)?.message) {
                    lastMessage = text
                }
            case .call:
                if let call = conversation.lastMessage as? Call {
                    let isLoggedInUser: Bool = (call.callInitiator as? User)?.uid == LoggedInUserInformation.getUID()
                    switch call.callStatus {
                        
                    case .initiated where call.receiverType == .user:
                       lastMessage = isLoggedInUser ? "OUTGOING_CALL".localize() : "INCOMING_CALL".localize()
                       
                    case .unanswered where call.receiverType == .user:
                        lastMessage = isLoggedInUser ? "CALL_UNANSWERED".localize() :  "MISSED_CALL".localize()
                       
                    case .rejected where call.receiverType == .user:
                        lastMessage = isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize()
                       
                    case .cancelled where call.receiverType == .user:
                        lastMessage = isLoggedInUser ? "CALL_CANCELLED".localize() : "MISSED_CALL".localize()
                      
                    case .busy where call.receiverType == .user:
                        lastMessage = isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize()
                       
                    case .ended:
                        lastMessage = "CALL_ENDED".localize()
                       
                    case .ongoing:
                        lastMessage = "CALL_ACCEPTED".localize()
                       
                    @unknown default: break
                   
                    }
                }
              
            case .custom where conversation.conversationType == .user:
                
                if let customMessage = currentMessage as? CustomMessage {
                    if customMessage.type == MessageTypeConstants.location {
                        lastMessage = ConversationConstants.customMessageLocation
                    } else if customMessage.type == MessageTypeConstants.poll {
                        lastMessage = ConversationConstants.customMessagePoll
                    } else if customMessage.type == MessageTypeConstants.sticker {
                        lastMessage = ConversationConstants.customMessageSticker
                    } else if customMessage.type == MessageTypeConstants.whiteboard {
                        lastMessage = ConversationConstants.customMessageWhiteboard
                    } else if customMessage.type == MessageTypeConstants.document {
                        lastMessage =  ConversationConstants.customMessageDocument
                    } else if customMessage.type == MessageTypeConstants.meeting {
                        lastMessage = ConversationConstants.hasIntiatedGroupAudioCall
                    } else {
                        if let pushNotificationTitle = customMessage.metaData?["pushNotification"] as? String {
                            if !pushNotificationTitle.isEmpty {
                                lastMessage = pushNotificationTitle
                            } else {
                                lastMessage = "\(String(describing: customMessage.customData))"
                            }
                        } else {
                            lastMessage = "\(String(describing: customMessage.customData))"
                        }
                    }
                }
            case .custom where conversation.conversationType == .group:
                if let customMessage = currentMessage as? CustomMessage {
                    if customMessage.type == MessageTypeConstants.location {
                        lastMessage =  ConversationConstants.customMessageLocation
                    } else if customMessage.type == MessageTypeConstants.poll {
                        lastMessage = ConversationConstants.customMessagePoll
                    } else if customMessage.type == MessageTypeConstants.sticker {
                        lastMessage = ConversationConstants.customMessageSticker
                    } else if customMessage.type == MessageTypeConstants.whiteboard {
                        lastMessage = ConversationConstants.customMessageWhiteboard
                    } else if customMessage.type == MessageTypeConstants.document {
                        lastMessage = ConversationConstants.customMessageDocument
                    } else if customMessage.type == MessageTypeConstants.meeting {
                       if  customMessage.sender?.uid == LoggedInUserInformation.getUID() {
                           lastMessage = ConversationConstants.youInitiatedGroupCall
                       } else {
                           if let sender = customMessage.sender?.name {
                               lastMessage = sender + ":" + ConversationConstants.hasIntiatedGroupAudioCall
                           }
                       }
                       
                    } else {
                        if let pushNotificationTitle = customMessage.metaData?["pushNotification"] as? String {
                            if !pushNotificationTitle.isEmpty {
                                lastMessage = pushNotificationTitle
                            } else {
                                lastMessage = "\(String(describing: customMessage.customData))"
                            }
                        } else {
                            lastMessage = "\(String(describing: customMessage.customData))"
                        }
                    }
                }
            case .custom: break
            @unknown default: break
            }
        } else {
            lastMessage = "TAP_TO_START_CONVERSATION".localize()
        }
        return lastMessage
    }
    
}
