//
//  CallDuration.swift
//  
//
//  Created by Ajay Verma on 07/03/23.
//

import Foundation
import CometChatSDK
import UIKit

public class CallDuration: UIView {
    
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var tableViewHeightContraint: NSLayoutConstraint!
    
    private var viewModel: CallDurationViewModel?
    // MARK: - Initialization of required Methods
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    //MARK: - INIT
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = self.bounds
            self.addSubview(contentView)
        }
        registerCell()
        tableViewHeightContraint.constant =  500
    }
    
    public override func layoutSubviews() {
        self.viewModel?.fetchCalls(completion: {
            print("")
        })
        
        self.calculateHeight()
    }
    
    public func set(user: User) {
        viewModel = CallDurationViewModel()
        viewModel?.user = user
    }
    
    public func set(group: Group) {
        viewModel = CallDurationViewModel()
        viewModel?.group = group
    }
    
    private func registerCell() {
        let nib = UINib(nibName: "CallDetailItem", bundle: CometChatUIKit.bundle)
        tableview.register(nib, forCellReuseIdentifier: "CallDetailItem")
        tableview.separatorStyle = .none
    }
    
    func calculateHeight() {
        viewModel?.updateTableViewHeight = {
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                this.tableview.reloadData()
                this.reloadInputViews()
            }
        }
    }
    
    func reloadData() {
        viewModel?.reload = {
            DispatchQueue.main.async() { [weak self] in
                self?.tableview.reloadData()
            }
        }
        
        viewModel?.failure = { [weak self] error in
            DispatchQueue.main.async {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.open {}
            }
        }
    }
    
}

//Currently not showing the details of a call
//====================================================
extension CallDuration: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 0  //viewModel?.groupedCalls.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.groupedCalls[section].count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CallDetailItem", for: indexPath) as? CallDetailItem else { return UITableViewCell() }
        cell.selectionStyle = .none
        guard let section = indexPath.section as? Int else { return UITableViewCell() }
        
        cell.time.set(pattern: .time)
        if let call = viewModel?.groupedCalls[safe: section]?[safe: indexPath.row] as? Call {
           cell.time.set(timestamp: Int(call.initiatedAt))
           cell.callStatus.text = CallUtils().setupCallDetail(call: call)
        }
        
        if let call = viewModel?.groupedCalls[safe: section]?[safe: indexPath.row] as? CustomMessage {
            cell.time.set(timestamp: Int(call.sentAt))
            cell.callStatus.text = "Conference call".localize()
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = CometChatDate()
        title.set(pattern: .dayDate)
        if let call =  viewModel?.groupedCalls[safe: section]?[0] as? Call {
            return title.set(timestamp: Int(call.initiatedAt)).text
        }
        
        if let call = viewModel?.groupedCalls[safe: section]?[0] as? CustomMessage {
            return title.set(timestamp: Int(call.sentAt)).text
        }

        return ""
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius = 10
        var corners: UIRectCorner = []
        
        if indexPath.row == 0 {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }
}


