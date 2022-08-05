//
//  Gradient.swift
//  room-vr-ai
//
//  Created by Pushpsen Airekar on 15/07/21.
//

import Foundation
import UIKit

extension UIView {
    
        func addGradient(with layer: CAGradientLayer, gradientFrame: CGRect? = nil, colorSet: [UIColor],
                         locations: [Double], startEndPoints: (CGPoint, CGPoint)? = nil) {
            layer.frame = gradientFrame ?? self.bounds
            layer.frame.origin = .zero

            let layerColorSet = colorSet.map { $0.cgColor }
            let layerLocations = locations.map { $0 as NSNumber }

            layer.colors = layerColorSet
            layer.locations = layerLocations

            if let startEndPoints = startEndPoints {
                layer.startPoint = startEndPoints.0
                layer.endPoint = startEndPoints.1
            }

            self.layer.insertSublayer(layer, above: self.layer)
        }
    
    @discardableResult
    func addGradientView(withColors:[CGColor],locations:[NSNumber]) -> UIView  {
        //Create customGradientView with exact dimension of parent, add it with centering with parent
        let customGradientView = UIView()
        customGradientView.backgroundColor = UIColor.clear
        customGradientView.frame = self.bounds
        self.addSubview(customGradientView)
        customGradientView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        customGradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.clipsToBounds = true

        //Create layer add it to customGradientView
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .conic //Circular
        gradientLayer.opacity = 0.8
        gradientLayer.colors = withColors
        gradientLayer.locations = locations
        gradientLayer.frame = customGradientView.bounds
        
        //Set start point as center and radius as 1, co-ordinate system maps 0 to 1, 0,0 top left, bottom right 1,1
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        let radius = 1.0
        gradientLayer.endPoint = CGPoint(x: radius, y: radius)
              
        //Add layer at top to make sure its visible
        let layerCount:UInt32 = UInt32(customGradientView.layer.sublayers?.count ?? 0)
        customGradientView.layer.insertSublayer(gradientLayer, at: layerCount)
        customGradientView.layoutIfNeeded()
        
        //Use reference to show/hide add/remove gradient view
        return customGradientView
    }
    
    
    @discardableResult
    func addAxicalGradientView(withColors:[CGColor],locations:[NSNumber]) -> UIView  {
        //Create customGradientView with exact dimension of parent, add it with centering with parent
        let customGradientView = UIView()
        customGradientView.backgroundColor = UIColor.clear
        customGradientView.frame = self.bounds
        self.addSubview(customGradientView)
        customGradientView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        customGradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.clipsToBounds = true

        //Create layer add it to customGradientView
        let gradientLayer = CAGradientLayer()
        gradientLayer.type =  .axial
        gradientLayer.opacity = 0.8
        gradientLayer.colors = withColors
        gradientLayer.locations = locations
        gradientLayer.frame = customGradientView.bounds
        
        //Set start point as center and radius as 1, co-ordinate system maps 0 to 1, 0,0 top left, bottom right 1,1
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        let radius = 1.0
        gradientLayer.endPoint = CGPoint(x: radius, y: radius)
              
        //Add layer at top to make sure its visible
        let layerCount:UInt32 = UInt32(customGradientView.layer.sublayers?.count ?? 0)
        customGradientView.layer.insertSublayer(gradientLayer, at: layerCount)
        customGradientView.layoutIfNeeded()
        
        //Use reference to show/hide add/remove gradient view
        return customGradientView
    }

}


