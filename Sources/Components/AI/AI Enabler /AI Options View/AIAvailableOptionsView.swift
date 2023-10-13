//
//  AIOptionsView.swift
//  
//
//  Created by SuryanshBisen on 12/09/23.
//

import Foundation
import UIKit

public class AIAvailableOptionsView: UIViewController {
    
    private let tableView = UITableView()
    private var optionList = [(String, AIParentRepliesStyle?)]()
    private var onOptionListPressed: ((_ selectedOption: String) -> ())?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        buildUI()
        setUpDelegate()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: false)
        }
    }
    
    @discardableResult
    public func set(optionList: [(String, AIParentRepliesStyle?)]) -> Self{
        self.optionList = optionList
        return self
    }
    
    @discardableResult
    public func buildFrom(enablerStyle: AIEnableStyle?) -> Self {
        
        if let backgroundColour = enablerStyle?.bottomSheetBackgroundColour {
            self.setBackgroundColour(colour: backgroundColour)
        }
        
        return self
    }
    
    @discardableResult
    @objc public func onOptionSelected(onOptionSelected: @escaping ((_ selectedOption: String) -> ())) -> Self {
        self.onOptionListPressed = onOptionSelected
        return self
    }
    
    @discardableResult
    @objc public func setBackgroundColour(colour: UIColor) -> Self {
        self.view.backgroundColor = colour
        return self
    }
    
    private func setUpDelegate() {
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "AIRepliesCell", bundle: CometChatUIKit.bundle)
        tableView.register(nib, forCellReuseIdentifier: "AIRepliesCell")
    }
    
    private func buildUI() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.isUserInteractionEnabled = true
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
    }
    
    
    func buildCellFromConfiguration(cell: AIRepliesCell, configuration: AIParentRepliesStyle) {
        
        guard let configuration = configuration as? AISmartRepliesStyle else { return }
        
        if let font = configuration.buttonTextFont {
            cell.set(textFont: font)
        }
        
        if let textColor = configuration.buttonTextColor {
            cell.set(titleColor: textColor)
        }
        
        if let border = configuration.buttonBorder {
            cell.set(buttonBorder: border)
        }
        
        if let textBackground = configuration.buttonBackground {
            cell.set(background: textBackground)
        }
        
        if let borderRadius = configuration.buttonBorder {
            cell.set(buttonBorder: borderRadius)
        }

    }
}

//MARK: TABEL VIEW
extension AIAvailableOptionsView: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AIRepliesCell") as? AIRepliesCell {
            
            let dataForCell = optionList[indexPath.row]
            
            cell.set(title: dataForCell.0)
            
            if let configuration = dataForCell.1 {
                buildCellFromConfiguration(cell: cell, configuration: configuration)
            }
            
            cell.set { title in
                self.onOptionListPressed?(title)
            }
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }

}

//MARK: PANMODAL
extension AIAvailableOptionsView: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return tableView
    }
    
    var shortFormHeight: PanModalHeight {
        let height = (optionList.count) * 65 + 80
        return .contentHeight(CGFloat(height))
    }
    
}
