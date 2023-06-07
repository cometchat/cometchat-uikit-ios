//
//  MessageBubbleConfiguration.swift
 
//
//  Created by Pushpsen Airekar on 15/02/22.
//

import Foundation
import UIKit

public class  MessageBubbleConfiguration : CometChatConfiguration {

//    private(set) var sentMessageInputData: SentMessageInputData? // messageBubbleData
//    private(set) var receivedMessageInputData: ReceivedMessageInputData? // messageBubbleData
    private(set) var messageBubbleAlignment: MessageBubbleAlignment?
    private(set) var timeAlignment: MessageBubbleTimeAlignment = .bottom
    private(set) var messageBubbleStyle: MessageBubbleStyle?
    private(set) var avatarConfiguration: AvatarConfiguration?
    private(set) var receiptConfiguration: ReceiptConfiguration?
    private(set) var dateConfiguration: DateConfiguration?
    private(set) var messageReactionsConfiguration: MessageReactionsConfiguration?
    private(set) var fileBubbleConfiguration: FileBubbleConfiguration?
    private(set) var imageBubbleConfiguration: ImageBubbleConfiguration?
    private(set) var audioBubbleConfiguration: AudioBubbleConfiguration?
    private(set) var videoBubbleConfiguration: VideoBubbleConfiguration?
    private(set) var pollBubbleConfiguration: PollBubbleConfiguration?
    private(set) var stickerBubbleConfiguration: StickerBubbleConfiguration?
    private(set) var groupActionBubbleConfiguration: GroupActionBubbleConfiguration?
    private(set) var placeholderBubbleConfiguration: PlaceholderBubbleConfiguration?
    private(set) var deletedBubbleConfiguration: DeletedBubbleConfiguration?
    private(set) var collaborativeWhiteboardBubbleConfiguration: CollaborativeWhiteboardBubbleConfiguration?
    private(set) var collaborativeDocumentBubbleConfiguration: CollaborativeDocumentBubbleConfiguration?
    private(set) var menuListConfiguration: MenuListConfiguration?
  //  private(set) var locationBubbleConfiguration: LocationBubbleConfiguration?
 
//    @discardableResult
//    public func set(sentMessageInputData: SentMessageInputData) -> Self {
//        self.sentMessageInputData = sentMessageInputData
//        return self
//    }
//    
//    @discardableResult
//    public func set(receivedMessageInputData: ReceivedMessageInputData) -> Self {
//        self.receivedMessageInputData = receivedMessageInputData
//        return self
//    }
    
    @discardableResult
    public func set(messageBubbleAlignment: MessageBubbleAlignment) -> Self {
        self.messageBubbleAlignment = messageBubbleAlignment
        return self
    }
    
    @discardableResult
    public func set(timeAlignment: MessageBubbleTimeAlignment) -> Self {
        self.timeAlignment = timeAlignment
        return self
    }
    
    @discardableResult
    public func set(messageBubbleStyle: MessageBubbleStyle) -> Self {
        self.messageBubbleStyle = messageBubbleStyle
        return self
    }
    
    @discardableResult
    public func set(avatarConfiguration: AvatarConfiguration) -> Self {
        self.avatarConfiguration = avatarConfiguration
        return self
    }
    
    @discardableResult
    public func set(receiptConfiguration: ReceiptConfiguration) -> Self {
        self.receiptConfiguration = receiptConfiguration
        return self
    }
    
    @discardableResult
    public func set(dateConfiguration: DateConfiguration) -> Self {
        self.dateConfiguration = dateConfiguration
        return self
    }
    
    @discardableResult
    public func set(messageReactionsConfiguration: MessageReactionsConfiguration) -> Self {
        self.messageReactionsConfiguration = messageReactionsConfiguration
        return self
    }
    
    @discardableResult
    public func set(fileBubbleConfiguration: FileBubbleConfiguration) -> Self {
        self.fileBubbleConfiguration = fileBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(imageBubbleConfiguration: ImageBubbleConfiguration) -> Self {
        self.imageBubbleConfiguration = imageBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(audioBubbleConfiguration: AudioBubbleConfiguration) -> Self {
        self.audioBubbleConfiguration = audioBubbleConfiguration
        
        return self
    }
    
    @discardableResult
    public func set(videoBubbleConfiguration: VideoBubbleConfiguration) -> Self {
        self.videoBubbleConfiguration = videoBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(pollBubbleConfiguration: PollBubbleConfiguration) -> Self {
        self.pollBubbleConfiguration = pollBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(stickerBubbleConfiguration: StickerBubbleConfiguration) -> Self {
        self.stickerBubbleConfiguration = stickerBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(groupActionBubbleConfiguration: GroupActionBubbleConfiguration) -> Self {
        self.groupActionBubbleConfiguration = groupActionBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(placeholderBubbleConfiguration: PlaceholderBubbleConfiguration) -> Self {
        self.placeholderBubbleConfiguration = placeholderBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(deletedBubbleConfiguration: DeletedBubbleConfiguration) -> Self {
        self.deletedBubbleConfiguration = deletedBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(collaborativeWhiteboardBubbleConfiguration: CollaborativeWhiteboardBubbleConfiguration) -> Self {
        self.collaborativeWhiteboardBubbleConfiguration = collaborativeWhiteboardBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(collaborativeDocumentBubbleConfiguration: CollaborativeDocumentBubbleConfiguration) -> Self {
        self.collaborativeDocumentBubbleConfiguration = collaborativeDocumentBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(menuListConfiguration: MenuListConfiguration) -> Self {
        self.menuListConfiguration = menuListConfiguration
        return self
    }
    
//    @discardableResult
//    public func set(locationBubbleConfiguration: LocationBubbleConfiguration) -> Self {
//        self.locationBubbleConfiguration = locationBubbleConfiguration
//        return self
//    }
  
}
