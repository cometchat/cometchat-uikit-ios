//
//  dummy.swift
//  
//
//  Created by Pushpsen Airekar on 10/02/22.
//

import UIKit

public class dummy: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    
    public override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "dummy", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
   


}
