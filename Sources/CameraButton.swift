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
    
    // MARK: Colors

    public var photoColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }

    public var videoColor: UIColor = .clear {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Ring

    public var ringOffset: CGFloat = 3 {
        didSet {
            setNeedsDisplay()
        }
    }

    public var ringLineWidth: CGFloat = 4 {
        didSet {
            setNeedsDisplay()
        }
    }

    public var ringColor: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: Inner large circle

    public var innerLargeCircleOffset: CGFloat = 8 {
        didSet {
            configureLayer()
        }
    }
    
    // MARK: Inner small circle

    public var innerSmallCircleOffset: CGFloat = 13 {
        didSet {
            configureLayer()
        }
    }
    
    // MARK: Inner square

    public var innerSquare: CGFloat = 17 {
        didSet {
            configureLayer()
        }
    }

    public var squareCornerRadius: CGFloat = 8 {
        didSet {
            configureLayer()
        }
    }
    
    // MARK: Properties
    
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
    
    // MARK: Public properties
    
    public var type: CameraType = .photo {
        didSet {
            pathLayer.removeAllAnimations()
            pathLayer.fillColor = configureColor().cgColor
            isSelected = false
        }
    }
    public weak var delegate: CameraButtonDelegate?

    // MARK: Private properties
    
    private let pathLayer = CAShapeLayer()
    private let animateDuration = CATransaction.animationDuration()
    private let colorChangeAnimator = CABasicAnimation(keyPath: "fillColor")
    
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
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        Task {
            await MainActor.run {
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
        }
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
        pathLayer.fillColor = configureColor().cgColor
    }

    // MARK: Private methods
    
    private func configureLayer() {
        pathLayer.removeAllAnimations()
        pathLayer.removeFromSuperlayer()
        pathLayer.path = currentInnerPath().cgPath
        pathLayer.strokeColor = nil
        layer.addSublayer(pathLayer)
    }
    
    private func configureButton() {
        configureLayer()
        setTitle("", for: .normal)
        tintColor = .clear
        let touchUpInsideAction = UIAction { [unowned self] _ in
            self.colorChangeAnimator.duration = animateDuration
            self.colorChangeAnimator.toValue = configureColor().cgColor

            self.colorChangeAnimator.fillMode = .forwards
            self.colorChangeAnimator.isRemovedOnCompletion = false

            self.colorChangeAnimator.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.pathLayer.add(colorChangeAnimator, forKey: "darkColor")
            self.isSelected = !self.isSelected
            self.delegate?.didTapButton(self)
        }
        addAction(touchUpInsideAction, for: .touchUpInside)
        let touchDownAction = UIAction { [unowned self] _ in
            self.colorChangeAnimator.duration = animateDuration
            self.colorChangeAnimator.toValue = type == .photo && photoColor == .clear ? UIColor.white.cgColor : configureColor().cgColor

            self.colorChangeAnimator.fillMode = .forwards
            self.colorChangeAnimator.isRemovedOnCompletion = false

            self.colorChangeAnimator.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.pathLayer.add(colorChangeAnimator, forKey: "darkColor")
            if self.type == .photo {
                self.isSelected = !isSelected
            }
            self.delegate?.didTapDownButton(self)
        }
        addAction(touchDownAction, for: .touchDown)
        let touchCancelAction = UIAction { [unowned self] _ in
            self.isSelected = !self.isSelected
            self.colorChangeAnimator.toValue = self.configureColor().cgColor
            self.pathLayer.add(colorChangeAnimator, forKey: "darkColor")
            self.delegate?.didTapCancelButton(self)
        }
        addAction(touchCancelAction, for: .touchCancel)
    }
    
    private func currentInnerPath() -> UIBezierPath {
        isSelected ? innerSquarePath() : innerCirclePath()
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
    
    private func configureColor() -> UIColor {
        switch type {
        case .photo: photoColor == .clear ? type.color : photoColor
        case .video: videoColor == .clear ? type.color : videoColor
        }
    }
    
}
