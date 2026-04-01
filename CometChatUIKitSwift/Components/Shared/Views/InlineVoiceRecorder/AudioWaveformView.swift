//
//  AudioWaveformView.swift
//  CometChatUIKitSwift
//
//  Created on 05/02/26.
//

import UIKit

/// A view that displays audio waveform visualization with animated bars
public class AudioWaveformView: UIView {
    
    // MARK: - Properties
    
    /// Color for inactive/unplayed bars
    public var barColor: UIColor = CometChatTheme.borderColorDefault {
        didSet { setNeedsDisplay() }
    }
    
    /// Color for active/played bars
    public var activeBarColor: UIColor = CometChatTheme.primaryColor {
        didSet { setNeedsDisplay() }
    }
    
    /// Width of each bar
    public var barWidth: CGFloat = 3 {
        didSet { setNeedsDisplay() }
    }
    
    /// Spacing between bars
    public var barSpacing: CGFloat = 2 {
        didSet { setNeedsDisplay() }
    }
    
    /// Corner radius of each bar
    public var barCornerRadius: CGFloat = 1.5 {
        didSet { setNeedsDisplay() }
    }
    
    /// Minimum bar height as a fraction of view height
    public var minBarHeightRatio: CGFloat = 0.15 {
        didSet { setNeedsDisplay() }
    }
    
    /// Maximum bar height as a fraction of view height
    public var maxBarHeightRatio: CGFloat = 1.0 {
        didSet { setNeedsDisplay() }
    }
    
    /// Callback when user seeks to a new position (progress 0.0 to 1.0)
    public var onSeek: ((Float) -> Void)?
    
    /// Number of bars to display
    private var maxBars: Int {
        let totalBarWidth = barWidth + barSpacing
        return max(1, Int(bounds.width / totalBarWidth))
    }
    
    /// Stored amplitude values (0.0 to 1.0)
    private var amplitudes: [Float] = []
    
    /// Current playback progress (0.0 to 1.0)
    private var playbackProgress: Float = 0
    
    /// Whether we're in playback mode (showing stored amplitudes)
    private var isPlaybackMode: Bool = false
    
    /// Whether seeking is enabled (only in playback mode)
    private var isSeekingEnabled: Bool = true
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        clipsToBounds = true
        
        // Add pan gesture for seeking
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        addGestureRecognizer(panGesture)
        
        // Add tap gesture for seeking to a specific position
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 32)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Redraw when bounds change
        setNeedsDisplay()
    }
    
    // MARK: - Gesture Handling
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard isPlaybackMode && isSeekingEnabled else { return }
        
        let location = gesture.location(in: self)
        let progress = Float(location.x / bounds.width).clamped(to: 0...1)
        
        switch gesture.state {
        case .began, .changed:
            // Update visual progress immediately for responsive feedback
            playbackProgress = progress
            setNeedsDisplay()
            
        case .ended, .cancelled:
            // Notify delegate of final seek position
            onSeek?(progress)
            
        default:
            break
        }
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard isPlaybackMode && isSeekingEnabled else { return }
        
        let location = gesture.location(in: self)
        let progress = Float(location.x / bounds.width).clamped(to: 0...1)
        
        // Update visual progress and notify
        playbackProgress = progress
        setNeedsDisplay()
        onSeek?(progress)
    }
    
    // MARK: - Drawing
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let viewHeight = bounds.height
        let viewWidth = bounds.width
        
        // Don't draw if view has no size
        guard viewWidth > 0 && viewHeight > 0 else { return }
        
        let totalBarWidth = barWidth + barSpacing
        let barsToShow = maxBars
        
        // Get amplitudes to display
        let displayAmplitudes = getDisplayAmplitudes(count: barsToShow)
        
        // Always start from the left
        let startX: CGFloat = 0
        
        // Draw each bar
        for (index, amplitude) in displayAmplitudes.enumerated() {
            let x = startX + CGFloat(index) * totalBarWidth
            
            // Skip bars that would be drawn outside the view
            guard x < viewWidth else { break }
            
            // Calculate bar height based on amplitude
            let minHeight = viewHeight * minBarHeightRatio
            let maxHeight = viewHeight * maxBarHeightRatio
            let barHeight = minHeight + CGFloat(amplitude) * (maxHeight - minHeight)
            
            // Center bar vertically
            let y = (viewHeight - barHeight) / 2
            
            // Create bar rect
            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: barCornerRadius)
            
            // Determine bar color based on playback progress
            let barProgress = Float(index) / Float(max(1, displayAmplitudes.count - 1))
            let color: UIColor
            
            if isPlaybackMode && barProgress <= playbackProgress {
                color = activeBarColor
            } else if !isPlaybackMode {
                color = activeBarColor
            } else {
                color = barColor
            }
            
            context.setFillColor(color.cgColor)
            context.addPath(barPath.cgPath)
            context.fillPath()
        }
    }
    
    private func getDisplayAmplitudes(count: Int) -> [Float] {
        // During recording, just return the actual amplitudes (growing from left)
        // During playback, fit all amplitudes to the view width
        
        if !isPlaybackMode {
            // Recording mode: show actual amplitudes, limited to view width
            if amplitudes.count <= count {
                return amplitudes
            }
            // If we have more amplitudes than can fit, show the most recent ones
            return Array(amplitudes.suffix(count))
        }
        
        // Playback mode: fit all amplitudes to view
        guard !amplitudes.isEmpty else {
            return []
        }
        
        if amplitudes.count <= count {
            return amplitudes
        }
        
        // Downsample amplitudes to fit the view
        var result: [Float] = []
        let step = Float(amplitudes.count) / Float(count)
        
        for i in 0..<count {
            let index = Int(Float(i) * step)
            if index < amplitudes.count {
                result.append(amplitudes[index])
            }
        }
        
        return result
    }
    
    // MARK: - Public API
    
    /// Add a new amplitude value during recording
    public func addAmplitude(_ amplitude: Float) {
        // Amplify for better visual response
        let visualAmplitude = amplifyAmplitude(amplitude)
        amplitudes.append(visualAmplitude)
        
        setNeedsDisplay()
    }
    
    /// Set all amplitudes at once (for playback)
    public func setAmplitudes(_ amplitudes: [Float]) {
        self.amplitudes = amplitudes.map { amplifyAmplitude($0) }
        setNeedsDisplay()
    }
    
    /// Set playback progress (0.0 to 1.0)
    public func setPlaybackProgress(_ progress: Float) {
        playbackProgress = progress.clamped(to: 0...1)
        setNeedsDisplay()
    }
    
    /// Set whether we're in playback mode
    public func setPlaybackMode(_ isPlayback: Bool) {
        isPlaybackMode = isPlayback
        setNeedsDisplay()
    }
    
    /// Enable or disable seeking
    public func setSeekingEnabled(_ enabled: Bool) {
        isSeekingEnabled = enabled
    }
    
    /// Reset the waveform
    public func reset() {
        amplitudes = []
        playbackProgress = 0
        isPlaybackMode = false
        setNeedsDisplay()
    }
    
    // MARK: - Helpers
    
    private func amplifyAmplitude(_ amplitude: Float) -> Float {
        // Amplify for better visual response
        let visualAmplitude: Float
        if amplitude < 0.1 {
            visualAmplitude = 0.15 + amplitude * 2.0
        } else if amplitude < 0.4 {
            visualAmplitude = 0.35 + (amplitude - 0.1) * 1.17
        } else {
            visualAmplitude = 0.7 + (amplitude - 0.4) * 0.5
        }
        return visualAmplitude.clamped(to: 0.15...1.0)
    }
}

// MARK: - Float Extension

extension Float {
    func clamped(to range: ClosedRange<Float>) -> Float {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
