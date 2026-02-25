//
//  VerticalTimelineView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/23/26.
//

import UIKit

protocol VerticalTimelineViewDelegate: AnyObject {
    func didSelectRoutine(view: VerticalTimelineView, _ routine: RoutineBlock)
}

final class VerticalTimelineView: UIView {
    
    weak var delegate: VerticalTimelineViewDelegate?
    
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
    
    private lazy var grayyedShapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.backgroundSecondary.cgColor
        layer.lineWidth = 5
        layer.lineCap = .round
        return layer
    }()
    
    private lazy var routineBubbleViews: [RoutineBubbleView] = []
    
    private lazy var linePath = UIBezierPath()
    private var ellipseTopConstraint: NSLayoutConstraint?
    
    private var timer: Timer?
    private var timeLabelYAxis: CGFloat = 0
    private var contentHeight: CGFloat?
    
    private let routines: [RoutineBlock] = RoutineBlock.allMocks
    private var selectedRoutine: RoutineBlock?
    private var routineYAxis: [CGFloat] = []
    
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
        linePath.move(to: CGPoint(x: center.x, y: -10000))
        addGrayyedLinePath()
        showAllTasksOnTimeline()
        checkRoutineBubbleViewStatus()
    }
    
    
    // MARK: - Private Methods
    
    private func setup() {
        startTimer()
        
        ellipseView.addSubview(timeLabel)
        addSubview(ellipseView)
        
        // The line will be in the center of timeLabel
        let topConstraint = ellipseView.topAnchor.constraint(equalTo: topAnchor,
                                                             constant: timeLabelYAxis - 5)
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
        UIView.animate(withDuration: 1) {
            // Set first location of the path to the top of the screen
            self.linePath.addLine(to: CGPoint(x: self.center.x, y: self.timeLabelYAxis))
            self.shapeLayer.path = self.linePath.cgPath
            self.layer.insertSublayer(self.shapeLayer, above: self.grayyedShapeLayer)
            self.ellipseTopConstraint?.constant = self.timeLabelYAxis
        }
        checkRoutineBubbleViewStatus()
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
    
    private func showAllTasksOnTimeline() {
        
        routines.enumerated().forEach { [weak self] index, routine in
            
            guard let self else { return }
            
            let routineStartDateSeconds = convertToSeconds(routine.startTime)
            let routinesEndDateSeconds = convertToSeconds(routines.last?.endTime ?? "22:30") // - For instance
            routineYAxis.append(calculateHeight(between: routineStartDateSeconds, and: routinesEndDateSeconds))
            
            let routineBubbledView = RoutineBubbleView(icon: routine.icon, color: routine.accentColor)
            routineBubbledView.onTap = {
                self.delegate?.didSelectRoutine(view: self, routine)
            }
            routineBubbledView.translatesAutoresizingMaskIntoConstraints = false
            
            self.routineBubbleViews.append(routineBubbledView)
            
            self.addSubview(routineBubbleViews[index])
            
            NSLayoutConstraint.activate([
                routineBubbleViews[index].centerXAnchor.constraint(equalTo: self.centerXAnchor),
                routineBubbleViews[index].topAnchor.constraint(equalTo: self.topAnchor, constant: routineYAxis[index])
            ])
        }
    }
    
    private func addGrayyedLinePath() {
        guard let contentHeight else {
            print("No height found")
            return
        }
        let grayLinePath = UIBezierPath()
        grayLinePath.move(to: CGPoint(x: center.x, y: -1000))
        grayLinePath.addLine(to: CGPoint(x: center.x, y: contentHeight + 1000))
        grayyedShapeLayer.path = grayLinePath.cgPath
        grayyedShapeLayer.strokeColor = UIColor.backgroundSecondary.cgColor
        layer.insertSublayer(grayyedShapeLayer, at: 0)
    }
    
    private func checkRoutineBubbleViewStatus() {
        routines.enumerated().forEach { [weak self] index, routine in
            guard let self else { return }
            let currentDateSeconds = convertToSeconds(getTime())
            let routineStartDateSeconds = convertToSeconds(routine.startTime)
            
            let isEnabled = currentDateSeconds >= routineStartDateSeconds
            self.routineBubbleViews[index].isEnabled(isEnabled)
        }
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
    
        let routineEndDateString = routines.last?.endTime ?? "22:30"
                
        let currentDateSeconds = convertToSeconds(getTime())
        let routineEndDateSeconds = convertToSeconds(routineEndDateString)
        
        let differenceBetweenDates = routineEndDateSeconds - currentDateSeconds
        
        timeLabelYAxis = calculateHeight(between: currentDateSeconds, and: routineEndDateSeconds)
        
        return differenceBetweenDates
    }
    
    private func calculateHeight(between time1: CGFloat, and time2: CGFloat) -> CGFloat {
        guard let contentHeight else {
            print("No height set")
            return 0
        }
        /// This math equation helps to place timeLabel and routineBubbles in the correct places
        let x = ((time1 * contentHeight)/time2) - 100
        return x
    }
    
    private func convertToSeconds(_ dateString: String) -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        /// - We use this method to get difference between 00:00 and date, to get a positive result
        let zeroDateString: String = "00:00"
        guard let zeroDate = dateFormatter.date(from: zeroDateString),
              let date = dateFormatter.date(from: dateString) else {
            print("No dates found")
            return 0
        }
        
        let dateInSeconds = date.timeIntervalSince(zeroDate)
        return dateInSeconds
    }

    deinit {
        timer?.invalidate()
    }
    
}

extension VerticalTimelineView {
    

}
