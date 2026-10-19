//
//  CameraButton.swift
//
//  Copyright (c) 2020 Ramiz Kichibekov (https://www.instagram.com/kichibekov69)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

open class CameraButton: UIButton {
    
    /// Visual style of the button.
    public enum Style: Sendable {
        /// Stroked ring with a filled inner shape.
        case classic
        /// Liquid Glass disc on iOS 26 and later. Falls back to `classic` on earlier systems.
        case glass
    }
    
    // MARK: Style
    
    public var style: Style = .classic {
        didSet {
            guard oldValue != style else { return }
            
            updateStyle()
        }
    }
    
    /// Tint of the Liquid Glass disc. Applies to the `glass` style only.
    public var glassTintColor: UIColor? {
        didSet {
            guard oldValue != glassTintColor else { return }
            
            updateStyle()
        }
    }
    
    /// Plays haptic feedback on capture and on start/stop of recording.
    public var isHapticFeedbackEnabled = true
    
    // MARK: Colors

    public var photoColor: UIColor = .clear {
        didSet {
            guard oldValue != photoColor else { return }
            
            updateFillColor(configureColor(), animated: false)
        }
    }

    public var videoColor: UIColor = .clear {
        didSet {
            guard oldValue != videoColor else { return }
            
            updateFillColor(configureColor(), animated: false)
        }
    }
    
    // MARK: Ring

    public var ringOffset: CGFloat = 3 {
        didSet {
            guard oldValue != ringOffset else { return }
            
            updateRing()
        }
    }

    public var ringLineWidth: CGFloat = 4 {
        didSet {
            guard oldValue != ringLineWidth else { return }
            
            updateRing()
        }
    }

    public var ringColor: UIColor = .white {
        didSet {
            guard oldValue != ringColor else { return }
            
            setNeedsDisplay()
        }
    }
    
    // MARK: Recording progress
    
    public var progressColor: UIColor = .systemRed {
        didSet {
            guard oldValue != progressColor else { return }
            
            updateProgressColor()
        }
    }
    
    /// Progress of the recording ring, from 0 to 1. Resets when recording stops.
    public var recordingProgress: CGFloat {
        get { progressLayer.strokeEnd }
        set {
            progressLayer.removeAnimation(forKey: "strokeEnd")
            CATransaction.performWithoutAnimation {
                progressLayer.strokeEnd = min(max(newValue, 0), 1)
            }
        }
    }
    
    // MARK: Inner large circle

    public var innerLargeCircleOffset: CGFloat = 8 {
        didSet {
            guard oldValue != innerLargeCircleOffset else { return }
            
            updateInnerPath(animated: false)
        }
    }
    
    // MARK: Inner small circle

    public var innerSmallCircleOffset: CGFloat = 13 {
        didSet {
            guard oldValue != innerSmallCircleOffset else { return }
            
            updateInnerPath(animated: false)
        }
    }
    
    // MARK: Inner square

    public var innerSquare: CGFloat = 17 {
        didSet {
            guard oldValue != innerSquare else { return }
            
            updateInnerPath(animated: false)
        }
    }

    public var squareCornerRadius: CGFloat = 8 {
        didSet {
            guard oldValue != squareCornerRadius else { return }
            
            updateInnerPath(animated: false)
        }
    }
    
    // MARK: Properties
    
    override open var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            
            updateInnerPath(animated: true)
            updateAccessibility()
            if !isSelected {
                recordingProgress = 0
            }
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        CGSize(width: 60, height: 60)
    }
    
    // MARK: Public properties
    
    public var type: CameraType = .photo {
        didSet {
            pathLayer.removeAllAnimations()
            isSelected = false
            updateFillColor(configureColor(), animated: false)
            updateAccessibility()
        }
    }
    public weak var delegate: CameraButtonDelegate?

    // MARK: Private properties
    
    private let pathLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private var glassView: UIView?
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let animateDuration = CATransaction.animationDuration()
    private let shutterDuration: CFTimeInterval = 0.3
    private var lastLayoutSize: CGSize = .zero
    private var customAccessibilityLabel: String?
    
    // MARK: Accessibility
    
    override open var accessibilityLabel: String? {
        get {
            if let customAccessibilityLabel { return customAccessibilityLabel }
            
            switch type {
            case .photo: return "Take Photo"
            case .video: return isSelected ? "Stop Recording" : "Record Video"
            }
        }
        set {
            customAccessibilityLabel = newValue
        }
    }
    
    // MARK: Life cycle

    public init() {
        super.init(frame: .zero)
        
        configureButton()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        configureButton()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureButton()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.size != lastLayoutSize else { return }
        
        lastLayoutSize = bounds.size
        pathLayer.removeAllAnimations()
        CATransaction.performWithoutAnimation {
            pathLayer.frame = bounds
            progressLayer.frame = bounds
            progressLayer.path = progressPath().cgPath
        }
        glassView?.frame = bounds
        glassView?.layer.cornerRadius = min(bounds.width, bounds.height) / 2
        updateInnerPath(animated: false)
        setNeedsDisplay()
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard !isGlassActive else { return }
        
        let ringRect = bounds.insetBy(dx: ringOffset, dy: ringOffset)
        let outerRing = UIBezierPath(ovalIn: ringRect)
        outerRing.lineWidth = ringLineWidth
        ringColor.setStroke()
        outerRing.stroke()
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        
        updateFillColor(configureColor(), animated: false)
        updateProgressColor()
        setNeedsDisplay()
    }
    
    // MARK: Public methods
    
    /// Animates the recording ring from its current value to full over `duration` seconds.
    public func animateRecordingProgress(duration: TimeInterval) {
        let fill = CABasicAnimation(keyPath: "strokeEnd")
        fill.fromValue = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
        fill.toValue = 1
        fill.duration = duration
        fill.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.add(fill, forKey: "strokeEnd")
        CATransaction.performWithoutAnimation {
            progressLayer.strokeEnd = 1
        }
    }

    // MARK: Private methods
    
    private func configureLayer() {
        pathLayer.removeAllAnimations()
        pathLayer.strokeColor = nil
        if pathLayer.superlayer == nil {
            layer.addSublayer(pathLayer)
        }
        progressLayer.fillColor = nil
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        if progressLayer.superlayer == nil {
            layer.addSublayer(progressLayer)
        }
        updateProgressColor()
        updateFillColor(configureColor(), animated: false)
        updateInnerPath(animated: false)
    }
    
    private var isGlassActive: Bool {
        glassView != nil
    }
    
    private func updateStyle() {
        glassView?.removeFromSuperview()
        glassView = makeGlassView()
        if let glassView {
            glassView.frame = bounds
            glassView.layer.cornerRadius = min(bounds.width, bounds.height) / 2
            insertSubview(glassView, at: 0)
            layer.insertSublayer(pathLayer, above: glassView.layer)
            layer.insertSublayer(progressLayer, above: pathLayer)
        }
        updateFillColor(configureColor(), animated: false)
        updateRing()
    }
    
    private func makeGlassView() -> UIView? {
        guard style == .glass else { return nil }
        
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect()
            effect.tintColor = glassTintColor
            let effectView = UIVisualEffectView(effect: effect)
            effectView.isUserInteractionEnabled = false
            effectView.clipsToBounds = true
            
            return effectView
        }
        #endif
        
        return nil
    }
    
    private func updateRing() {
        updateProgressColor()
        CATransaction.performWithoutAnimation {
            progressLayer.path = progressPath().cgPath
        }
        setNeedsDisplay()
    }
    
    private func updateProgressColor() {
        progressLayer.strokeColor = progressColor.resolvedColor(with: traitCollection).cgColor
        progressLayer.lineWidth = ringLineWidth
    }
    
    private func progressPath() -> UIBezierPath {
        let inset = isGlassActive ? ringLineWidth / 2 : ringOffset
        let radius = min(bounds.width, bounds.height) / 2 - inset
        
        return UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                            radius: max(radius, 0),
                            startAngle: -.pi / 2,
                            endAngle: .pi * 3 / 2,
                            clockwise: true)
    }
    
    private func setPressed(_ pressed: Bool, pulse: Bool = false) {
        guard isGlassActive else { return }
        
        let pressedTransform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        let transform = pressed ? pressedTransform : .identity
        guard !UIAccessibility.isReduceMotionEnabled else {
            self.transform = transform
            return
        }
        
        let options: UIView.AnimationOptions = [.allowUserInteraction, .beginFromCurrentState]
        let release = {
            UIView.animate(withDuration: 0.35,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0,
                           options: options) {
                self.transform = transform
            }
        }
        guard pulse else {
            release()
            return
        }
        
        UIView.animate(withDuration: shutterDuration * 0.4, delay: 0, options: options) {
            self.transform = pressedTransform
        } completion: { _ in
            release()
        }
    }
    
    private func playHaptic() {
        guard isHapticFeedbackEnabled else { return }
        
        impactGenerator.impactOccurred()
    }
    
    private func configureButton() {
        configureLayer()
        setTitle("", for: .normal)
        tintColor = .clear
        isAccessibilityElement = true
        updateAccessibility()
        
        addAction(UIAction { [unowned self] _ in
            self.handleTouchDown()
        }, for: .touchDown)
        addAction(UIAction { [unowned self] _ in
            self.handleTouchUpInside()
        }, for: .touchUpInside)
        addAction(UIAction { [unowned self] _ in
            self.handleTouchCancel()
        }, for: [.touchUpOutside, .touchCancel])
    }
    
    private func handleTouchDown() {
        let pressedColor = type == .photo && photoColor == .clear ? UIColor.white : configureColor()
        updateFillColor(pressedColor, animated: true)
        if type == .photo {
            isSelected = true
        }
        setPressed(true)
        if isHapticFeedbackEnabled {
            impactGenerator.prepare()
        }
        delegate?.didTapDownButton(self)
    }
    
    private func handleTouchUpInside() {
        switch type {
        case .photo:
            playShutterAnimation()
        case .video:
            updateFillColor(configureColor(), animated: true)
            isSelected.toggle()
            setPressed(false)
        }
        playHaptic()
        delegate?.didTapButton(self)
    }
    
    private func handleTouchCancel() {
        updateFillColor(configureColor(), animated: true)
        if type == .photo {
            isSelected = false
        }
        setPressed(false)
        delegate?.didTapCancelButton(self)
    }
    
    /// Plays a full press-and-release of the inner circle so that a quick tap is visible
    /// even when touch down and touch up arrive almost at the same time.
    private func playShutterAnimation() {
        let currentPath = pathLayer.presentation()?.path ?? pathLayer.path
        let currentColor = pathLayer.presentation()?.fillColor ?? pathLayer.fillColor
        let pressedColor = (photoColor == .clear ? UIColor.white : configureColor()).resolvedColor(with: traitCollection).cgColor
        let normalColor = configureColor().resolvedColor(with: traitCollection).cgColor
        
        isSelected = false
        CATransaction.performWithoutAnimation {
            pathLayer.fillColor = normalColor
        }
        setPressed(false, pulse: true)
        
        guard !UIAccessibility.isReduceMotionEnabled else {
            pathLayer.removeAllAnimations()
            return
        }
        
        let timing = CAMediaTimingFunction(name: .easeInEaseOut)
        let pathPulse = CAKeyframeAnimation(keyPath: "path")
        pathPulse.values = [currentPath as Any, innerSquarePath().cgPath, innerCirclePath().cgPath]
        pathPulse.keyTimes = [0, 0.4, 1]
        pathPulse.timingFunctions = [timing, timing]
        pathPulse.duration = shutterDuration
        pathLayer.add(pathPulse, forKey: "path")
        
        let colorPulse = CAKeyframeAnimation(keyPath: "fillColor")
        colorPulse.values = [currentColor as Any, pressedColor, normalColor]
        colorPulse.keyTimes = [0, 0.4, 1]
        colorPulse.timingFunctions = [timing, timing]
        colorPulse.duration = shutterDuration
        pathLayer.add(colorPulse, forKey: "fillColor")
    }
    
    private func updateInnerPath(animated: Bool) {
        let newPath = currentInnerPath().cgPath
        if animated && !UIAccessibility.isReduceMotionEnabled {
            let morph = CABasicAnimation(keyPath: "path")
            morph.fromValue = pathLayer.presentation()?.path ?? pathLayer.path
            morph.toValue = newPath
            morph.duration = animateDuration
            morph.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            pathLayer.add(morph, forKey: "path")
        }
        CATransaction.performWithoutAnimation {
            pathLayer.path = newPath
        }
    }
    
    private func updateFillColor(_ color: UIColor, animated: Bool) {
        let newColor = color.resolvedColor(with: traitCollection).cgColor
        if animated {
            let colorChange = CABasicAnimation(keyPath: "fillColor")
            colorChange.fromValue = pathLayer.presentation()?.fillColor ?? pathLayer.fillColor
            colorChange.toValue = newColor
            colorChange.duration = animateDuration
            colorChange.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            pathLayer.add(colorChange, forKey: "fillColor")
        } else {
            pathLayer.removeAnimation(forKey: "fillColor")
        }
        CATransaction.performWithoutAnimation {
            pathLayer.fillColor = newColor
        }
    }
    
    private func updateAccessibility() {
        accessibilityTraits = type == .video && isSelected ? [.button, .selected] : .button
    }
    
    private func currentInnerPath() -> UIBezierPath {
        isSelected ? innerSquarePath() : innerCirclePath()
    }
    
    private func innerCirclePath() -> UIBezierPath {
        let rect = bounds.insetBy(dx: innerLargeCircleOffset, dy: innerLargeCircleOffset)
        
        return UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
    }
    
    private func innerSquarePath() -> UIBezierPath {
        switch type {
        case .photo:
            let rect = bounds.insetBy(dx: innerSmallCircleOffset, dy: innerSmallCircleOffset)
            
            return UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
        case .video:
            let rect = bounds.insetBy(dx: bounds.width / 4, dy: bounds.height / 4)
            
            return UIBezierPath(roundedRect: rect, cornerRadius: squareCornerRadius)
        }
    }
    
    private func configureColor() -> UIColor {
        switch type {
        case .photo where photoColor == .clear && isGlassActive: .white
        case .photo: photoColor == .clear ? type.color : photoColor
        case .video: videoColor == .clear ? type.color : videoColor
        }
    }
    
}

private extension CATransaction {
    
    static func performWithoutAnimation(_ changes: () -> Void) {
        begin()
        setDisableActions(true)
        changes()
        commit()
    }
    
}
