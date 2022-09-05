//
//  CometChatPollsBubble.swift
//  DemoCometChat
//
//  Created by Abdullah Ansari on 16/05/22.
//

import UIKit
import CometChatPro

public class CometChatPollsBubble: UIView {

    // MARK: - Properties
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var answerList: UITableView!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var answeredPoll: UILabel!
    @IBOutlet weak var answerListHeightConstraint: NSLayoutConstraint!
    var results: [String: Any] = [:]
    private var cellIdentifier = "pollCell"
    private var pollID = ""
    private var voters: [String] = []
    /// Added for tableviewcell.
    var isStandard = false
    var isSender: Bool = false
    var controller: UIViewController?
    var customMessage: CustomMessage?
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init(frame: CGRect, message: CustomMessage, isStandard: Bool, isSender: Bool) {
        self.init(frame: frame)
        // Set the messge here.
        self.isStandard = isStandard
        self.isSender = isSender
        setupList(message: message)
        self.set(message: message)
        // Setup Style
        setupStyle(isStandard: isStandard)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helper Methods.
    
    private func setupStyle(isStandard: Bool) {
        let pollStyle = PollBubbleStyle(
            questionColor: CometChatTheme.palatte?.accent900 ,
            questionFont: CometChatTheme.typography?.Name2,
            answeredPollTextColor: CometChatTheme.palatte?.accent600,
            answeredPollTextFont: CometChatTheme.typography?.Subtitle2)
            set(style: pollStyle)
       
    }
    
    private func set(style: PollBubbleStyle) -> Self {
        self.set(questionColor: style.questionColor!)
        self.set(questionFont: style.questionFont!)
        self.set(answeredPollTextColor: style.answeredPollTextColor!)
        self.set(answeredPollTextFont: style.answeredPollTextFont!)
        return self
    }
    
    private func setupList(message: CustomMessage) {
        answerList.delegate = self
        answerList.dataSource = self
        let nib = UINib(nibName: "CometChatPollBubbleCell", bundle: CometChatUIKit.bundle)
        answerList.register(nib, forCellReuseIdentifier: cellIdentifier)
        answerList.separatorStyle = .none
        answerList.isScrollEnabled = false
        self.parsePolls(forMessage: message)
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
        containerView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    @discardableResult
    public func set(message: CustomMessage) -> Self {
        self.customMessage = message
        return self
    }
    
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    @objc public func set(questionColor: UIColor) -> Self {
        self.question.textColor = questionColor
        return self
    }
    
    @discardableResult
    @objc public func set(questionFont: UIFont) -> Self {
        self.question.font = questionFont
        return self
    }
    
    @discardableResult
    @objc public func set(answeredPollTextColor: UIColor) -> Self {
            self.answeredPoll.textColor = answeredPollTextColor
        return self
    }
    
    @discardableResult
    @objc public func set(answeredPollTextFont: UIFont) -> Self {
        self.answeredPoll.font = answeredPollTextFont
        return self
    }
    
    @discardableResult
    @objc public func set(question: String) -> Self {
        self.question.text = question
        return self
    }
    
    @discardableResult
    @objc public func set(answeredPoll: String) -> Self {
        self.answeredPoll.text = answeredPoll + " " + "PEOPLE_VOTED".localize()
        return self
    }

    private func parsePolls(forMessage: CustomMessage) {
        
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let pollsDictionary = cometChatExtension[ExtensionConstants.polls] as? [String : Any] {
            if let pollID = pollsDictionary["id"] as? String {
               self.pollID = pollID
            }
            if let currentQuestion = pollsDictionary["question"] as? String {
                set(question: currentQuestion)
            }
            if let results = pollsDictionary["results"] as? [String: Any], let options = results["options"] as? [String: Any], let total = results["total"] as? Int {
                self.voters.removeAll()
                set(answeredPoll: "\(total)")
                for (index, value) in options.enumerated() {
                    print(index, value)
                    if let dict = options["\(index + 1)"] as? [String: Any], let voters = dict["voters"] as? [String: Any] {
                        for voter in voters.keys {
                            self.voters.append(voter)
                        }
                    }
                }
                self.results = results
                /// Update the constraint after having value in options.
                answerListHeightConstraint.constant = CGFloat(options.count * 40)
                self.answerList.reloadData()
            }
        }
    }
}

extension CometChatPollsBubble: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let options = results["options"] as? [String: Any] else { return 0 }
        return options.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CometChatPollBubbleCell else { print("Could not found CometChatPollBubbleCell"); return UITableViewCell() }
        cell.configure(isStandard: isStandard, results: results, indexPath: indexPath, isSender: isSender, voters: voters)
        cell.callBack = { [weak self] in
            guard let strongSelf = self else { return }
            Indicator.show()
            CometChat.callExtension(slug: ExtensionConstants.polls, type: .post, endPoint: "v2/vote", body: ["vote": indexPath.row + 1, "id": strongSelf.pollID]) { response in
                Indicator.hide()
            } onError: { error in
                guard let error = error else { return }
                print("Error whiling voting to the poll \(error.errorDescription)")
            }
            return
        }
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let message = customMessage, CometChat.getLoggedInUser()!.uid! != message.sender?.uid {
            Indicator.show()
            CometChat.callExtension(slug: ExtensionConstants.polls, type: .post, endPoint: "v2/vote", body: ["vote": indexPath.row + 1, "id": pollID]) { response in
                Indicator.hide()
            } onError: { error in
                guard let error = error else { return }
                print("Error whiling voting to the poll \(error.errorDescription)")
                Indicator.hide()
            }
        }
    }
}

//TODO: - This class should be in separate file.
class Indicator {
    
    private static var loadingIndicator: UIActivityIndicatorView!
    private static var alert: UIAlertController!
    
    static func show() {
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator?.color = CometChatTheme.palatte?.accent600
        loadingIndicator.startAnimating()
        alert = UIAlertController(title: nil, message: "VOTING".localize(), preferredStyle: .alert)
        alert.view.addSubview(loadingIndicator)
        DispatchQueue.main.async {
            if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({$0.windows }).first(where: { $0.isKeyWindow }) {
                window.rootViewController?.presentedViewController?.present(alert, animated: true)
            }
        }
    }
    
    static func hide() {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).flatMap({$0.windows }).first(where: { $0.isKeyWindow }) {
                window.rootViewController?.presentedViewController?.dismiss(animated: true)
            }
        }
    }
}
