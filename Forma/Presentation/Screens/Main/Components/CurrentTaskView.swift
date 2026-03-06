//
//  CurrentTaskView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/27/26.
//

import UIKit

protocol CurrentTaskViewDelegate: AnyObject {
    func nextTask(_ view: CurrentTaskView)
}

// MARK: - Task State

enum TaskState: String, Codable {
    case upcoming, running, paused, completed
    
    
    var contentAlpha: CGFloat {
        switch self {
        case .upcoming:  return 0.55
        case .running:   return 1.0
        case .completed: return 0.35
        case .paused:    return 1.0
        }
    }

    var gradientColors: [CGColor] {
        switch self {
        case .upcoming:
            return [
                UIColor(red: 20/255, green: 20/255, blue: 28/255, alpha: 1).cgColor,
                UIColor(red: 14/255, green: 14/255, blue: 20/255, alpha: 1).cgColor,
            ]
        case .running:
            return [
                UIColor(red: 28/255, green: 26/255, blue: 46/255, alpha: 1).cgColor,
                UIColor(red: 18/255, green: 16/255, blue: 32/255, alpha: 1).cgColor,
            ]
        case .completed:
            return [
                UIColor(red: 16/255, green: 16/255, blue: 22/255, alpha: 1).cgColor,
                UIColor(red: 12/255, green: 12/255, blue: 16/255, alpha: 1).cgColor,
            ]
        case .paused:
            return [
                UIColor(red: 16/255, green: 16/255, blue: 22/255, alpha: 1).cgColor,
                UIColor(red: 12/255, green: 12/255, blue: 16/255, alpha: 1).cgColor,
            ]
        }
    }

    var borderColor: CGColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.06).cgColor
        case .running:   return UIColor.accent.withAlphaComponent(0.35).cgColor
        case .completed: return UIColor.white.withAlphaComponent(0.03).cgColor
        case .paused:    return UIColor.white.withAlphaComponent(0.03).cgColor
        }
    }

    var iconTint: UIColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.25)
        case .running:   return UIColor.accent
        case .completed: return UIColor.white.withAlphaComponent(0.15)
        case .paused:    return UIColor.white.withAlphaComponent(0.15)
        }
    }

    var badgeAccentColor: UIColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.3)
        case .running:   return UIColor.accent
        case .completed: return UIColor.systemGreen
        case .paused:    return UIColor.systemGreen
        }
    }

    var badgeText: String {
        switch self {
        case .upcoming:  return "upcoming"
        case .running:   return "now"
        case .completed: return "done"
        case .paused:    return "paused"
        }
    }

    var titleColor: UIColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.45)
        case .running:   return UIColor.white
        case .completed: return UIColor.white.withAlphaComponent(0.2)
        case .paused:    return UIColor.white.withAlphaComponent(0.2)
        }
    }

    var timeColor: UIColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.2)
        case .running:   return UIColor.accent.withAlphaComponent(0.8)
        case .completed: return UIColor.white.withAlphaComponent(0.12)
        case .paused:    return UIColor.white.withAlphaComponent(0.12)
        }
    }
}

// MARK: - CurrentTaskView

final class CurrentTaskView: UIView {

    // MARK: - Properties

    private lazy var circleView         = UIView()
    private lazy var iconBackgroundView = UIView()
    private lazy var iconImageView      = UIImageView()
    private lazy var taskNameLabel      = UILabel()
    private lazy var timeLabel          = UILabel()
    private lazy var finishesAtLabel    = UILabel()

    private lazy var statusPillView = UIView()
    private lazy var statusDotView  = UIView()
    private lazy var statusLabel    = UILabel()

    private var backgroundCircleLayer = CAShapeLayer()
    private var progressLayer         = CAShapeLayer()
    private var gradientLayer         = CAGradientLayer()
    private var glowLayer             = CAShapeLayer()
    private var iconCircleLayer: CAShapeLayer?

    private var countdownTimer: Timer?
    private var remainingTime: CGFloat = 0
    private var isLayedOut    = false
    private var progressValue: CGFloat = 0
    
    weak var delegate: CurrentTaskViewDelegate?

    var task: RoutineTask? {
        didSet { updateTask(animated: true) }
    }

    var state: TaskState = .upcoming {
        didSet { handleStateChange() }
    }

    // MARK: - Init

    init(task: RoutineTask? = nil) {
        self.task = task
        super.init(frame: .zero)
        layoutViews()
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        iconBackgroundView.layoutIfNeeded()
        guard !isLayedOut else { return }
        guard !iconBackgroundView.bounds.isEmpty else { return }
        isLayedOut = true

        buildCircleLayers()
        buildIconImageView()
        buildTaskNameLabel()
        buildTimeLabel()
        buildFinishesAtLabel()
        buildStatusPill()
    }
    
    // MARK: - Public Methods
    public func start() {
        animateProgressIn()
        startPulsingIcon()
        startCountdown()
    }

    private func layoutViews() {
        circleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(circleView)
        NSLayoutConstraint.activate([
            circleView.topAnchor.constraint(equalTo: topAnchor),
            circleView.leadingAnchor.constraint(equalTo: leadingAnchor),
            circleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            circleView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // Icon
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints      = false
        iconImageView.contentMode      = .scaleAspectFit
        iconBackgroundView.backgroundColor = .clear
        iconBackgroundView.addSubview(iconImageView)
        circleView.addSubview(iconBackgroundView)

        let imagePadding: CGFloat = 10
        NSLayoutConstraint.activate([
            iconBackgroundView.topAnchor.constraint(equalTo: circleView.topAnchor, constant: 64),
            iconBackgroundView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 44),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 44),

            iconImageView.topAnchor.constraint(equalTo: iconBackgroundView.topAnchor, constant: imagePadding),
            iconImageView.leadingAnchor.constraint(equalTo: iconBackgroundView.leadingAnchor, constant: imagePadding),
            iconImageView.trailingAnchor.constraint(equalTo: iconBackgroundView.trailingAnchor, constant: -imagePadding),
            iconImageView.bottomAnchor.constraint(equalTo: iconBackgroundView.bottomAnchor, constant: -imagePadding),
        ])

        // Task Name
        taskNameLabel.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(taskNameLabel)
        NSLayoutConstraint.activate([
            taskNameLabel.topAnchor.constraint(equalTo: iconBackgroundView.bottomAnchor, constant: 16),
            taskNameLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            taskNameLabel.widthAnchor.constraint(equalTo: circleView.widthAnchor, multiplier: 0.75),
        ])

        // Time
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: taskNameLabel.bottomAnchor, constant: 8),
            timeLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
        ])

        // Finishes At
        finishesAtLabel.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(finishesAtLabel)
        NSLayoutConstraint.activate([
            finishesAtLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            finishesAtLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
        ])

        // Status pill
        statusPillView.translatesAutoresizingMaskIntoConstraints = false
        statusDotView.translatesAutoresizingMaskIntoConstraints  = false
        statusLabel.translatesAutoresizingMaskIntoConstraints    = false

        statusPillView.addSubview(statusDotView)
        statusPillView.addSubview(statusLabel)
        circleView.addSubview(statusPillView)

        let dotSize: CGFloat = 6
        NSLayoutConstraint.activate([
            statusPillView.topAnchor.constraint(equalTo: finishesAtLabel.bottomAnchor, constant: 12),
            statusPillView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),

            statusDotView.leadingAnchor.constraint(equalTo: statusPillView.leadingAnchor, constant: 10),
            statusDotView.centerYAnchor.constraint(equalTo: statusPillView.centerYAnchor),
            statusDotView.widthAnchor.constraint(equalToConstant: dotSize),
            statusDotView.heightAnchor.constraint(equalToConstant: dotSize),

            statusLabel.leadingAnchor.constraint(equalTo: statusDotView.trailingAnchor, constant: 6),
            statusLabel.trailingAnchor.constraint(equalTo: statusPillView.trailingAnchor, constant: -10),
            statusLabel.topAnchor.constraint(equalTo: statusPillView.topAnchor, constant: 5),
            statusLabel.bottomAnchor.constraint(equalTo: statusPillView.bottomAnchor, constant: -5),
        ])
    }

    // MARK: - Tap Gesture

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        circleView.addGestureRecognizer(tap)
        circleView.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        guard state != .completed else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        switch state {
        case .upcoming:
            state = .running
        case .running:
            state = .paused
        case .paused:
            state = .running
        case .completed:
            break
        }
    }
}

// MARK: - Status Pill

extension CurrentTaskView {

    private func buildStatusPill() {
        statusPillView.layer.cornerRadius  = 10
        statusPillView.layer.borderWidth   = 0.5
        statusPillView.layer.borderColor   = UIColor.white.withAlphaComponent(0.08).cgColor
        statusPillView.backgroundColor     = UIColor.white.withAlphaComponent(0.05)
        statusPillView.clipsToBounds       = true

        statusDotView.layer.cornerRadius = 3

        statusLabel.font = UIFont.typography(.caption)
        statusLabel.textColor = UIColor.textTertiary

        applyStatusStyle(for: .upcoming, animated: false)
    }

    private func applyStatusStyle(for newState: TaskState, animated: Bool) {
        typealias Style = (dot: UIColor, text: String)

        let style: Style
        switch newState {
        case .running:   style = (UIColor.accent,        "in focus")
        case .paused:    style = (UIColor.systemOrange,  "paused")
        case .completed: style = (UIColor.systemGreen,   "completed")
        case .upcoming:      style = (UIColor.textTertiary,  "Upcoming")
        }

        let apply = {
            self.statusDotView.backgroundColor    = style.dot
            self.statusDotView.layer.shadowColor   = style.dot.cgColor
            self.statusDotView.layer.shadowRadius  = 4
            self.statusDotView.layer.shadowOpacity = 0.85
            self.statusDotView.layer.shadowOffset  = .zero
            self.statusLabel.text = style.text
        }

        if animated {
            UIView.transition(with: statusPillView, duration: 0.3,
                              options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }

        restartDotPulse(color: style.dot, pulsing: newState == .running)
    }

    // MARK: Dot pulse

    private func restartDotPulse(color: UIColor, pulsing: Bool) {
        statusDotView.layer.removeAllAnimations()
        guard pulsing else { return }

        // Scale breathe
        let scale        = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.values     = [1.0, 1.6, 1.0]
        scale.keyTimes   = [0,   0.5,  1]
        scale.duration   = 1.6
        scale.repeatCount = .infinity
        scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        statusDotView.layer.add(scale, forKey: "dotScale")

        // Opacity breathe
        let opacity          = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue    = 1.0
        opacity.toValue      = 0.35
        opacity.duration     = 0.8
        opacity.autoreverses = true
        opacity.repeatCount  = .infinity
        opacity.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        statusDotView.layer.add(opacity, forKey: "dotOpacity")
    }
}

// MARK: - Circle Layers

extension CurrentTaskView {

    private func buildCircleLayers() {
        let rect   = circleView.bounds
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2 - 15
        let start: CGFloat = -CGFloat.pi / 2

        let trackPath = UIBezierPath(arcCenter: center, radius: radius,
                                     startAngle: 0, endAngle: .pi * 2, clockwise: true)
        backgroundCircleLayer.path        = trackPath.cgPath
        backgroundCircleLayer.fillColor   = UIColor.clear.cgColor
        backgroundCircleLayer.strokeColor = UIColor.backgroundSecondary.cgColor
        backgroundCircleLayer.lineWidth   = 15
        backgroundCircleLayer.frame       = rect
        circleView.layer.addSublayer(backgroundCircleLayer)

        let progressPath = UIBezierPath(arcCenter: center, radius: radius,
                                        startAngle: start, endAngle: .pi * 2 + start, clockwise: true)
        progressLayer.path        = progressPath.cgPath
        progressLayer.fillColor   = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.accent.cgColor
        progressLayer.lineWidth   = 15
        progressLayer.lineCap     = .round
        progressLayer.frame       = rect
        progressLayer.strokeEnd   = 0

        gradientLayer.colors     = [UIColor.accent.cgColor, UIColor.accentGradient.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.3, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        gradientLayer.frame      = rect
        gradientLayer.mask       = progressLayer

        glowLayer.path          = progressPath.cgPath
        glowLayer.fillColor     = UIColor.clear.cgColor
        glowLayer.strokeColor   = UIColor.accent.withAlphaComponent(0.45).cgColor
        glowLayer.lineWidth     = 22
        glowLayer.lineCap       = .round
        glowLayer.frame         = rect
        glowLayer.strokeEnd     = 0
        glowLayer.shadowColor   = UIColor.accent.cgColor
        glowLayer.shadowRadius  = 8
        glowLayer.shadowOpacity = 0.9
        glowLayer.shadowOffset  = .zero

        circleView.layer.addSublayer(glowLayer)
        circleView.layer.addSublayer(gradientLayer)
    }

    private func animateProgressIn() {
        let anim   = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue            = progressValue
        anim.toValue              = remainingTime
        anim.duration             = 1.2
        anim.timingFunction       = CAMediaTimingFunction(controlPoints: 0.25, 1.5, 0.5, 1.0)
        anim.fillMode             = .forwards
        anim.isRemovedOnCompletion = false

        progressLayer.strokeEnd = remainingTime
        progressLayer.add(anim, forKey: "progressIn")
        glowLayer.strokeEnd = remainingTime
        glowLayer.add(anim.copy() as! CABasicAnimation, forKey: "glowIn")
        progressValue = remainingTime
    }

    private func animateProgress(to fraction: CGFloat) {
        let current = progressValue
        print("current", current)
        print("fraction", fraction)
        let anim    = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue            = current
        anim.toValue              = fraction
        anim.duration             = 0.6
        anim.timingFunction       = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.fillMode             = .forwards
        anim.isRemovedOnCompletion = false

        progressLayer.strokeEnd = fraction
        progressLayer.add(anim, forKey: "progressUpdate")
        glowLayer.strokeEnd = fraction
        glowLayer.add(anim.copy() as! CABasicAnimation, forKey: "glowUpdate")
        progressValue = fraction
    }

}

// MARK: - Inner Content

extension CurrentTaskView {

    private func buildIconImageView() {
        iconImageView.image     = UIImage(systemName: "bolt.fill")
        iconImageView.tintColor = UIColor.accent

        let rect = iconBackgroundView.bounds
        guard !rect.isEmpty else { return }

        let circleLayer           = CAShapeLayer()
        circleLayer.path          = UIBezierPath(ovalIn: CGRect(origin: .zero, size: rect.size)).cgPath
        circleLayer.fillColor     = UIColor.accent.withAlphaComponent(0.1).cgColor
        circleLayer.strokeColor   = UIColor.accent.cgColor
        circleLayer.lineWidth     = 0.5
        circleLayer.frame         = CGRect(origin: .zero, size: rect.size)
        circleLayer.contentsScale = UIScreen.main.scale
        circleLayer.shadowColor   = UIColor.accent.cgColor
        circleLayer.shadowRadius  = 6
        circleLayer.shadowOpacity = 0.6
        circleLayer.shadowOffset  = .zero
        iconBackgroundView.layer.insertSublayer(circleLayer, at: 0)
        iconCircleLayer = circleLayer
    }

    private func buildTaskNameLabel() {
        taskNameLabel.text          = task?.title ?? ""
        taskNameLabel.font          = UIFont.typography(.heading3)
        taskNameLabel.textColor     = .textPrimary
        taskNameLabel.numberOfLines = 2
        taskNameLabel.textAlignment = .center
    }

    private func buildTimeLabel() {
        timeLabel.text      = "Starts at \(task?.startTime ?? "00:00")"
        timeLabel.font      = UIFont.typography(.bodySmall)
        timeLabel.textColor = UIColor.accentGradient
    }

    private func buildFinishesAtLabel() {
        finishesAtLabel.text      = "Finishes at \(finishTime())"
        finishesAtLabel.font      = UIFont.typography(.monospacedSmall)
        finishesAtLabel.textColor = UIColor.textTertiary
    }

    private func finishTime() -> String {
        let startTimeInSeconds = DateManager.shared.convertToSeconds(task?.startTime ?? "00:00")
        let end = DateManager.shared.convertToDateString(startTimeInSeconds + CGFloat(task?.duration ?? 0))
        return end
    }
}

// MARK: - Countdown Timer

extension CurrentTaskView {

    private func startCountdown() {
        scheduleTimer()
    }

    private func scheduleTimer() {
        countdownTimer?.invalidate()
        guard state == .running else { return }
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard remainingTime > 0 else {
            countdownTimer?.invalidate()
            state = .completed
            delegate?.nextTask(self)
            return
        }
        checkTime()
        animateProgress(to: remainingTime)
    }
    
    private func checkTime() {
        let currentTime = DateManager.shared.getTodayTimeString()
        let currentTimeInSeconds = DateManager.shared.convertToSeconds(currentTime)
        let taskStartTimeInSeconds = DateManager.shared.convertToSeconds(task?.startTime ?? "00:00")
        let elapsed = currentTimeInSeconds - taskStartTimeInSeconds
        
        if elapsed >= 0 {
            remainingTime = CGFloat(elapsed) / CGFloat(task?.duration ?? 0)
        }
    }
    
}

// MARK: - State Handling

extension CurrentTaskView {

    private func handleStateChange() {
        switch state {
        case .running:
            resumeAnimations()
            scheduleTimer()
            UIView.animate(withDuration: 0.3) { self.iconImageView.alpha = 1 }

        case .paused:
            pauseAnimations()
            countdownTimer?.invalidate()
            flashPauseIndicator()

        case .completed:
            countdownTimer?.invalidate()
            animateCompletion()

        case .upcoming:
            break
        }
        applyStatusStyle(for: state, animated: true)
    }

    private func pauseAnimations() {
        let pausedTime              = circleView.layer.convertTime(CACurrentMediaTime(), from: nil)
        circleView.layer.speed      = 0
        circleView.layer.timeOffset = pausedTime
        UIView.animate(withDuration: 0.3) { self.gradientLayer.opacity = 0.4 }
    }

    private func resumeAnimations() {
        let pausedTime              = circleView.layer.timeOffset
        circleView.layer.speed      = 1
        circleView.layer.timeOffset = 0
        circleView.layer.beginTime  = 0
        let timeSincePause = circleView.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        circleView.layer.beginTime = timeSincePause
        UIView.animate(withDuration: 0.3) { self.gradientLayer.opacity = 1 }
    }

    private func flashPauseIndicator() {
        let flash      = CAKeyframeAnimation(keyPath: "opacity")
        flash.values   = [1, 0.3, 1, 0.3, 1]
        flash.keyTimes = [0, 0.2, 0.4, 0.6, 1]
        flash.duration = 0.6
        iconBackgroundView.layer.add(flash, forKey: "flash")
    }

    private func animateCompletion() {
        let scale      = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.values   = [1, 1.15, 0.95, 1.05, 1]
        scale.keyTimes = [0, 0.3,  0.6,  0.8,  1]
        scale.duration = 0.6
        circleView.layer.add(scale, forKey: "completionBounce")
        animateProgress(to: 1)
    }
}

// MARK: - Task Update

extension CurrentTaskView {

    private func updateTask(animated: Bool) {
        guard task != nil else {
            state = .upcoming
            return
        }
        guard animated else {
            buildTaskNameLabel()
            buildTimeLabel()
            return
        }

        UIView.transition(with: taskNameLabel, duration: 0.35, options: .transitionCrossDissolve) {
            self.taskNameLabel.text = self.task?.title ?? ""
        }
        UIView.transition(with: timeLabel, duration: 0.35, options: .transitionCrossDissolve) {
            self.timeLabel.text = "Starts at \(self.task?.startTime ?? "00:00")"
        }

        UIView.animate(withDuration: 0.15, animations: {
            self.iconImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            self.iconImageView.alpha = 0
        }) { _ in
            self.iconImageView.image = UIImage(systemName: "bolt.fill")
            UIView.animate(withDuration: 0.35, delay: 0,
                           usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8) {
                self.iconImageView.transform = .identity
                self.iconImageView.alpha     = 1
            }
        }

        animateProgress(to: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.startCountdown() }
    }
}

// MARK: - Icon Pulse

extension CurrentTaskView {

    private func startPulsingIcon() {
        let pulse          = CAKeyframeAnimation(keyPath: "transform.scale")
        pulse.values       = [1, 1.08, 1]
        pulse.keyTimes     = [0, 0.5,  1]
        pulse.duration     = 2.4
        pulse.repeatCount  = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        iconBackgroundView.layer.add(pulse, forKey: "iconPulse")

        let glowPulse          = CABasicAnimation(keyPath: "shadowOpacity")
        glowPulse.fromValue    = 0.6
        glowPulse.toValue      = 1.0
        glowPulse.duration     = 1.2
        glowPulse.autoreverses = true
        glowPulse.repeatCount  = .infinity
        iconCircleLayer?.add(glowPulse, forKey: "glowPulse")
    }

    func stopPulsingIcon() {
        iconBackgroundView.layer.removeAnimation(forKey: "iconPulse")
        iconCircleLayer?.removeAnimation(forKey: "glowPulse")
    }
}

// MARK: - Cleanup

extension CurrentTaskView {
    override func removeFromSuperview() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        super.removeFromSuperview()
    }
}
