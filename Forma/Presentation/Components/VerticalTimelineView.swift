//
//  VerticalTimelineView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/23/26.
//

import UIKit

final class VerticalTimelineView: UIView {
    
    private lazy var ellipseView: UIView = {
        let view = UIView()
        view.backgroundColor = .accent
        view.layer.cornerRadius = 7
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = self.getTime()
        label.font = UIFont.monospacedSystemFont(ofSize: 7, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.accent.cgColor
        layer.lineWidth = 5
        layer.lineCap = .round
        return layer
    }()
    
    private lazy var linePath = UIBezierPath()
    private var ellipseTopConstraint: NSLayoutConstraint?
    
    private var timer: Timer?
    private var yAxis: CGFloat = 50
    private var contentHeight: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        contentHeight = bounds.height
        linePath.move(to: CGPoint(x: center.x, y: 0))
        linePath.addLine(to: CGPoint(x: center.x, y: yAxis))
    }
    
    
    // MARK: - Private Methods
    
    private func setup() {
        startTimer()
        
        ellipseView.addSubview(timeLabel)
        addSubview(ellipseView)
        
        let topConstraint = ellipseView.topAnchor.constraint(equalTo: topAnchor, constant: yAxis)
        self.ellipseTopConstraint = topConstraint
        
        NSLayoutConstraint.activate([
            
            ellipseView.centerXAnchor.constraint(equalTo: centerXAnchor),
            topConstraint,
            
            timeLabel.topAnchor.constraint(equalTo: ellipseView.topAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: ellipseView.leadingAnchor, constant: 4),
            timeLabel.trailingAnchor.constraint(equalTo: ellipseView.trailingAnchor, constant: -4),
            timeLabel.bottomAnchor.constraint(equalTo: ellipseView.bottomAnchor, constant: -4),
        ])
    }
    
    private func drawLine() {
        // Set first location of the path to the top of the screen
        linePath.move(to: CGPoint(x: center.x, y: -10000))
        linePath.addLine(to: CGPoint(x: center.x, y: yAxis))
        shapeLayer.path = linePath.cgPath
        layer.addSublayer(shapeLayer)
        ellipseTopConstraint?.constant = yAxis
        layoutIfNeeded()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [ weak self] _ in
            guard let self else {
                return
            }
            self.timeLabel.text = self.getTime()
            if self.calculateTime() == 0 {
                timer?.invalidate()
                timer = nil
            } else {
                drawLine()
            }
        })
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    // MARK: - Helpers
    
    private func getTime() -> String {
        let todayDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let todayDateString = dateFormatter.string(from: todayDate)
        return todayDateString
    }
    
    private func calculateTime() -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let currentDate = dateFormatter.date(from: getTime()) else {
            print("No date set")
            return 0
        }
        
        /// - We use this method to get current time as seconds
        let zeroDateString = "00:00"
        let routineStartDateString = "05:30" // - For instance
        let routineEndDateString = "22:30" // - For instance
        
        guard let zeroDate = dateFormatter.date(from: zeroDateString),
              let routineEndDate = dateFormatter.date(from: routineEndDateString),
              let routineStartDate = dateFormatter.date(from: routineStartDateString) else {
            print("No dates found")
            return 0
        }
        
        let currentDateSeconds = currentDate.timeIntervalSince(zeroDate)
        let routineStartDateSeconds = routineStartDate.timeIntervalSince(zeroDate)
        let routineEndDateSeconds = routineEndDate.timeIntervalSince(zeroDate)
        
        let differenceBetweenDates = routineEndDateSeconds - currentDateSeconds
        
        print("currentDateSeconds: \(currentDateSeconds)")
        print("routineStartDateSeconds: \(routineStartDateSeconds)")
        print("routineEndDateSeconds: \(routineEndDateSeconds)")
        print("differenceBetweenDates: \(differenceBetweenDates)")
        
        yAxis = calculateHeight(between: currentDateSeconds, and: routineEndDateSeconds)
        print(yAxis)
        return differenceBetweenDates
    }
    
    private func calculateHeight(between time1: CGFloat, and time2: CGFloat) -> CGFloat {
        guard let contentHeight else {
            print("No height set")
            return 0
        }
        print(contentHeight)
        /// This math equation helps to place timeLabel in the correct place
        let x = ((time1 * contentHeight)/time2) - 200
        return x
    }

    deinit {
        timer?.invalidate()
    }
    
}
