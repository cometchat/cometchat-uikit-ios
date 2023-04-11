//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 21/11/22.
//

import UIKit

public extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
    
}


extension UIView {

    
//    func loadFromNib() {
//        let name = String(describing: type(of: self))
//        let bundle = Bundle(for: type(of: self))
//        guard let view = bundle.loadNibNamed(name, owner: self, options: nil)?.first as? UIView else {
//            fatalError("Nib not found.")
//        }
//        addSubview(view)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        layoutAttachViewToSuperview(view: view)
//    }

    func layoutAttachViewToSuperview(view: UIView) {
        let views = ["view" : view]
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: views)
        addConstraints(horizontalConstraints + verticalConstraints)
    }

}

extension UIView {
    func bindFrameToSuperviewBoundsWithConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superview!.topAnchor),
            bottomAnchor.constraint(equalTo: superview!.bottomAnchor),
            leadingAnchor.constraint(equalTo: superview!.leadingAnchor),
            trailingAnchor.constraint(equalTo: superview!.trailingAnchor)
        ])
    }

    func bindFrameToSuperviewBoundsWithAutoResizingMask() {
        translatesAutoresizingMaskIntoConstraints = true
        frame = superview!.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
 
