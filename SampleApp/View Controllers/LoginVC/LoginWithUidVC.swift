//
//  LoginWithUidVC.swift
//  CometChatSampleApp
//
//  Created by Suryansh on 23/12/24.
//

import UIKit
import CometChatUIKitSwift

class LoginWithUidVC: UIViewController {
    
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cometchat-logo-with-name")?.withRenderingMode(.alwaysOriginal)
        imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 134).isActive = true
        return imageView
    }()
    
    lazy var signInLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SIGN_IN_COMETCHAT".localize()
        label.font = CometChatTypography.Heading2.bold
        label.textColor = CometChatTheme.textColorPrimary
        return label
    }()
    
    lazy var chooseSampleUserLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "CHOOSE_SAMPLE_USER".localize();
        label.font = CometChatTypography.Body.medium
        label.textColor = CometChatTheme.textColorPrimary
        return label
    }()
    
    lazy var sampleUserCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        layout.scrollDirection = .vertical
        return collectionView
    }()
    
    lazy var dividerView: UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let divider1 = UIView()
        divider1.translatesAutoresizingMaskIntoConstraints = false
        divider1.heightAnchor.constraint(equalToConstant: 0.6).isActive = true
        divider1.backgroundColor = CometChatTheme.textColorPrimary.withAlphaComponent(0.4)
        view.addSubview(divider1)

        let orLabel = UILabel()
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        orLabel.text = "  \("OR".localize())  "
        orLabel.backgroundColor = CometChatTheme.backgroundColor01
        orLabel.textColor = CometChatTheme.neutralColor500
        orLabel.font = CometChatTypography.Body.medium
        view.addSubview(orLabel)
        
        NSLayoutConstraint.activate([
            divider1.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider1.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            orLabel.centerYAnchor.constraint(equalTo: divider1.centerYAnchor),
            orLabel.centerXAnchor.constraint(equalTo: divider1.centerXAnchor)
        ])
        
        return view
    }()
    
    lazy var uidTextField: CustomTextFiled = {
        let textFiled = CustomTextFiled(leadingText: "UID", placeholderText: "ENTER_UID".localize())
        textFiled.textField.delegate = self
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        return textFiled
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(onContinueButtonClicked), for: .primaryActionTriggered)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CONTINUE".localize(), for: .normal)
        button.setTitleColor(CometChatTheme.white, for: .normal)
        button.backgroundColor = CometChatTheme.primaryColor
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.layer.cornerRadius = CometChatSpacing.Radius.r2
        return button
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var changeAppCredentialsLabel: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let fullText = "CHANGE_APP_CREDENTIALS".localize();
        let attributedText = NSMutableAttributedString(
            string: fullText,
            attributes: [.foregroundColor: CometChatTheme.primaryColor]
        )
        attributedText.addAttribute(
            .foregroundColor,
            value: CometChatTheme.textColorPrimary,
            range: (fullText as NSString).range(of: "CHANGE".localize())
        )
        button.setAttributedTitle(attributedText, for: .normal)
        button.titleLabel?.font = CometChatTypography.Body.regular
        button.addTarget(self, action: #selector(onAppCredentialChangeButtonClicked), for: .primaryActionTriggered)
        return button
    }()
    
    var sampleUsers: [(name: String, uid: String, avatar: String)] = [(name: String, uid: String, avatar: String)]() {
        didSet {
            DispatchQueue.main.async(execute: { [weak self] in
                self?.sampleUserCollectionView.reloadData()
            })
        }
    }
    var selectedSampleUser: (name: String, uid: String, avatar: String)?
    lazy var keyboardDismissGusture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    
    var selectedUID = -1


    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        fetchUserData()
        sampleUserCollectionView.register(SampleUserCVCell.self, forCellWithReuseIdentifier: "SampleUserCVCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    open func handleThemeModeChange() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                self.logoImageView.image = UIImage(named: "cometchat-logo-with-name")?.withRenderingMode(.alwaysOriginal)
            })
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check if the user interface style has changed
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            logoImageView.image = UIImage(named: "cometchat-logo-with-name")?.withRenderingMode(.alwaysOriginal)
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.view.removeGestureRecognizer(keyboardDismissGusture)
        let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.3
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            self?.scrollView.contentInset = .zero
            self?.scrollView.scrollIndicatorInsets = .zero
        })
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        self.view.addGestureRecognizer(keyboardDismissGusture)
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = calculateKeyboardHeight(from: keyboardFrame)
            let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.3
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                self?.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
                self?.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            })
            // Scroll to make the text field visible
            let textFieldFrame = uidTextField.convert(uidTextField.bounds, to: scrollView)
            scrollView.scrollRectToVisible(textFieldFrame.insetBy(dx: 0, dy: -60), animated: true)
        }
    }
    
    /// Calculate keyboard height accounting for iPad flexible window positioning
    private func calculateKeyboardHeight(from keyboardFrame: CGRect) -> CGFloat {
        guard let window = self.view.window else {
            return keyboardFrame.height
        }
        
        // Convert keyboard frame from screen coordinates to window coordinates
        let keyboardFrameInWindow = window.convert(keyboardFrame, from: nil)
        
        // Calculate the keyboard height relative to the window bottom
        let windowHeight = window.bounds.height
        let keyboardTopInWindow = keyboardFrameInWindow.origin.y
        
        // If keyboard is below the window (not visible), return 0
        if keyboardTopInWindow >= windowHeight {
            return 0
        }
        
        return max(0, windowHeight - keyboardTopInWindow)
    }
    
    func buildUI() {
        
        view.backgroundColor = CometChatTheme.backgroundColor01
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        scrollView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        containerView.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        containerView.addSubview(signInLabel)
        NSLayoutConstraint.activate([
            signInLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: CometChatSpacing.Padding.p5),
            signInLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        containerView.addSubview(chooseSampleUserLabel)
        NSLayoutConstraint.activate([
            chooseSampleUserLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            chooseSampleUserLabel.topAnchor.constraint(equalTo: signInLabel.bottomAnchor, constant: CometChatSpacing.Padding.p10)
        ])
        
        containerView.addSubview(sampleUserCollectionView)
        NSLayoutConstraint.activate([
            sampleUserCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            sampleUserCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            sampleUserCollectionView.topAnchor.constraint(equalTo: chooseSampleUserLabel.bottomAnchor, constant: 8),
            sampleUserCollectionView.heightAnchor.constraint(equalToConstant: 250)
        ])
        
        containerView.addSubview(dividerView)
        NSLayoutConstraint.activate([
            dividerView.topAnchor.constraint(equalTo: sampleUserCollectionView.bottomAnchor, constant: 0),
            dividerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        containerView.addSubview(uidTextField)
        NSLayoutConstraint.activate([
            uidTextField.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 15),
            uidTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            uidTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        containerView.addSubview(continueButton)
        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: uidTextField.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
        
        containerView.addSubview(changeAppCredentialsLabel)
        NSLayoutConstraint.activate([
            changeAppCredentialsLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 10),
            changeAppCredentialsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            changeAppCredentialsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10)
        ])
        
    }
    
    @objc func onAppCredentialChangeButtonClicked() {
        let ChangeAppCredentialsVC = ChangeAppCredentialsVC()
        self.present(ChangeAppCredentialsVC, animated: true)
    }
    
    @objc func onContinueButtonClicked() {
        if let uid = selectedSampleUser?.uid ?? uidTextField.textField.text, !uid.isEmpty {
            self.continueButton.showLoading()
            CometChatUIKit.login(uid: uid) { result in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.continueButton.hideLoading(withTitle: "CONTINUE".localize())
                        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            sceneDelegate.setRootViewController(SplitViewController())
                        } else {
                            sceneDelegate.setRootViewController(UINavigationController(rootViewController: HomeScreenViewController()))
                        }
                    }
                    break
                case .onError(let error):
                    DispatchQueue.main.async {
                        self.continueButton.hideLoading(withTitle: "CONTINUE".localize())
                        self.presentSomethingWentWrongAlert(error: error.errorDescription)
                    }
                @unknown default:
                    break
                }
            }
        }
    }
    
    func presentSomethingWentWrongAlert(error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "SOMETHING_WENT_WRONG".localize(),
                message: error,
                preferredStyle: .alert
            )
            
            let cancelAction = UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }


}

extension LoginWithUidVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleUsers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SampleUserCVCell", for: indexPath) as! SampleUserCVCell
        if selectedUID == indexPath.row{
            cell.didSelect()
        }else{
            cell.didDeselect()
        }
        cell.set(data: sampleUsers[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 115, height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let itemWidth: CGFloat = 115
        let itemCount = CGFloat(sampleUsers.count)
        let totalItemWidth = itemWidth * itemCount
        let totalSpacing = max(0, itemCount - 1) * 0 // minimumInteritemSpacing
        let totalContentWidth = totalItemWidth + totalSpacing
        let collectionViewWidth = collectionView.bounds.width
        
        if totalContentWidth < collectionViewWidth {
            let horizontalInset = (collectionViewWidth - totalContentWidth) / 2
            return UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let reviseSelectedUID = selectedUID
        if selectedUID == indexPath.row{
            selectedUID = -1
            selectedSampleUser = nil
        }else{
            selectedUID = indexPath.row
            selectedSampleUser = sampleUsers[selectedUID]
        }
        collectionView.reloadItems(at: [indexPath, IndexPath(row: reviseSelectedUID, section: 0)])
    }
}


extension LoginWithUidVC {
    
    func fetchUserData() {
        guard let url = URL(string: "https://assets.cometchat.io/sampleapp/sampledata.json") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                self?.presentSomethingWentWrongAlert(error: error.localizedDescription)
                return
            }
            
            guard let data = data else {
                self?.presentSomethingWentWrongAlert(error: "NO_DATA_RECEIVED".localize())
                return
            }
            
            do {
                // Parse the JSON directly as a dictionary
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let users = json["users"] as? [[String: Any]] {
                    
                    // Convert the user data to tuple format
                    let userTuples: [(name: String, uid: String, avatar: String)] = users.compactMap { user in
                        if let name = user["name"] as? String,
                           let uid = user["uid"] as? String,
                           let avatar = user["avatar"] as? String {
                            return (name: name, uid: uid, avatar: avatar)
                        }
                        return nil
                    }
                    
                    self?.sampleUsers = userTuples
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
}

extension LoginWithUidVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

