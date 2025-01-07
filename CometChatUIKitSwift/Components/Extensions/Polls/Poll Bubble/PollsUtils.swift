//
//  PollsUtils.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 19/09/24.
//

import Foundation
import CometChatSDK

class PollUtils {
    
    //Getting polls data from the messages metaData. Refer to this doc: https://www.cometchat.com/docs/extensions/polls#4-getting-results
    public func parsePolls(forMessage: BaseMessage) -> PollsData {
        
        let pollsData = PollsData()
        
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let pollsDictionary = cometChatExtension["polls"] as? [String : Any] {
            if let pollID = pollsDictionary["id"] as? String {
                pollsData.id = pollID
            }
            if let currentQuestion = pollsDictionary["question"] as? String {
                pollsData.question = currentQuestion
            }
            if let results = pollsDictionary["results"] as? [String: Any], let options = results["options"] as? [String: Any], let total = results["total"] as? Int {
                pollsData.total = total
                for (index, _) in options.enumerated() {
                    let optionsInfo = PollOptions()
                    if let dict = options["\(index + 1)"] as? [String: Any] {
                        optionsInfo.count = dict["count"] as? Int ?? 0
                        optionsInfo.index = "\(index + 1)"
                        if let voters = dict["voters"] as? [String: [String: Any]] {
                            for voter in voters {
                                optionsInfo.user.append((
                                    uid: voter.key,
                                    avatar: (voter.value["avatar"]  as? String) ?? "",
                                    name: voter.value["name"] as? String ?? ""
                                ))
                            }
                        }
                        optionsInfo.text = dict["text"] as? String ?? ""
                        pollsData.options.append(optionsInfo)
                    }
                }
            }
        }
        
        
        return pollsData
    }
}


public class PollsData {
    public var id = ""
    public var total = 0
    public var question = ""
    public var options = [PollOptions]()
}

public class PollOptions {
    public var text: String = ""
    public var count: Int = 0
    public var index: String = ""
    public var user = [(uid: String, avatar: String, name: String)]()
}
