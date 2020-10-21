//
//  CCActivityIndicator.swift
//  CCActivityIndicator


import UIKit
import QuartzCore

@IBDesignable
 final class CCActivityIndicator: UIView {
    /// Specifies the segment animation duration.
     var animationDuration: Double = 0.5
    /// Specifies the indicator rotation animatino duration.
     var rotationDuration: Double = 10
    /// Specifies the number of segments in the indicator.
    
    @IBInspectable
     var numSegments: Int = 12 {
        didSet {
            updateSegments()
        }
    }
    
    /// Specifies the stroke color of the indicator segments.
    @IBInspectable
     var strokeColor : UIColor = .blue {
        didSet {
            segmentLayer?.strokeColor = strokeColor.cgColor
        }
    }
    
    /// Specifies the line width of the indicator segments.
    @IBInspectable
     var lineWidth : CGFloat = 8 {
        didSet {
            segmentLayer?.lineWidth = lineWidth
            updateSegments()
        }
    }
    
    /// A Boolean value that controls whether the receiver is hidden when the animation is stopped.
     var hidesWhenStopped: Bool = true
    
    /// A Boolean value that returns whether the indicator is animating or not.
     private(set) var isAnimating = false
    
    /// the layer replicating the segments.
    private weak var replicatorLayer: CAReplicatorLayer!
    
    /// the visual layer that gets replicated around the indicator.
    private weak var segmentLayer: CAShapeLayer!
    
     override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        // create and add the replicator layer
        let replicatorLayer = CAReplicatorLayer()
        
        layer.addSublayer(replicatorLayer)
        
        // configure the shape layer that gets replicated
        let dot = CAShapeLayer()
        dot.lineCap = CAShapeLayerLineCap.round
        dot.strokeColor = strokeColor.cgColor
        dot.lineWidth = lineWidth
        dot.fillColor = nil
        
        replicatorLayer.addSublayer(dot)
        
        // set the weak variables after being added to the layer
        self.replicatorLayer = replicatorLayer
        self.segmentLayer = dot
    }
    
    override  func layoutSubviews() {
        super.layoutSubviews()
        
        // resize the replicator layer.
        let maxSize = max(0,min(bounds.width, bounds.height))
        replicatorLayer.bounds = CGRect(x: 0, y: 0, width: maxSize, height: maxSize)
        replicatorLayer.position = CGPoint(x: bounds.width/2, y:bounds.height/2)
        
        updateSegments()
    }
    
    /// Updates the visuals of the indicator, specifically the segment characteristics.
    private func updateSegments() {
        guard numSegments > 0, let segmentLayer = segmentLayer else { return }
        
        let angle = 2*CGFloat.pi / CGFloat(numSegments)
        replicatorLayer.instanceCount = numSegments
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
        replicatorLayer.instanceDelay = 1.5*animationDuration/Double(numSegments)
        
        let maxRadius = max(0,min(replicatorLayer.bounds.width, replicatorLayer.bounds.height))/2
        let radius: CGFloat = maxRadius - lineWidth/2
        
        segmentLayer.bounds = CGRect(x:0, y:0, width: 2*maxRadius, height: 2*maxRadius)
        segmentLayer.position = CGPoint(x: replicatorLayer.bounds.width/2, y: replicatorLayer.bounds.height/2)
        
        // set the path of the replicated segment layer.
        let path = UIBezierPath(arcCenter: CGPoint(x: maxRadius, y: maxRadius), radius: radius, startAngle: -angle/2 - CGFloat.pi/2, endAngle: angle/2 - CGFloat.pi/2, clockwise: true)
        
        segmentLayer.path = path.cgPath
    }
    
    /// Starts the animation of the indicator.
     func startAnimating() {
        self.isHidden = false
        isAnimating = true
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.byValue = CGFloat.pi*2
        rotate.duration = rotationDuration
        rotate.repeatCount = Float.infinity
        
        // add animations to segment
        // multiplying duration changes the time of empty or hidden segments
        let shrinkStart = CABasicAnimation(keyPath: "strokeStart")
        shrinkStart.fromValue = 0.0
        shrinkStart.toValue = 0.5
        shrinkStart.duration = animationDuration // * 1.5
        shrinkStart.autoreverses = true
        shrinkStart.repeatCount = Float.infinity
        shrinkStart.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let shrinkEnd = CABasicAnimation(keyPath: "strokeEnd")
        shrinkEnd.fromValue = 1.0
        shrinkEnd.toValue = 0.5
        shrinkEnd.duration = animationDuration // * 1.5
        shrinkEnd.autoreverses = true
        shrinkEnd.repeatCount = Float.infinity
        shrinkEnd.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let fade = CABasicAnimation(keyPath: "lineWidth")
        fade.fromValue = lineWidth
        fade.toValue = 0.0
        fade.duration = animationDuration // * 1.5
        fade.autoreverses = true
        fade.repeatCount = Float.infinity
        fade.timingFunction = CAMediaTimingFunction(controlPoints: 0.55, 0.0, 0.45, 1.0)
        
        replicatorLayer.add(rotate, forKey: "rotate")
        segmentLayer.add(shrinkStart, forKey: "start")
        //segmentLayer.add(shrinkEnd, forKey: "end")
        //segmentLayer.add(fade, forKey: "fade")
    }
    
    /// Stops the animation of the indicator.
     func stopAnimating() {
        isAnimating = false
        
        replicatorLayer.removeAnimation(forKey: "rotate")
        segmentLayer.removeAnimation(forKey: "start")
        //segmentLayer.removeAnimation(forKey: "end")
        //        segmentLayer.removeAnimation(forKey: "fade")
        
        if hidesWhenStopped {
            self.isHidden = true
        }
    }
    
     override var intrinsicContentSize: CGSize {
        return CGSize(width: 180, height: 180)
    }
}
