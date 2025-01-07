//
//  Extensions.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 15/11/24.
//

import UIKit
import CometChatUIKitSwift

extension UIImageView {
    static func downloaded(from url: URL, completion: ((_ image: UIImage?) -> Void)?) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async() {
                    completion?(nil)
                }
                return
            }
            DispatchQueue.main.async() {
                completion?(image)
            }
        }.resume()
    }
}

extension UIViewController {
    public func showAlert(_ title: String, _ message: String, _ cancelText: String, _ confirmText: String, onActionsTriggered: @escaping (() -> ())) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = CometChatTheme.backgroundColor04
        alertController.setValue(NSAttributedString(string: alertController.title ?? "", attributes: [.font : CometChatTypography.Heading4.bold, .foregroundColor : CometChatTheme.textColorPrimary]), forKey: "attributedTitle")
        alertController.setValue(NSAttributedString(string: alertController.message ?? "", attributes: [.font : CometChatTypography.Body.regular, .foregroundColor : CometChatTheme.textColorSecondary]), forKey: "attributedMessage")
        
        if !cancelText.isEmpty {
            let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
        }
        
        if !confirmText.isEmpty {
            let deleteAction = UIAlertAction(title: confirmText, style: .destructive) { _ in
                onActionsTriggered()
            }
            alertController.addAction(deleteAction)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
}

func formatTime(seconds: Double) -> String {
    let totalSeconds = Int(seconds)
    
    if totalSeconds < 60 {
        return "\(totalSeconds)s"
    } else {
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%d:%02d m", minutes, remainingSeconds)
    }
}

public func convertTimeStampToCallDate(timestamp: Double) -> String{
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM, h:mm a"
    formatter.amSymbol = "am"
    formatter.pmSymbol = "pm"

    let formattedDate = formatter.string(from: date)
    return formattedDate
}


extension UIButton {
    func showLoading() {
        self.setTitle("", for: .normal)
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .white
        spinner.startAnimating()
        
        self.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        self.isEnabled = false
    }
    
    func hideLoading(withTitle title: String) {
        self.setTitle(title, for: .normal)
        
        for subview in self.subviews {
            if let spinner = subview as? UIActivityIndicatorView {
                spinner.removeFromSuperview()
            }
        }
        
        self.isEnabled = true
    }
}
