//
//  CameraButton.swift
//
//  Copyright (c) 2019 Ramiz Kichibekov (https://t.me/Ramiz69)
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

public enum CameraButtonType {
    case photo
    case video
    
    public var color: CGColor {
        switch self {
        case .photo: return UIColor(white: 1, alpha: 0.24).cgColor
        case .video: return UIColor.red.cgColor
        }
    }
    
    public init(withValue value: Int) {
        switch value {
        case 0: self = .photo
        case 1: self = .video
        default: self = .photo
        }
    }
    
    public var index: Int {
        switch self {
        case .photo: return 0
        case .video: return 1
        }
    }
}

@IBDesignable
open class CameraButton: UIButton {
    
    // MARK: - Ring
    
    @IBInspectable
    public var ringOffset: CGFloat = 3 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var ringLineWidth: CGFloat = 4 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    public var ringColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Inner large circle
    
    @IBInspectable
    public var innerLargeCircleOffset: CGFloat = 8 {
        didSet {
            configureLayer()
        }
    }
    
    // MARK: - Inner small circle
    
    @IBInspectable
    public var innerSmallCircleOffset: CGFloat = 13 {
        didSet {
            configureLayer()
        }
    }
    
    // MARK: - Inner square
    
    @IBInspectable
    public var innerSquare: CGFloat = 17 {
        didSet {
            configureLayer()
        }
    }
    
    @IBInspectable
    public var squareCornerRadius: CGFloat = 8 {
        didSet {
            configureLayer()
        }
    }
    
    // MARK: - Properties
    // MARK: - Open properties
    
    override open var isSelected: Bool {
        didSet {
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = animateDuration
            morph.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            morph.toValue = currentInnerPath().cgPath
            morph.fillMode = .forwards
            morph.isRemovedOnCompletion = false
            pathLayer.add(morph, forKey: "")
        }
    }
    
    // MARK: - Public properties
    
    public var type: CameraButtonType = .photo {
        didSet {
            pathLayer.removeAllAnimations()
            pathLayer.fillColor = type.color
        }
    }
    
    // MARK: - Private properties
    
    private let pathLayer = CAShapeLayer()
    private let animateDuration = 0.3
    private let colorChangeAnimator = CABasicAnimation(keyPath: "fillColor")
    
    // MARK: - UIButton life cycle
    
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
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .width,
                                         multiplier: 1,
                                         constant: frame.width))
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .width,
                                         multiplier: 1,
                                         constant: frame.height))
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ringRect = CGRect(x: ringOffset,
                              y: ringOffset,
                              width: frame.width - ringOffset * 2,
                              height: frame.height - ringOffset * 2)
        let outerRing = UIBezierPath(ovalIn: ringRect)
        outerRing.lineWidth = ringLineWidth
        ringColor.setStroke()
        outerRing.stroke()
    }
    
    // MARK: - Custom methos
    // MARK: - Private methods
    
    private func configureLayer() {
        pathLayer.removeAllAnimations()
        pathLayer.removeFromSuperlayer()
        pathLayer.path = currentInnerPath().cgPath
        pathLayer.strokeColor = nil
        pathLayer.fillColor = type.color
        layer.addSublayer(pathLayer)
    }
    
    private func configureButton() {
        configureLayer()
        setTitle("", for: .normal)
        tintColor = .clear
        addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(touchCancel(_:)), for: .touchDragExit)
    }
    
    private func currentInnerPath() -> UIBezierPath {
        var returnPath: UIBezierPath
        if isSelected {
            returnPath = innerSquarePath()
        } else {
            returnPath = innerCirclePath()
        }
        
        return returnPath
    }
    
    private func innerCirclePath() -> UIBezierPath {
        let rect = CGRect(x: innerLargeCircleOffset,
                          y: innerLargeCircleOffset,
                          width: frame.width - innerLargeCircleOffset * 2,
                          height: frame.height - innerLargeCircleOffset * 2)
        
        return UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
    }
    
    private func innerSquarePath() -> UIBezierPath {
        switch type {
        case .photo:
            let rect = CGRect(x: innerSmallCircleOffset,
                              y: innerSmallCircleOffset,
                              width: frame.width - innerSmallCircleOffset * 2,
                              height: frame.height - innerSmallCircleOffset * 2)
            
            return UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
        case .video:
            let rect = CGRect(x: innerCirclePath().currentPoint.x / 2,
                              y: innerCirclePath().currentPoint.x / 2,
                              width: frame.width / 2,
                              height: frame.height / 2)
            
            return UIBezierPath(roundedRect: rect, cornerRadius: squareCornerRadius)
        }
    }
    
    // MARK: - Actions
    
    @objc private func touchCancel(_ sender: UIButton) {
        isSelected = !isSelected
        colorChangeAnimator.toValue = type.color
        pathLayer.add(colorChangeAnimator, forKey: "darkColor")
    }
    
    @objc private func touchDown(_ sender: UIButton) {
        colorChangeAnimator.duration = animateDuration
        colorChangeAnimator.toValue = type == .photo ? UIColor.white.cgColor : type.color
        
        colorChangeAnimator.fillMode = .forwards
        colorChangeAnimator.isRemovedOnCompletion = false
        
        colorChangeAnimator.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathLayer.add(colorChangeAnimator, forKey: "darkColor")
        if type == .photo {
            isSelected = !isSelected
        }
    }
    
    @objc private func touchUpInside(_ sender: UIButton) {
        colorChangeAnimator.duration = animateDuration
        colorChangeAnimator.toValue = type.color
        
        colorChangeAnimator.fillMode = .forwards
        colorChangeAnimator.isRemovedOnCompletion = false
        
        colorChangeAnimator.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathLayer.add(colorChangeAnimator, forKey: "darkColor")
        isSelected = !isSelected
    }
    
}
