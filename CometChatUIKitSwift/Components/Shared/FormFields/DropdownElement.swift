//
//  DropdownElement.swift
//  
//
//  Created by Abhishek Saralaya on 15/09/23.
//

import Foundation
import UIKit

@objc public class DropdownElement: ElementEntity {
    @objc public var optional = false
    @objc public var label = ""
    @objc public var defaultValue = ""
    public var options = [OptionElement]()
    var selectedValue = ""
    
    public override init() {
        super.init()
        self.elementType = .dropdown
    }
    
    @objc public static func dropdownElementFromJSON(_ data:[String:Any])-> DropdownElement? {
        let dropdownElement = DropdownElement()
        dropdownElement.elementType = (data[InteractiveConstants.ELEMENT_TYPE] as? String)?.stringValueToElementType
        if let id = data[InteractiveConstants.ELEMENT_ID] as? String {
            dropdownElement.elementId = id
        }
        if let text = data[InteractiveConstants.DropDownUIConstants.LABEL] as? String {
            dropdownElement.label =  text
        }
        if let defaultValue = data[InteractiveConstants.DropDownUIConstants.DEFAULT_VALUE] as? String {
            dropdownElement.defaultValue = defaultValue
        }
        if let optional = data[InteractiveConstants.DropDownUIConstants.OPTIONAL] as? Bool {
            dropdownElement.optional = optional
        }
        if let options = data[InteractiveConstants.DropDownUIConstants.OPTIONS] as? [[String:Any]] {
            for option in options {
                if let id = option[InteractiveConstants.DropDownUIConstants.LABEL] as? String, let value = option[InteractiveConstants.DropDownUIConstants.OPTION_VALUE] as? String {
                    let optionElement = OptionElement()
                    optionElement.id = id
                    optionElement.value = value
                    dropdownElement.options.append(optionElement)
                }
            }
        }
        return dropdownElement
    }
    
    
    
    public func toJSON() -> [String: Any] {
        var jsonRepresentation = [String: Any]()
            jsonRepresentation[InteractiveConstants.ELEMENT_TYPE] = "dropdown"
        jsonRepresentation[InteractiveConstants.ELEMENT_ID] = self.elementId
        jsonRepresentation[InteractiveConstants.DropDownUIConstants.LABEL] = self.label
        jsonRepresentation[InteractiveConstants.DropDownUIConstants.OPTIONAL] = self.optional
        jsonRepresentation[InteractiveConstants.DropDownUIConstants.DEFAULT_VALUE] = self.defaultValue
        
        if self.options.count > 0 {
            var arrOption = [[String:Any]]()
            for option in self.options {
                var optionDict = [String:Any]()
                optionDict[InteractiveConstants.DropDownUIConstants.LABEL] = option.id
                optionDict[InteractiveConstants.DropDownUIConstants.OPTION_VALUE] = option.value
                arrOption.append(optionDict)
            }
            jsonRepresentation[InteractiveConstants.DropDownUIConstants.OPTIONS] = arrOption
        }
        return jsonRepresentation
    }
    
    
    class DropdownButtonView: UIView, UITableViewDataSource, UITableViewDelegate {
        var parentDropdownElement: DropdownElement?
        private let titleLabel: UILabel
        private var value = "" {
            didSet {
                if let parentDropdownElement = parentDropdownElement {
                    parentDropdownElement.selectedValue = value
                }
            }
        }
        private let arrowImageView: UIImageView = UIImageView(image: UIImage(systemName: "arrowtriangle.down"))
        private var isDropdownOpen: Bool = false
        var parentContainerView: UIStackView?
        var style: FormBubbleStyle = FormBubbleStyle()

        // Options to display in the dropdown
        private var options: [OptionElement] = [] {
            didSet {
                tableView.reloadData()
            }
        }

        private let tableView: UITableView = {
            let tableView = UITableView()
            tableView.isHidden = true
            return tableView
        }()

        override init(frame: CGRect) {
            titleLabel = UILabel()
            super.init(frame: frame)

            setupUI()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupUI() {
            // Add the title label
            titleLabel.frame = CGRect(x: 5, y: 0, width: frame.width - 100, height: 30)
            titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            addSubview(titleLabel)
//            titleLabel.backgroundColor = .blue

            // Add the arrow image view
//            arrowImageView.frame = CGRect(x: frame.width - 74, y: 5, width: 30, height: 20)
            addSubview(arrowImageView)
            arrowImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([self.arrowImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
                                             self.arrowImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                             self.arrowImageView.widthAnchor.constraint(equalToConstant: 30),
                                             self.arrowImageView.heightAnchor.constraint(equalToConstant: 30)])
//                self.layoutIfNeeded()
//            })
            arrowImageView.tintColor = style.borderColor
            
            // Configure the arrow image view to respond to taps
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(arrowTapped))
            arrowImageView.isUserInteractionEnabled = true
            self.addGestureRecognizer(tapGesture)

            // Configure the table view
            tableView.frame = CGRect(x:0, y: frame.height, width: frame.width - 46, height: CGFloat(self.options.count) * 44)
            tableView.borderWith(width: 0.5)
            tableView.borderColor(color: style.borderColor)
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isUserInteractionEnabled = true
            addSubview(tableView)
        }

        @objc private func arrowTapped() {
            isDropdownOpen.toggle()
            tableView.isHidden = !isDropdownOpen
            if isDropdownOpen {
                if let views = parentContainerView?.arrangedSubviews {
                    for view1 in views {
                        parentContainerView?.insertSubview(self, aboveSubview: view1)
                        for gestureRecognizer in view1.gestureRecognizers ?? [] {
                            if gestureRecognizer is UITapGestureRecognizer {
                                let tapRecognizer = gestureRecognizer as! UITapGestureRecognizer
                                // Access properties of the UITapGestureRecognizer
                                tapRecognizer.isEnabled = false  // To disable

                            }
                            // Handle other gesture recognizer types here
                        }
                        
                    }
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self.tableView.frame.size.height = CGFloat(self.options.count) * 44 // Adjust height based on the number of options
                })
            } else {
//                tableView.frame.size.height = 0
                if let views = parentContainerView?.arrangedSubviews {
                    for view1 in views {
                        for gestureRecognizer in view1.gestureRecognizers ?? [] {
                            if gestureRecognizer is UITapGestureRecognizer {
                                let tapRecognizer = gestureRecognizer as! UITapGestureRecognizer
                                // Access properties of the UITapGestureRecognizer
                                tapRecognizer.isEnabled = true  // To disable

                            }
                        }
                        
                    }
                }
            }
        }

        func setOptions(_ options: [OptionElement]) {
            self.options = options
            
            if let parentDropdownElement = parentDropdownElement, !parentDropdownElement.defaultValue.isEmpty {
                value = options.first(where: {$0.value == parentDropdownElement.defaultValue})?.value ?? ""
                titleLabel.text = options.first(where: {$0.value == parentDropdownElement.defaultValue})?.id
            } else {
                value = options.first?.value ?? ""
                titleLabel.text = options.first?.id
            }
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return options.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = options[indexPath.row].id
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            titleLabel.text = options[indexPath.row].id
            value = options[indexPath.row].value
            arrowTapped()
        }
        
        public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            if !tableView.isHidden {
                let extendedFrame = bounds.insetBy(dx: -frame.width, dy: -CGFloat(self.options.count) * 44) // Expand hit area
                return extendedFrame.contains(point)
            } else {
                let extendedFrame = bounds.insetBy(dx: 0, dy: 0) // Expand hit area
                return extendedFrame.contains(point)
            }
        }
    }
}
