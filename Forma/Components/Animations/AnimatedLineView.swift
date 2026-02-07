//
//  SmoothLineAnimationView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/6/26.
//

import UIKit

class WavedLineView: UIView {
    
    var shapeLayer: CAShapeLayer!
    private var displayLink: CADisplayLink?
    private var animationStartTime: CFTimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .backgroundPrimary
        
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3.0
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set initial path
        if shapeLayer.path == nil {
            shapeLayer.path = createWavedLine(phase: 0).cgPath
        }
    }
    
    // MARK: - Create Waved Line
    
    private func createWavedLine(phase: CGFloat = 0) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        
        let width = bounds.width
        let midY = bounds.midY
        
        // Create smooth wave using multiple curves
        let numberOfWaves: CGFloat = 1
        let waveAmplitude: CGFloat = 250
        let segmentWidth = width / numberOfWaves
        
        for i in 0..<Int(numberOfWaves) {
            let startX = CGFloat(i) * segmentWidth
            let endX = startX + segmentWidth
            
            // Calculate wave offset based on phase
            let offset = sin(phase + CGFloat(i) * 0.5) * waveAmplitude
            
            let controlPoint1 = CGPoint(
                x: startX + segmentWidth * 0.25,
                y: midY - waveAmplitude + offset
            )
            let controlPoint2 = CGPoint(
                x: startX + segmentWidth * 0.75,
                y: midY + waveAmplitude + offset
            )
            
            path.addCurve(
                to: CGPoint(x: endX, y: midY),
                controlPoint1: controlPoint1,
                controlPoint2: controlPoint2
            )
        }
        
        return path
    }
    
    func animateStroke() {

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor.stateMorning.cgColor,
            UIColor.stateEvening.cgColor,
            UIColor.stateSleep.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        shapeLayer.path = createWavedLine(phase: 0).cgPath
        
        gradientLayer.mask = shapeLayer
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = 7.0
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shapeLayer.add(animation, forKey: "strokeAnimation")
    }
    
    func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopAnimation()
    }
}
