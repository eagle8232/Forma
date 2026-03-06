//
//  TasksInfoView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/25/26.
//



// ------------------ Will Be Refactored ------------------

import UIKit

enum CellTaskState {
    case upcoming
    case running
    case completed

    var contentAlpha: CGFloat {
        switch self {
        case .upcoming:  return 0.55
        case .running:   return 1.0
        case .completed: return 0.35
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
        }
    }

    var borderColor: CGColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.06).cgColor
        case .running:   return UIColor.accent.withAlphaComponent(0.35).cgColor
        case .completed: return UIColor.white.withAlphaComponent(0.03).cgColor
        }
    }

    var iconTint: UIColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.25)
        case .running:   return UIColor.accent
        case .completed: return UIColor.white.withAlphaComponent(0.15)
        }
    }

    var badgeAccentColor: UIColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.3)
        case .running:   return UIColor.accent
        case .completed: return UIColor.systemGreen
        }
    }

    var badgeText: String {
        switch self {
        case .upcoming:  return "upcoming"
        case .running:   return "now"
        case .completed: return "done"
        }
    }

    var titleColor: UIColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.45)
        case .running:   return UIColor.white
        case .completed: return UIColor.white.withAlphaComponent(0.2)
        }
    }

    var timeColor: UIColor {
        switch self {
        case .upcoming:  return UIColor.white.withAlphaComponent(0.2)
        case .running:   return UIColor.accent.withAlphaComponent(0.8)
        case .completed: return UIColor.white.withAlphaComponent(0.12)
        }
    }
}

// MARK: - TaskInfoViewCell

final class TaskInfoViewCell: UICollectionViewCell {

    // MARK: - Identifier

    static let identifier: String = "taskInfoCell"

    // MARK: - UI Components

    private lazy var taskContainerView  = UIView()
    private lazy var iconContainerView  = UIView()
    private lazy var iconImageView      = UIImageView()
    private lazy var taskTitleLabel     = UILabel()
    private lazy var clockIconImageView = UIImageView()
    private lazy var startTimeLabel     = UILabel()
    private lazy var chevronView        = UIView()
    private lazy var chevronImageView   = UIImageView()
    private lazy var badgePillView      = UIView()
    private lazy var badgeDotView       = UIView()
    private lazy var badgeLabel         = UILabel()

    // MARK: - Layers

    private var gradientLayer   = CAGradientLayer()
    private var borderLayer     = CAShapeLayer()
    private var iconCircleLayer = CAShapeLayer()
    private var glowLayer       = CALayer()
    private var shimmerLayer    = CAGradientLayer()
    private var strikeLayer     = CAShapeLayer()

    // MARK: - State

    private var isLayedOut    = false
    private var currentState: TaskState = .upcoming

    override var isSelected: Bool {
        didSet { animateSelection(isSelected) }
    }

    override var isHighlighted: Bool {
        didSet { animateHighlight(isHighlighted) }
    }

    var task: RoutineTask? {
        didSet { updateContent() }
    }

    var taskState: TaskState = .upcoming {
        didSet {
            currentState = taskState
            applyState(animated: isLayedOut)
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.alpha = 0
        layoutViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Pass

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isLayedOut else { return }
        guard !taskContainerView.bounds.isEmpty else { return }
        isLayedOut = true

        buildTaskContainerView()
        buildIconView()
        buildChevronView()
        buildTitlesAndClockIcon()
        buildBadgePill()
        buildStrikeLayer()
        applyState(animated: false)
        runEntryAnimation()
    }

    // MARK: - View Hierarchy

    private func layoutViews() {
        taskContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(taskContainerView)
        NSLayoutConstraint.activate([
            taskContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            taskContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            taskContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            taskContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        [iconContainerView, iconImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        taskContainerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconContainerView.centerYAnchor.constraint(equalTo: taskContainerView.centerYAnchor),
            iconContainerView.leadingAnchor.constraint(equalTo: taskContainerView.leadingAnchor, constant: 14),
            iconContainerView.widthAnchor.constraint(equalToConstant: 44),
            iconContainerView.heightAnchor.constraint(equalToConstant: 44),

            iconImageView.topAnchor.constraint(equalTo: iconContainerView.topAnchor, constant: 11),
            iconImageView.leadingAnchor.constraint(equalTo: iconContainerView.leadingAnchor, constant: 11),
            iconImageView.trailingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: -11),
            iconImageView.bottomAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: -11),
        ])

        chevronView.translatesAutoresizingMaskIntoConstraints  = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        taskContainerView.addSubview(chevronView)
        chevronView.addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            chevronView.centerYAnchor.constraint(equalTo: taskContainerView.centerYAnchor),
            chevronView.trailingAnchor.constraint(equalTo: taskContainerView.trailingAnchor, constant: -14),
            chevronView.widthAnchor.constraint(equalToConstant: 30),
            chevronView.heightAnchor.constraint(equalToConstant: 30),

            chevronImageView.centerXAnchor.constraint(equalTo: chevronView.centerXAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: chevronView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12),
        ])

        // Badge pill sits between labels and chevron
        badgePillView.translatesAutoresizingMaskIntoConstraints = false
        badgeDotView.translatesAutoresizingMaskIntoConstraints  = false
        badgeLabel.translatesAutoresizingMaskIntoConstraints    = false
        badgePillView.addSubview(badgeDotView)
        badgePillView.addSubview(badgeLabel)
        taskContainerView.addSubview(badgePillView)

        NSLayoutConstraint.activate([
            badgePillView.centerYAnchor.constraint(equalTo: taskContainerView.centerYAnchor),
            badgePillView.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -8),

            badgeDotView.leadingAnchor.constraint(equalTo: badgePillView.leadingAnchor, constant: 8),
            badgeDotView.centerYAnchor.constraint(equalTo: badgePillView.centerYAnchor),
            badgeDotView.widthAnchor.constraint(equalToConstant: 5),
            badgeDotView.heightAnchor.constraint(equalToConstant: 5),

            badgeLabel.leadingAnchor.constraint(equalTo: badgeDotView.trailingAnchor, constant: 5),
            badgeLabel.trailingAnchor.constraint(equalTo: badgePillView.trailingAnchor, constant: -8),
            badgeLabel.topAnchor.constraint(equalTo: badgePillView.topAnchor, constant: 4),
            badgeLabel.bottomAnchor.constraint(equalTo: badgePillView.bottomAnchor, constant: -4),
        ])

        let timeStack = UIStackView(arrangedSubviews: [clockIconImageView, startTimeLabel])
        timeStack.axis      = .horizontal
        timeStack.spacing   = 5
        timeStack.alignment = .center

        [taskTitleLabel, timeStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            taskContainerView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            taskTitleLabel.topAnchor.constraint(equalTo: taskContainerView.topAnchor, constant: 16),
            taskTitleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),
            taskTitleLabel.trailingAnchor.constraint(equalTo: badgePillView.leadingAnchor, constant: -8),

            timeStack.topAnchor.constraint(equalTo: taskTitleLabel.bottomAnchor, constant: 5),
            timeStack.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 12),

            clockIconImageView.widthAnchor.constraint(equalToConstant: 11),
            clockIconImageView.heightAnchor.constraint(equalToConstant: 11),
        ])

        // Immediate styling so nothing floats unstyled
        taskTitleLabel.font          = UIFont.typography(.bodyMedium)
        taskTitleLabel.textColor     = UIColor.textPrimary
        taskTitleLabel.numberOfLines = 1

        startTimeLabel.font      = UIFont.typography(.caption)
        startTimeLabel.textColor = UIColor.contentTertiary

        iconImageView.tintColor   = UIColor.accent
        iconImageView.contentMode = .scaleAspectFit

        chevronImageView.tintColor   = UIColor.white.withAlphaComponent(0.3)
        chevronImageView.contentMode = .scaleAspectFit
    }
}

// MARK: - Build Layers

extension TaskInfoViewCell {

    private func buildTaskContainerView() {
        let rect         = taskContainerView.bounds
        let cornerRadius = rect.height / 2

        taskContainerView.layer.cornerRadius  = cornerRadius
        taskContainerView.layer.masksToBounds = false
        taskContainerView.clipsToBounds       = false

        glowLayer.backgroundColor = UIColor.clear.cgColor
        glowLayer.cornerRadius    = cornerRadius + 2
        glowLayer.shadowColor     = UIColor.accent.cgColor
        glowLayer.shadowRadius    = 14
        glowLayer.shadowOpacity   = 0
        glowLayer.shadowOffset    = .zero
        glowLayer.frame           = rect.insetBy(dx: -2, dy: -2)
        taskContainerView.layer.insertSublayer(glowLayer, at: 0)

        gradientLayer.colors       = currentState.gradientColors
        gradientLayer.startPoint   = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint     = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.frame        = rect
        taskContainerView.layer.insertSublayer(gradientLayer, at: 0)

        shimmerLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.04).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor,
        ]
        shimmerLayer.locations    = [0, 0.5, 1]
        shimmerLayer.startPoint   = CGPoint(x: 0, y: 0)
        shimmerLayer.endPoint     = CGPoint(x: 1, y: 0)
        shimmerLayer.frame        = CGRect(x: 0, y: 0, width: rect.width, height: rect.height * 0.5)
        shimmerLayer.cornerRadius = cornerRadius
        taskContainerView.layer.addSublayer(shimmerLayer)

        let borderPath          = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        borderLayer.path        = borderPath.cgPath
        borderLayer.fillColor   = UIColor.clear.cgColor
        borderLayer.strokeColor = currentState.borderColor
        borderLayer.lineWidth   = 0.5
        borderLayer.frame       = rect
        taskContainerView.layer.addSublayer(borderLayer)
    }

    private func buildIconView() {
        iconContainerView.backgroundColor = .clear
        let rect   = iconContainerView.bounds
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        let ringPath          = UIBezierPath(arcCenter: center, radius: radius,
                                             startAngle: 0, endAngle: .pi * 2, clockwise: true)
        let ringLayer         = CAShapeLayer()
        ringLayer.path        = ringPath.cgPath
        ringLayer.fillColor   = UIColor(red: 16/255, green: 16/255, blue: 24/255, alpha: 1).cgColor
        ringLayer.strokeColor = UIColor.white.withAlphaComponent(0.07).cgColor
        ringLayer.lineWidth   = 0.5
        ringLayer.frame       = rect
        iconContainerView.layer.insertSublayer(ringLayer, at: 0)
        iconCircleLayer = ringLayer

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iconImageView.preferredSymbolConfiguration = symbolConfig
        iconImageView.image = UIImage(
            systemName: "dot.radiowaves.left.and.right",
            withConfiguration: symbolConfig
        )
    }

    private func buildChevronView() {
        chevronView.backgroundColor = .clear
        let rect = chevronView.bounds

        let circlePath          = UIBezierPath(ovalIn: rect)
        let circleLayer         = CAShapeLayer()
        circleLayer.path        = circlePath.cgPath
        circleLayer.fillColor   = UIColor.white.withAlphaComponent(0.03).cgColor
        circleLayer.strokeColor = UIColor.white.withAlphaComponent(0.06).cgColor
        circleLayer.lineWidth   = 0.5
        circleLayer.frame       = rect
        chevronView.layer.addSublayer(circleLayer)

        let config             = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        chevronImageView.image = UIImage(systemName: "chevron.right", withConfiguration: config)
    }

    private func buildTitlesAndClockIcon() {
        let clockConfig          = UIImage.SymbolConfiguration(pointSize: 9, weight: .medium)
        clockIconImageView.image = UIImage(systemName: "clock.fill", withConfiguration: clockConfig)
        clockIconImageView.tintColor   = UIColor.contentTertiary
        clockIconImageView.contentMode = .scaleAspectFit
    }

    private func buildBadgePill() {
        badgePillView.layer.cornerRadius = 8
        badgePillView.clipsToBounds      = false
        badgeDotView.layer.cornerRadius  = 2.5
        badgeLabel.font      = UIFont.monospacedSystemFont(ofSize: 10, weight: .semibold)
        badgeLabel.textColor = UIColor.white
    }

    private func buildStrikeLayer() {
        strikeLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        strikeLayer.lineWidth   = 1
        strikeLayer.opacity     = 0
        strikeLayer.strokeEnd   = 0
        taskTitleLabel.layer.addSublayer(strikeLayer)
    }
}

// MARK: - State Application

extension TaskInfoViewCell {

    private func applyState(animated: Bool) {
        let state    = currentState
        let duration = animated ? 0.35 : 0.0

        // Alpha
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            self.contentView.alpha = state.contentAlpha
        }

        // Gradient
        let colorsAnim                   = CABasicAnimation(keyPath: "colors")
        colorsAnim.toValue               = state.gradientColors
        colorsAnim.duration              = duration
        colorsAnim.fillMode              = .forwards
        colorsAnim.isRemovedOnCompletion = false
        gradientLayer.add(colorsAnim, forKey: "stateGradient")
        gradientLayer.colors = state.gradientColors

        // Border
        let borderAnim                   = CABasicAnimation(keyPath: "strokeColor")
        borderAnim.toValue               = state.borderColor
        borderAnim.duration              = duration
        borderAnim.fillMode              = .forwards
        borderAnim.isRemovedOnCompletion = false
        borderLayer.add(borderAnim, forKey: "stateBorder")
        borderLayer.strokeColor = state.borderColor

        // Icon + labels
        UIView.animate(withDuration: duration) {
            self.iconImageView.tintColor    = state.iconTint
            self.taskTitleLabel.textColor   = state.titleColor
            self.startTimeLabel.textColor   = state.timeColor
            self.clockIconImageView.tintColor = state.timeColor
            self.chevronView.alpha          = state == .completed ? 0 : 1
        }

        // Badge
        applyBadge(for: state, animated: animated)

        // Strike-through
        applyStrike(for: state, animated: animated)

        // Glow pulse only while running
        if state == .running {
            glowLayer.shadowOpacity = 0.2
            startGlowPulse()
        } else {
            stopGlowPulse()
            let fade                   = CABasicAnimation(keyPath: "shadowOpacity")
            fade.toValue               = Float(0)
            fade.duration              = duration
            fade.fillMode              = .forwards
            fade.isRemovedOnCompletion = false
            glowLayer.add(fade, forKey: "fadeGlow")
            glowLayer.shadowOpacity = 0
        }
    }

    // MARK: - Badge

    private func applyBadge(for state: TaskState, animated: Bool) {
        let color = state.badgeAccentColor
        let apply: () -> Void = {
            self.badgePillView.backgroundColor      = color.withAlphaComponent(0.12)
            self.badgePillView.layer.borderColor    = color.withAlphaComponent(0.25).cgColor
            self.badgePillView.layer.borderWidth    = 0.5
            self.badgePillView.clipsToBounds        = true
            self.badgeDotView.backgroundColor       = color
            self.badgeDotView.layer.shadowColor     = color.cgColor
            self.badgeDotView.layer.shadowRadius    = 4
            self.badgeDotView.layer.shadowOpacity   = state == .running ? 1.0 : 0
            self.badgeDotView.layer.shadowOffset    = .zero
            self.badgeLabel.text      = state.badgeText
            self.badgeLabel.textColor = color
        }

        if animated {
            UIView.transition(with: badgePillView, duration: 0.3,
                              options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }

        // Dot pulse only for running
        badgeDotView.layer.removeAllAnimations()
        if state == .running {
            let pulse            = CABasicAnimation(keyPath: "opacity")
            pulse.fromValue      = 1.0
            pulse.toValue        = 0.25
            pulse.duration       = 0.75
            pulse.autoreverses   = true
            pulse.repeatCount    = .infinity
            pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            badgeDotView.layer.add(pulse, forKey: "dotPulse")
        }
    }

    // MARK: - Strike-through

    private func applyStrike(for state: TaskState, animated: Bool) {
        taskTitleLabel.layoutIfNeeded()
        let labelWidth = taskTitleLabel.intrinsicContentSize.width
        let midY       = taskTitleLabel.bounds.midY

        let path = UIBezierPath()
        path.move(to:    CGPoint(x: 0,          y: midY))
        path.addLine(to: CGPoint(x: labelWidth, y: midY))
        strikeLayer.path = path.cgPath

        if state == .completed {
            strikeLayer.opacity = 1
            if animated {
                let draw            = CABasicAnimation(keyPath: "strokeEnd")
                draw.fromValue      = 0
                draw.toValue        = 1
                draw.duration       = 0.45
                draw.timingFunction = CAMediaTimingFunction(name: .easeOut)
                strikeLayer.add(draw, forKey: "strikeAnim")
            }
            strikeLayer.strokeEnd = 1
        } else {
            strikeLayer.opacity   = 0
            strikeLayer.strokeEnd = 0
        }
    }

    // MARK: - Glow Pulse

    private func startGlowPulse() {
        guard glowLayer.animation(forKey: "glowPulse") == nil else { return }
        let pulse            = CABasicAnimation(keyPath: "shadowOpacity")
        pulse.fromValue      = Float(0.0)
        pulse.toValue        = Float(0.35)
        pulse.duration       = 1.8
        pulse.autoreverses   = true
        pulse.repeatCount    = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        glowLayer.add(pulse, forKey: "glowPulse")
    }

    private func stopGlowPulse() {
        glowLayer.removeAnimation(forKey: "glowPulse")
    }
}

// MARK: - Content Update

extension TaskInfoViewCell {

    private func updateContent() {
        taskTitleLabel.text = task?.title
        startTimeLabel.text = task?.startTime

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        iconImageView.image = UIImage(
            systemName: "dot.radiowaves.left.and.right",
            withConfiguration: symbolConfig
        )

        guard isLayedOut else { return }
        animateContentSwap()
    }

    private func animateContentSwap() {
        UIView.transition(with: taskTitleLabel, duration: 0.25, options: .transitionCrossDissolve) {
            self.taskTitleLabel.text = self.task?.title
        }
        UIView.transition(with: startTimeLabel, duration: 0.25, options: .transitionCrossDissolve) {
            self.startTimeLabel.text = self.task?.startTime
        }

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        UIView.animate(withDuration: 0.12, animations: {
            self.iconImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.iconImageView.alpha     = 0
        }) { _ in
            self.iconImageView.image = UIImage(
                systemName: "dot.radiowaves.left.and.right",
                withConfiguration: symbolConfig
            )
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
                self.iconImageView.transform = .identity
                self.iconImageView.alpha     = 1
            }
        }
    }
}

// MARK: - Animations

extension TaskInfoViewCell {

    private func runEntryAnimation() {
        contentView.transform = CGAffineTransform(translationX: 0, y: 10)
        UIView.animate(withDuration: 0.45, delay: 0,
                       usingSpringWithDamping: 0.75, initialSpringVelocity: 0.4) {
            self.contentView.alpha     = self.currentState.contentAlpha
            self.contentView.transform = .identity
        }
    }

    private func animateSelection(_ selected: Bool) {
        guard currentState != .completed else { return }

        let borderColor = selected
            ? UIColor.accent.withAlphaComponent(0.7).cgColor
            : currentState.borderColor

        let borderAnim                   = CABasicAnimation(keyPath: "strokeColor")
        borderAnim.toValue               = borderColor
        borderAnim.duration              = 0.25
        borderAnim.fillMode              = .forwards
        borderAnim.isRemovedOnCompletion = false
        borderLayer.add(borderAnim, forKey: "selectionBorder")
        borderLayer.strokeColor = borderColor

        let glowAnim                   = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnim.toValue               = selected ? Float(0.4) : Float(0)
        glowAnim.duration              = 0.3
        glowAnim.fillMode              = .forwards
        glowAnim.isRemovedOnCompletion = false
        glowLayer.add(glowAnim, forKey: "selectionGlow")
        glowLayer.shadowOpacity = selected ? 0.4 : 0

        UIView.animate(withDuration: 0.25) {
            self.chevronImageView.tintColor = selected
                ? UIColor.accent.withAlphaComponent(0.9)
                : UIColor.white.withAlphaComponent(0.3)
        }

        if selected {
            UIView.animate(withDuration: 0.18, animations: {
                self.chevronImageView.transform = CGAffineTransform(translationX: 3, y: 0)
            }) { _ in
                UIView.animate(withDuration: 0.22, delay: 0,
                               usingSpringWithDamping: 0.5, initialSpringVelocity: 1.2) {
                    self.chevronImageView.transform = .identity
                }
            }
        }
    }

    private func animateHighlight(_ highlighted: Bool) {
        guard currentState != .completed else { return }
        UIView.animate(withDuration: 0.15, delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.taskContainerView.transform = highlighted
                ? CGAffineTransform(scaleX: 0.97, y: 0.97)
                : .identity
            self.contentView.alpha = highlighted
                ? self.currentState.contentAlpha * 0.7
                : self.currentState.contentAlpha
        }
    }
}

// MARK: - Reuse

extension TaskInfoViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()

        taskTitleLabel.text  = nil
        startTimeLabel.text  = nil
        iconImageView.image  = nil
        isLayedOut           = false
        currentState         = .upcoming

        stopGlowPulse()
        badgeDotView.layer.removeAllAnimations()
        strikeLayer.removeFromSuperlayer()

        borderLayer.removeFromSuperlayer()
        gradientLayer.removeFromSuperlayer()
        shimmerLayer.removeFromSuperlayer()
        glowLayer.removeFromSuperlayer()
        iconCircleLayer.removeFromSuperlayer()

        borderLayer     = CAShapeLayer()
        gradientLayer   = CAGradientLayer()
        shimmerLayer    = CAGradientLayer()
        glowLayer       = CALayer()
        iconCircleLayer = CAShapeLayer()
        strikeLayer     = CAShapeLayer()

        contentView.alpha           = 0
        contentView.transform       = .identity
        taskContainerView.transform = .identity
        chevronView.alpha           = 1
    }
}
