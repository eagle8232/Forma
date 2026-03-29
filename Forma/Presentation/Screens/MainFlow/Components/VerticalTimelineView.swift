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
    
    private lazy var currentTimeCircle: UIView = {
        let view = UIView()
        view.backgroundColor = .accent
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
    private var circleTopConstraint: NSLayoutConstraint?
    
    private var timer: Timer?
    private var timeLabelYAxis: CGFloat = 0
    private var contentHeight: CGFloat?
    
    private let routines: [RoutineBlock] = RoutineBlock.allMocks
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
        guard contentHeight == nil else { return }
        
        shapeLayer.frame = bounds
        contentHeight = bounds.height
        
        linePath.move(to: CGPoint(x: center.x, y: -10000))
        addGrayyedLinePath()
        showAllTasksOnTimeline()
        checkRoutineBubbleViewStatus()
        _ = calculateTime()
        drawLine()
    }
    
    
    // MARK: - Private Methods
    
    private func setup() {
        layer.addSublayer(grayyedShapeLayer)
        layer.addSublayer(shapeLayer)
        layer.insertSublayer(shapeLayer, above: grayyedShapeLayer)
        
        addSubview(currentTimeCircle)
        
        let circleTop = currentTimeCircle.topAnchor.constraint(equalTo: topAnchor, constant: timeLabelYAxis)
        self.circleTopConstraint = circleTop
        circleTop.isActive = true
        
        NSLayoutConstraint.activate([
            currentTimeCircle.centerXAnchor.constraint(equalTo: centerXAnchor),
            currentTimeCircle.widthAnchor.constraint(equalToConstant: 10),
            currentTimeCircle.heightAnchor.constraint(equalToConstant: 10),
        ])
        startTimer()
    }
    
    private func drawLine() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x, y: -10000))
        path.addLine(to: CGPoint(x: center.x, y: timeLabelYAxis))
        shapeLayer.path = path.cgPath
        
        circleTopConstraint?.constant = timeLabelYAxis - 5
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { [ weak self] _ in
            guard let self else {
                return
            }
            if self.calculateTime() == 0 {
                timer?.invalidate()
                timer = nil
            } else {
                drawLine()
                self.checkRoutineBubbleViewStatus()
            }
        })
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func showAllTasksOnTimeline() {
        
        routines.enumerated().forEach { [weak self] index, routine in
            
            guard let self else { return }
            
            let routineStartDateSeconds = DateManager.shared.convertToSeconds(string: routine.startTime)
            let routinesEndDateSeconds = DateManager.shared.convertToSeconds(string: routines.last?.endTime ?? "22:30") // - For instance
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
        let today = DateManager.shared.getTodayTimeString()
        routines.enumerated().forEach { [weak self] index, routine in
            guard let self else { return }
            let currentDateSeconds = DateManager.shared.convertToSeconds(string: today)
            let routineStartDateSeconds = DateManager.shared.convertToSeconds(string: routine.startTime)
            
            if currentDateSeconds >= routineStartDateSeconds {
                self.routineBubbleViews[index].isEnabled(true)
                return
            } else {
                self.routineBubbleViews[index].isEnabled(false)
                return
            }
        }
    }
    
    // MARK: - Helpers
    
    private func calculateTime() -> CGFloat {
        let today = DateManager.shared.getTodayTimeString()
        let routineEndDateString = routines.last?.endTime ?? "22:30"
            
        let currentDateSeconds = DateManager.shared.convertToSeconds(string: today)
        let routineEndDateSeconds = DateManager.shared.convertToSeconds(string: routineEndDateString)
        
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

    deinit {
        timer?.invalidate()
    }
    
}

extension VerticalTimelineView {
    

}
