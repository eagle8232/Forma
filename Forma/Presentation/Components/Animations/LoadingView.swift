//
//  SmoothLineAnimationView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/6/26.
//

import UIKit

class LoadingView: UIView {

    var shapeLayer: CAShapeLayer!
    private var lineGradient: CAGradientLayer!

    // Shared configuration
    private let loopDuration: CFTimeInterval = 2.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        
        // Shape layer for the infinity path
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5.0
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round

        // Gradient for the line (will be masked by shapeLayer)
        lineGradient = CAGradientLayer()
        lineGradient.startPoint = CGPoint(x: 0, y: 0.5)
        lineGradient.endPoint = CGPoint(x: 1, y: 0.5)
        lineGradient.colors = [
            UIColor.stateMorning.cgColor,
            UIColor.cyan.cgColor,
            UIColor.green.cgColor,
            UIColor.stateEvening.cgColor,
            UIColor.stateSleep.cgColor
        ]
        lineGradient.locations = [0.0, 0.4, 0.8, 1.0]
        lineGradient.backgroundColor = UIColor.clear.cgColor

        // The gradient shows only where the mask (shapeLayer) is
        lineGradient.mask = shapeLayer

        // Add layers
        layer.addSublayer(lineGradient)

        layer.shouldRasterize = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Create the complete infinity path (no gaps)
        let path = createInfinityPath(in: bounds)
        shapeLayer.path = path.cgPath
        
        // Update frames
        lineGradient.frame = bounds
        shapeLayer.frame = bounds
    }

    // Generate a smooth, complete infinity path
    private func createInfinityPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let cx = rect.midX
        let cy = rect.midY
        let a = min(rect.width, rect.height * 2) * 0.45
        let b = a * 0.6

        let steps = 480

        for i in 0...steps {
            let t = Double(i) / Double(steps) * Double.pi * 2.0
            let x = a * CGFloat(cos(t))
            let y = b * CGFloat(sin(t) * cos(t))
            let pt = CGPoint(x: cx + x, y: cy + y)

            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }

        path.close() // Complete the loop
        path.lineWidth = 10.0
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        return path
    }

    // Start the animated loader
    func startLoadingAnimation() {
        shapeLayer.path = createInfinityPath(in: bounds).cgPath

        // Animate strokeStart and strokeEnd to create a moving gap
        let gapSize: CGFloat = 0.5 // Size of the gap (15% of total path)
        
        // strokeEnd animation - the "head" of the visible line
        let strokeEndAnim = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnim.fromValue = 0
        strokeEndAnim.toValue = 1 + gapSize
        strokeEndAnim.duration = loopDuration
        strokeEndAnim.repeatCount = .infinity
        strokeEndAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        strokeEndAnim.isRemovedOnCompletion = false
        
        // strokeStart animation - the "tail" that follows, creating the gap
        let strokeStartAnim = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnim.fromValue = 0
        strokeStartAnim.toValue = 1
        strokeStartAnim.duration = loopDuration
        strokeStartAnim.repeatCount = .infinity
        strokeStartAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        strokeStartAnim.isRemovedOnCompletion = false
        
        shapeLayer.add(strokeEndAnim, forKey: "strokeEnd")
        shapeLayer.add(strokeStartAnim, forKey: "strokeStart")

        // Gradient animation for color cycling
        let startPointAnim = CABasicAnimation(keyPath: "startPoint")
        startPointAnim.fromValue = NSValue(cgPoint: CGPoint(x: -0.5, y: 0.5))
        startPointAnim.toValue = NSValue(cgPoint: CGPoint(x: 1.5, y: 0.5))
        startPointAnim.duration = loopDuration * 2
        startPointAnim.repeatCount = .infinity
        startPointAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        startPointAnim.isRemovedOnCompletion = false
        lineGradient.add(startPointAnim, forKey: "startPointMove")

        let endPointAnim = CABasicAnimation(keyPath: "endPoint")
        endPointAnim.fromValue = NSValue(cgPoint: CGPoint(x: 0.5, y: 0.5))
        endPointAnim.toValue = NSValue(cgPoint: CGPoint(x: 2.5, y: 0.5))
        endPointAnim.duration = loopDuration * 2
        endPointAnim.repeatCount = .infinity
        endPointAnim.timingFunction = CAMediaTimingFunction(name: .linear)
        endPointAnim.isRemovedOnCompletion = false
        lineGradient.add(endPointAnim, forKey: "endPointMove")
    }

    func stopLoadingAnimation() {
        shapeLayer.removeAllAnimations()
        lineGradient.removeAllAnimations()
    }

    deinit {
        stopLoadingAnimation()
    }
}
