//
//  UIView+Extensions.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 02/09/24.
//

import UIKit
import ImageIO

public class GIFImageView: UIImageView {
    private var gifData: NSData?
    private var frames: [UIImage] = []
    private var displayLink: CADisplayLink?
    private var currentFrameIndex = 0
    private var isPlaying = false
    private var duration: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    private var lastTimeStamp: TimeInterval = 0
    
    // Load GIF from NSData and apply tint color
    func setGIFData(_ data: NSData, tintColor: UIColor?) {
        self.gifData = data
        self.frames = createFrames(from: data)
        
        // Apply tint color to all frames if provided
        if let tintColor = tintColor {
            self.frames = self.frames.map { image in
                image.withRenderingMode(.alwaysTemplate)
            }
            self.tintColor = tintColor
        }
        
        // Set the first frame as the image
        self.image = frames.last
        self.duration = calculateGIFDuration(data: data)
        
        // Reset animation state
        stopAnimation()
        currentFrameIndex = 0
    }
    
    // Start animation from the current frame
    func startAnimation() {
        guard !isPlaying else { return }
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateFrame))
        displayLink?.add(to: .main, forMode: .common)
        lastTimeStamp = CACurrentMediaTime() - elapsedTime
        isPlaying = true
    }
    
    // Stop animation and retain current frame
    func stopAnimation() {
        guard isPlaying else { return }
        
        displayLink?.invalidate()
        displayLink = nil
        elapsedTime = CACurrentMediaTime() - lastTimeStamp
        isPlaying = false
    }
    
    @objc private func updateFrame() {
        guard isPlaying else { return }
        
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastTimeStamp
        
        elapsedTime += deltaTime
        lastTimeStamp = currentTime
        
        // Calculate current frame based on elapsed time
        let frameIndex = Int((elapsedTime / duration) * Double(frames.count)) % frames.count
        
        if frameIndex != currentFrameIndex {
            currentFrameIndex = frameIndex
            self.image = frames[currentFrameIndex]
        }
    }
    
    // Create frames from GIF data
    private func createFrames(from data: NSData) -> [UIImage] {
        var frames: [UIImage] = []
        guard let source = CGImageSourceCreateWithData(data, nil) else { return frames }
        
        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                frames.append(UIImage(cgImage: cgImage))
            }
        }
        return frames
    }
    
    // Calculate the total duration of the GIF
    private func calculateGIFDuration(data: NSData) -> TimeInterval {
        guard let source = CGImageSourceCreateWithData(data, nil) else { return 0 }
        
        var totalDuration: TimeInterval = 0
        let count = CGImageSourceGetCount(source)
        
        for i in 0..<count {
            let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any]
            let gifProperties = properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
            let frameDuration = gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval
                ?? gifProperties?[kCGImagePropertyGIFDelayTime as String] as? TimeInterval
                ?? 0.1
            totalDuration += frameDuration
        }
        return totalDuration
    }
}
