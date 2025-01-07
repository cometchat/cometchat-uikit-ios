//
//  CometChatCallLogDetails.swift
//  Sample App
//
//  Created by Dawinder on 28/10/24.
//

#if canImport(CometChatCallsSDK)

import Foundation
import CometChatSDK
import CometChatUIKitSwift
import CometChatCallsSDK

public class CallLogDetailsVC: UIViewController {
    
    public lazy var userInfoView: CometChatMessageHeader = {
        let view = CometChatMessageHeader()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 65).isActive = true
        view.backgroundColor = .yellow
        view.titleLabel.font = CometChatTypography.Heading4.medium
        view.subtitleLabel.font = CometChatTypography.Body.regular
        view.titleContainerStackView.spacing = 4
        view.set(controller: self)
        view.disable(typing: true)
        return view
    }()
    
    public lazy var currentCallDetailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 72).isActive = true
        view.backgroundColor = CometChatTheme.backgroundColor03
        view.layer.cornerRadius = 4
        return view
    }()
    
    public lazy var callTypeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public lazy var titleStack: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Heading4.medium
        label.textColor = CometChatTheme.textColorPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Body.regular
        label.textColor = CometChatTheme.textColorSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    public lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = CometChatTypography.Caption1.medium
        label.textColor = CometChatTheme.textColorPrimary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Collection view for tabs
    public lazy var tabsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TabCell.self, forCellWithReuseIdentifier: "TabCell")
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    public lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.backgroundColor = CometChatTheme.borderColorDefault
        return view
    }()
    
    // Page view controller to manage child view controllers
    public lazy var pageViewController: UIPageViewController = {
        let pvc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pvc.dataSource = self
        pvc.delegate = self
        return pvc
    }()
    
    // View controllers for each tab
    public lazy var participantsVC: CallLogParticipantsVC = {
        let vc = CallLogParticipantsVC()
        vc.callLog = callLog
        return vc
    }()
    public lazy var recordingVC: CallLogRecordingsVC = {
        let vc = CallLogRecordingsVC()
        vc.callLog = callLog
        return vc
    }()
    public lazy var historyVC: CallLogHistoryVC = {
        let vc = CallLogHistoryVC()
        return vc
    }()
    
    public lazy var viewControllers: [UIViewController] = {
        return [participantsVC, recordingVC, historyVC]
    }()
    
    public var currentIndex: Int = 0
    
    public let tabNames = ["Participants", "Recording", "History"]
    public var callLog: CometChatCallsSDK.CallLog?
    public var currentGroup: Group?
    public var currentUser: User?
    public var callLogRequest: CometChatCallsSDK.CallLogsRequest?
    public var callLogRequestBuilder: CometChatCallsSDK.CallLogsRequest.CallLogsBuilder?

    override public func viewDidLoad() {
        super.viewDidLoad()
        if let user = currentUser{
            userInfoView.set(user: user)
        }else if let group = currentGroup{
            userInfoView.set(group: group)
        }
        setupPageViewController()
        getCallHistory()
        buildUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public func buildUI() {
        view.backgroundColor = CometChatTheme.backgroundColor01
        title = "Call Detail"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.tintColor = CometChatTheme.iconColorPrimary
        
        // Add the tabs collection view
        view.addSubview(userInfoView)
        view.addSubview(currentCallDetailView)
        view.addSubview(tabsCollectionView)
        view.addSubview(separatorView)
        userInfoView.backButton.removeFromSuperview()
        NSLayoutConstraint.activate([
            userInfoView.tailView.centerYAnchor.constraint(equalTo: userInfoView.avatar.centerYAnchor),
            userInfoView.avatar.leadingAnchor.constraint(equalTo: userInfoView.leadingAnchor, constant: 16),
            userInfoView.avatar.heightAnchor.constraint(equalToConstant: 60),
            userInfoView.avatar.widthAnchor.constraint(equalToConstant: 60),
            userInfoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            userInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            currentCallDetailView.topAnchor.constraint(equalTo: userInfoView.bottomAnchor, constant: 20),
            currentCallDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            currentCallDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            tabsCollectionView.topAnchor.constraint(equalTo: currentCallDetailView.bottomAnchor, constant: 12),
            tabsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabsCollectionView.heightAnchor.constraint(equalToConstant: 50),
            tabsCollectionView.bottomAnchor.constraint(equalTo: separatorView.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        currentCallDetailView.addSubview(callTypeImageView)
        currentCallDetailView.addSubview(titleStack)
        titleStack.addArrangedSubview(nameLabel)
        titleStack.addArrangedSubview(dateLabel)
        currentCallDetailView.addSubview(durationLabel)
        
        NSLayoutConstraint.activate([
            callTypeImageView.leadingAnchor.constraint(equalTo: currentCallDetailView.leadingAnchor, constant: 20),
            callTypeImageView.centerYAnchor.constraint(equalTo: currentCallDetailView.centerYAnchor),
            
            titleStack.leadingAnchor.constraint(equalTo: callTypeImageView.trailingAnchor, constant: 12),
            titleStack.topAnchor.constraint(equalTo: currentCallDetailView.topAnchor, constant: 8),
            titleStack.bottomAnchor.constraint(equalTo: currentCallDetailView.bottomAnchor, constant: -12),
            
            durationLabel.trailingAnchor.constraint(equalTo: currentCallDetailView.trailingAnchor, constant: -16),
            durationLabel.centerYAnchor.constraint(equalTo: titleStack.centerYAnchor)
        ])
        
        dateLabel.text = convertTimeStampToCallDate(timestamp: Double(callLog?.initiatedAt ?? 0))
        durationLabel.text = formatTime(seconds: (callLog?.totalDurationInMinutes ?? 0.0)*60)
        
        let isInitiator = CometChat.getLoggedInUser()?.uid == (callLog?.initiator as? CallUser)?.uid
        
        switch callLog?.status {
        case .busy, .unanswered, .rejected, .cancelled:
            nameLabel.text = "Missed"
            callTypeImageView.image = UIImage(named: "missed_call_image")
            callTypeImageView.tintColor = CometChatTheme.errorColor
        case .initiated, .ongoing, .ended:
            if isInitiator{
                nameLabel.text = "Outgoing"
                callTypeImageView.image = UIImage(systemName: "arrow.up.right")
                callTypeImageView.tintColor = CometChatTheme.successColor
            }else{
                nameLabel.text = "Incoming"
                callTypeImageView.image = UIImage(systemName: "arrow.down.left")
                callTypeImageView.tintColor = CometChatTheme.errorColor
            }
        case .none:
            break
        @unknown default:
            break
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tabsCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        
        setTailViewToHeader()
    }
    
    public func setTailViewToHeader() {
        if let user = currentUser {
            
            let menu = CometChatUIKit.getDataSource().getAuxiliaryHeaderMenu(user: user, group: currentGroup, controller: self, id: nil)
            menu?.distribution = .fillEqually
            menu?.alignment = .center
            menu?.spacing = 8
            menu?.widthAnchor.constraint(equalToConstant: 100).isActive = true
            userInfoView.set(tailView: menu ?? UIView())
            
        } else {
            let callButton = CometChatCallButtons(width: 24, height: 24)
            callButton.set(controller: self)
            
            if let group = currentGroup { callButton.set(group: group) }
            callButton.set(callSettingsBuilder: { user, group, isAudioOnly in
                var callSettingsBuilder = CallSettingsBuilder()
                    .setIsAudioOnly(isAudioOnly)
                callSettingsBuilder = callSettingsBuilder.setDefaultAudioMode(isAudioOnly ? "EARPIECE" : "SPEAKER")
                return callSettingsBuilder
            })
            callButton.distribution = .fillEqually
            callButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            userInfoView.set(tailView: callButton)
        }
    }
    
    public func setupPageViewController() {
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: false, completion: nil)
    }
    
    public func getCallHistory(){
        callLogRequestBuilder = CometChatCallsSDK.CallLogsRequest.CallLogsBuilder()
            .set(authToken: CometChat.getUserAuthToken())
            .set(callCategory: .call)
            .set(uid: currentUser?.uid ?? "")
            .set(guid: currentGroup?.guid ?? "")
        callLogRequest = callLogRequestBuilder?.build()
        fetchNext()
    }
    
    public func fetchNext() {
        callLogRequest?.fetchNext() { [weak self] callLogs in
            guard let this = self else { return }
            if !callLogs.isEmpty {
                this.historyVC.callLog = callLogs
            } else {
                print("empty list")
            }
        } onError: { error in
            print(error as Any)
        }
    }
}

// MARK: - Collection View Delegate & Data Source
extension CallLogDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabNames.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TabCell", for: indexPath) as! TabCell
        cell.label.text = tabNames[indexPath.item]
        cell.label.font = CometChatTypography.Heading4.medium
        if currentIndex == indexPath.item{
            cell.label.textColor = CometChatTheme.textColorHighlight
            cell.highlightView.isHidden = false
        }else{
            cell.label.textColor = CometChatTheme.textColorPrimary
            cell.highlightView.isHidden = true
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let direction: UIPageViewController.NavigationDirection = indexPath.item > currentIndex ? .forward : .reverse
        pageViewController.setViewControllers([viewControllers[indexPath.item]], direction: direction, animated: true, completion: nil)
        currentIndex = indexPath.item
        collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / CGFloat(tabNames.count), height: 50)
    }
}

// MARK: - UIPageViewController Delegate & Data Source
extension CallLogDetailsVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return viewControllers[index - 1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else {
            return nil
        }
        return viewControllers[index + 1]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first, let index = viewControllers.firstIndex(of: currentVC) {
            currentIndex = index
            tabsCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            tabsCollectionView.reloadData()
        }
    }
}

// MARK: - Custom Tab Cell
class TabCell: UICollectionViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    let highlightView: UIView = {
        let view = UIView()
        view.backgroundColor = CometChatTheme.primaryColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 3).isActive = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.addSubview(highlightView)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: highlightView.topAnchor, constant: -8),
            highlightView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            highlightView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
