//
//  CameraButton.swift
//
//  Copyright (c) 2019 Kichibekov Ramiz (https://www.instagram.com/ramiz69/)
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

enum CameraButtonType {
    case photo
    case video
    
    var color: CGColor {
        switch self {
        case .photo: return UIColor(white: 1, alpha: 0.24).cgColor
        case .video: return UIColor.red.cgColor
        }
    }
    
    init(withValue value: Int) {
        switch value {
        case 0: self = .photo
        case 1: self = .video
        default: self = .photo
        }
    }
    
    var index: Int {
        switch self {
        case .photo: return 0
        case .video: return 1
        }
    }
}

final class CameraButton: UIButton {
    
    // MARK: - Properties
    
    public var type: CameraButtonType = .photo {
        didSet {
            pathLayer.removeAllAnimations()
            pathLayer.fillColor = type.color
        }
    }
    private let pathLayer = CAShapeLayer()
    private let animateDuration = 0.3
    override var isSelected: Bool {
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
    
    // MARK: - UIButton life cycle
    
    init() {
        super.init(frame: .zero)
        
        configureButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configureButton()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .width,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .width,
                                         multiplier: 1,
                                         constant: 66))
        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .height,
                                         relatedBy: .equal,
                                         toItem: nil,
                                         attribute: .width,
                                         multiplier: 1,
                                         constant: 66))
        setTitle("", for: .normal)
        tintColor = .clear
        addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        addTarget(self, action: #selector(touchCancel(_:)), for: .touchDragExit)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let ringRect = CGRect(x: 3, y: 3, width: 60, height: 60)
        let outerRing = UIBezierPath(ovalIn: ringRect)
        outerRing.lineWidth = 4
        UIColor.white.setStroke()
        outerRing.stroke()
    }
    
    // MARK: - Custom methos
    // MARK: - Private methods
    
    private func configureButton() {
        pathLayer.path = currentInnerPath().cgPath
        pathLayer.strokeColor = nil
        pathLayer.fillColor = type.color
        layer.addSublayer(pathLayer)
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
        let rect = CGRect(x: 8, y: 8, width: 50, height: 50)
        
        return UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
    }
    
    private func innerSquarePath() -> UIBezierPath {
        switch type {
        case .photo:
            let rect = CGRect(x: 13, y: 13, width: 40, height: 40)
            
            return UIBezierPath(roundedRect: rect, cornerRadius: rect.width / 2)
        case .video:
            let rect = CGRect(x: 17, y: 17, width: 32, height: 32)
            
            return UIBezierPath(roundedRect: rect, cornerRadius: 8)
        }
    }
    
    // MARK: - Actions
    
    @objc private func touchCancel(_ sender: UIButton) {
        isSelected = !isSelected
    }
    
    @objc private func touchDown(_ sender: UIButton) {
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animateDuration
        colorChange.toValue = type == .photo ? UIColor.white.cgColor : type.color
        
        colorChange.fillMode = .forwards
        colorChange.isRemovedOnCompletion = false
        
        colorChange.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathLayer.add(colorChange, forKey: "darkColor")
        if type == .photo {
            isSelected = !isSelected
        }
    }
    
    @objc private func touchUpInside(_ sender: UIButton) {
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animateDuration
        colorChange.toValue = type.color
        
        colorChange.fillMode = .forwards
        colorChange.isRemovedOnCompletion = false
        
        colorChange.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathLayer.add(colorChange, forKey: "darkColor")
        isSelected = !isSelected
    }
    
}
