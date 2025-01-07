//
//  asdfsadf.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 15/09/24.
//

import UIKit
import Foundation

public class DownloadableCircularProgressBar: CircularProgressBar {
    
    public var downloadImage = UIImage(named: "download", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate) {
        didSet {
            downloadImageView.image = downloadImage
        }
    }
    private var onDownloadClicked: (() -> ())?
    
    lazy public var downloadImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleToFill
        imageView.pin(anchors: [.height, .width], to: frame.height)
        imageView.image = downloadImage
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpDownloadIcon()
    }
    
    @objc func onClick() {
        downloadImageView.removeFromSuperview()
        configureProgressViewToBeCircular()
        onDownloadClicked?()
    }
    
    func setUpDownloadIcon() {
        addSubview(downloadImageView)
        downloadImageView.pin(anchors: [.centerX, .centerY], to: self)
        downloadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClick)))
    }
    
    @discardableResult
    public func on(downloadClicked: @escaping (() -> ())) -> Self {
        self.onDownloadClicked = downloadClicked
        return self
    }
    
    override func onCancelImageClicked() {
        super.onCancelImageClicked()
        setUpDownloadIcon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

import QuartzCore
public class CircularProgressBar: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var tracklayer = CAShapeLayer()
    private var crossLayer = CAShapeLayer()
    private var tapCallback: (() -> Void)?
    
    public var cancelImage = UIImage(systemName: "multiply")?.withRenderingMode(.alwaysTemplate) {
        didSet {
            cancelImageView.image = cancelImage
        }
    }
    private var onCancelClicked: (() -> ())?
    private lazy var cancelButtonGesture = UITapGestureRecognizer(target: self, action: #selector(onCancelImageClicked))
    private var observedTask: URLSessionDownloadTask?

    
    lazy public var cancelImageView: UIImageView = {
        let imageView = UIImageView().withoutAutoresizingMaskConstraints()
        imageView.image = cancelImage
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTapGestureRecognizer()
    }
    
    @discardableResult
    public func on(cancelClicked: @escaping (() -> ())) -> Self {
        self.onCancelClicked = cancelClicked
        return self
    }
    
    var setProgressColor: UIColor = UIColor.red {
        didSet {
            progressLayer.strokeColor = setProgressColor.cgColor
        }
    }
    
    var setTrackColor: UIColor = UIColor.white {
        didSet {
            tracklayer.strokeColor = setTrackColor.cgColor
        }
    }
    
    private var viewCGPath: CGPath? {
        return UIBezierPath(
            arcCenter: CGPoint(
                x: frame.size.width / 2.0,
                y: frame.size.height / 2.0
            ),
            radius: (frame.size.width - 1.5) / 2,
            startAngle: CGFloat(-0.5 * Double.pi),
            endAngle: CGFloat(1.5 * Double.pi), clockwise: true).cgPath
    }
    
    func configureProgressViewToBeCircular() {
        setupCancelImage()
        self.drawsView(using: tracklayer, startingPoint: 2.2, ending: 1.0)
        self.drawsView(using: progressLayer, startingPoint: 2.2, ending: 0.0)
    }
    
    private func setupCancelImage() {
        cancelImageView.pin(anchors: [.height, .width], to: frame.height/1.9)
        addSubview(cancelImageView)
        cancelImageView.pin(anchors: [.centerX, .centerY], to: self)
        self.addGestureRecognizer(cancelButtonGesture)
    }
    
    @objc func onCancelImageClicked() {
        tracklayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        cancelImageView.removeFromSuperview()
        self.removeGestureRecognizer(cancelButtonGesture)
        observedTask?.progress.removeObserver(self, forKeyPath: "fractionCompleted")
        onCancelClicked?()
    }
    
    private func drawsView(using shape: CAShapeLayer, startingPoint: CGFloat, ending: CGFloat) {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width / 2.0
        
        shape.path = self.viewCGPath
        shape.fillColor = UIColor.clear.cgColor // Make sure the fill is transparent
        shape.lineWidth = startingPoint
        shape.strokeEnd = ending
        
        // Ensure the progressLayer is drawn above the trackLayer
        if shape == tracklayer {
            shape.strokeColor = setTrackColor.cgColor
            self.layer.insertSublayer(shape, at: 0) // Ensure track layer is at the bottom
        } else if shape == progressLayer {
            shape.strokeColor = setProgressColor.cgColor
            self.layer.insertSublayer(shape, above: tracklayer) // Ensure progress layer is above
        }
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        // Check the presentation layer for the current animated strokeEnd value
        let currentStrokeEnd: CGFloat = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd

        // Remove previous animation
        progressLayer.removeAnimation(forKey: "animateCircle")

        // Create the animation, starting from the current strokeEnd
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = currentStrokeEnd // Start from the current animated value
        animation.toValue = value // Animate to the new value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        // Update the final strokeEnd value
        progressLayer.strokeEnd = CGFloat(value)

        // Add the animation
        progressLayer.add(animation, forKey: "animateCircle")
    }
    
    // Monitor download progress using URLSessionTask
    public func observeDownloadProgress(for task: URLSessionDownloadTask) {
        observedTask = task
        task.progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
    }
    
    // Observe progress and update circular progress
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "fractionCompleted", let progress = object as? Progress {
            DispatchQueue.main.async {
                self.setProgressWithAnimation(duration: 0.3, value: Float(progress.fractionCompleted))
            }
        }
    }
    
    // Add a tap gesture to trigger callback
    private func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        tapCallback?()
    }
    
    // Function to set callback from outside
    public func setTapCallback(callback: @escaping () -> Void) {
        self.tapCallback = callback
    }
}
