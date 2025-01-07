//
//  CollaborativeDocumentViewModel.swift
//  
//
//  Created by Pushpsen Airekar on 18/02/23.
//

import Foundation
import CometChatSDK

class ThumbnailGenerationConfiguration {}

public class ThumbnailGenerationViewModel : DataSourceDecorator {
    
    var thumbnailGenerationTypeConstant = ExtensionConstants.thumbnailGeneration
    var configuration: ThumbnailGenerationConfiguration?
    var loggedInUser = CometChat.getLoggedInUser()
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
    }
    
    public override func getId() -> String {
        return "thumbnail-generator"
    }

    public override func getImageMessageBubble(imageUrl: String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        guard let message = message else { return UIView() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getImageMessageBubble(imageUrl: thumbnailURL, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        } else {
            return super.getImageMessageBubble(imageUrl: message.attachment?.fileUrl, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        }
    }
    
    public override func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        guard let message = message else { return UIView() }
        if let thumbnailURL = checkForThumbnail(message: message) {
            return super.getVideoMessageBubble(videoUrl: videoUrl, thumbnailUrl: thumbnailURL, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        } else {
            return super.getVideoMessageBubble(videoUrl: videoUrl, thumbnailUrl: thumbnailUrl, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
        }
    }
    
    public func getThumbnailGeneration(message: MediaMessage) -> String? {
        if let map = ExtensionModerator.extensionCheck(baseMessage: message), !map.isEmpty && map.containsKey(ExtensionConstants.thumbnailGeneration),
           let thumbnailGeneration = map[ExtensionConstants.thumbnailGeneration], let url = thumbnailGeneration["url_medium"] as? String {
            return url
        } else {
            return nil
        }
    }
    
    public func checkForThumbnail(message: MediaMessage) -> String? {
        if let mediumURL = getThumbnailGeneration(message: message) {
            return mediumURL
        }else {
            return message.attachment?.fileUrl
        }
    }
}
