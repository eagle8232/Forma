//
//  RoutineTimelineView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/20/26.
//

import UIKit

// MARK: - Delegate

protocol RoutineTimelineViewDelegate: AnyObject {
    func timelineDidUpdateStart(_ date: Date)
    func timelineDidUpdateEnd(_ date: Date)
}

final class RoutineTimelineView: UIView {

    weak var delegate: RoutineTimelineViewDelegate?

    // MARK: - State

    private(set) var startDate: Date
    private(set) var endDate: Date
    private var tasks: [RoutineTask]

    private let palette: [UIColor] = [
        UIColor(red: 0.40, green: 0.75, blue: 1.00, alpha: 1),
        UIColor(red: 0.55, green: 1.00, blue: 0.75, alpha: 1),
        UIColor(red: 1.00, green: 0.75, blue: 0.40, alpha: 1),
        UIColor(red: 0.80, green: 0.55, blue: 1.00, alpha: 1),
        UIColor(red: 1.00, green: 0.55, blue: 0.55, alpha: 1),
        UIColor(red: 0.55, green: 0.90, blue: 1.00, alpha: 1),
    ]

    // MARK: - Track

    private let trackContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 1, alpha: 0.06)
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        return v
    }()

    private var segmentViews: [UIView] = []

    // MARK: - Bubbles (above track)

    private var taskBubbles: [UIView] = []
    private let bubblesContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - Bottom row: [startLabel]  [durationLabel]  [endLabel]

    private lazy var startTimeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold)
        b.setTitleColor(.textSecondary, for: .normal)
        b.contentHorizontalAlignment = .left
        // Subtle underline hint to show it's tappable
        b.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        return b
    }()

    private lazy var endTimeButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.titleLabel?.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold)
        b.setTitleColor(.textSecondary, for: .normal)
        b.contentHorizontalAlignment = .right
        b.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
        return b
    }()

    private let durationLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(white: 1, alpha: 0.35)
        l.textAlignment = .center
        return l
    }()

    // MARK: - Picker proxies

    private lazy var startPickerProxy: FormaTimePickerView = {
        let p = FormaTimePickerView(type: .wakeTime)
        p.isHidden = true
        p.delegate = self
        p.setTime(startDate)
        return p
    }()

    private lazy var endPickerProxy: FormaTimePickerView = {
        let p = FormaTimePickerView(type: .sleepTime)
        p.isHidden = true
        p.delegate = self
        p.setTime(endDate)
        return p
    }()

    // MARK: - Init

    init(startDate: Date, endDate: Date, tasks: [RoutineTask] = []) {
        self.startDate = startDate
        self.endDate   = endDate
        self.tasks     = tasks
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
        refreshBottomRow()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func setTasks(_ tasks: [RoutineTask]) {
        self.tasks = tasks
        setNeedsLayout()
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        guard trackContainer.bounds.width > 0 else { return }
        rebuildSegments()
        rebuildBubbles()
    }

    // MARK: - Setup

    private func setup() {
        addSubview(bubblesContainer)
        addSubview(trackContainer)
        addSubview(startTimeButton)
        addSubview(durationLabel)
        addSubview(endTimeButton)
        addSubview(startPickerProxy)
        addSubview(endPickerProxy)

        NSLayoutConstraint.activate([
            // Bubbles above track
            bubblesContainer.topAnchor.constraint(equalTo: topAnchor),
            bubblesContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bubblesContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bubblesContainer.heightAnchor.constraint(equalToConstant: 26),

            // Track
            trackContainer.topAnchor.constraint(equalTo: bubblesContainer.bottomAnchor, constant: 8),
            trackContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackContainer.heightAnchor.constraint(equalToConstant: 32),

            // Bottom row: start | duration | end
            startTimeButton.topAnchor.constraint(equalTo: trackContainer.bottomAnchor, constant: 10),
            startTimeButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            startTimeButton.bottomAnchor.constraint(equalTo: bottomAnchor),

            durationLabel.centerYAnchor.constraint(equalTo: startTimeButton.centerYAnchor),
            durationLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            endTimeButton.topAnchor.constraint(equalTo: trackContainer.bottomAnchor, constant: 10),
            endTimeButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            endTimeButton.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    // MARK: - Segments

    private var windowMinutes: Double {
        max(endDate.timeIntervalSince(startDate) / 60, 1)
    }

    private func rebuildSegments() {
        segmentViews.forEach { $0.removeFromSuperview() }
        segmentViews = []

        let totalW  = trackContainer.bounds.width
        let totalH  = trackContainer.bounds.height
        let window  = windowMinutes
        var usedW: CGFloat = 0
        let valid   = tasks.filter { !$0.title.isEmpty }

        for (i, task) in valid.enumerated() {
            let mins      = task.duration / 60
            let fraction  = CGFloat(min(Double(mins) / window, 1.0))
            let w         = min(fraction * totalW, totalW - usedW)
            guard w > 0 else { break }

            let color = palette[i % palette.count]

            let segment = UIView()
            segment.clipsToBounds = true

            // Corner masking
            var mask: CACornerMask = []
            if usedW == 0 { mask.formUnion([.layerMinXMinYCorner, .layerMinXMaxYCorner]) }
            let isLast = i == valid.count - 1 || usedW + w >= totalW - 0.5
            if isLast { mask.formUnion([.layerMaxXMinYCorner, .layerMaxXMaxYCorner]) }
            segment.layer.cornerRadius = 10
            segment.layer.maskedCorners = mask

            // Gradient fill
            let grad = CAGradientLayer()
            grad.colors   = [color.withAlphaComponent(0.9).cgColor, color.withAlphaComponent(0.6).cgColor]
            grad.startPoint = CGPoint(x: 0, y: 0)
            grad.endPoint   = CGPoint(x: 1, y: 0)
            grad.frame    = CGRect(x: 0, y: 0, width: w, height: totalH)
            grad.cornerRadius = 10
            grad.maskedCorners = mask
            segment.layer.insertSublayer(grad, at: 0)

            // Separator
            if usedW > 0 {
                let sep = UIView(frame: CGRect(x: 0, y: 0, width: 1.5, height: totalH))
                sep.backgroundColor = UIColor(white: 0, alpha: 0.35)
                segment.addSubview(sep)
            }

            // Duration label inside segment (only if wide enough)
            let durText = mins > 0 ? DurationFormatter.formatCompact(Double(mins)) : ""
            if w > 22 && !durText.isEmpty {
                let lbl = UILabel()
                lbl.text = durText
                lbl.font = UIFont.monospacedSystemFont(ofSize: 9, weight: .bold)
                lbl.textColor = UIColor(white: 0, alpha: 0.55)
                lbl.textAlignment = .left
                lbl.frame = CGRect(x: 2, y: 0, width: w - 15, height: totalH-15)
                lbl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                lbl.adjustsFontSizeToFitWidth = true
                lbl.minimumScaleFactor = 0.3
                segment.addSubview(lbl)
            }

            segment.frame = CGRect(x: usedW, y: 0, width: w, height: totalH)
            trackContainer.insertSubview(segment, at: 0)
            segmentViews.append(segment)

            usedW += w
        }
    }

    // MARK: - Bubbles

    private func rebuildBubbles() {
        taskBubbles.forEach { $0.removeFromSuperview() }
        taskBubbles = []

        let totalW = bubblesContainer.bounds.width
        let window = windowMinutes
        let valid  = tasks.filter { !$0.title.isEmpty }
        guard totalW > 0, !valid.isEmpty else { return }

        let size: CGFloat = 22
        var usedMins: Double = 0

        for (i, task) in valid.enumerated() {
            let mins = task.duration / 60
            let midFrac = CGFloat((usedMins + Double(mins / 2)) / window)
            let xCenter = midFrac * totalW
            let x = min(max(xCenter - size / 2, 0), totalW - size)
            let y = (bubblesContainer.bounds.height - size) / 2

            let color  = palette[i % palette.count]
            let bubble = makeBubble(number: i + 1, color: color)
            bubble.frame = CGRect(x: x, y: y, width: size, height: size)
            bubblesContainer.addSubview(bubble)
            taskBubbles.append(bubble)

            usedMins += Double(mins)
            if usedMins >= window { break }
        }
    }

    private func makeBubble(number: Int, color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = color.withAlphaComponent(0.20)
        v.layer.cornerRadius = 11
        v.layer.borderWidth = 1.5
        v.layer.borderColor = color.withAlphaComponent(0.70).cgColor
        v.isUserInteractionEnabled = false

        let l = UILabel()
        l.text = "\(number)"
        l.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .bold)
        l.textColor = color
        l.textAlignment = .center
        l.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
        v.addSubview(l)
        return v
    }

    // MARK: - Bottom row update

    private func refreshBottomRow() {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"

        // Start button: underlined to hint tappability
        let startStr = fmt.string(from: startDate)
        let startAttr = NSAttributedString(string: startStr, attributes: [
            .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.textSecondary,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.textSecondary.withAlphaComponent(0.4)
        ])
        startTimeButton.setAttributedTitle(startAttr, for: .normal)

        let endStr = fmt.string(from: endDate)
        let endAttr = NSAttributedString(string: endStr, attributes: [
            .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.textSecondary,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.textSecondary.withAlphaComponent(0.4)
        ])
        endTimeButton.setAttributedTitle(endAttr, for: .normal)

        // Centre duration
        let totalMins = Int(max(endDate.timeIntervalSince(startDate) / 60, 0))
        let h = totalMins / 60, m = totalMins % 60
        switch (h, m) {
        case (0, let m): durationLabel.text = "\(m) mins"
        case (let h, 0): durationLabel.text = "\(h) " + "\(h == 1 ? "hr" : "hrs")"
        default:         durationLabel.text = "\(h) " + "\(h == 1 ? "hr" : "hrs") \(m) min"
        }
    }

    // MARK: - Actions

    @objc private func startTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        animateButton(startTimeButton)
        startPickerProxy.showPicker()
    }

    @objc private func endTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        animateButton(endTimeButton)
        endPickerProxy.showPicker()
    }

    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
            button.alpha = 0.6
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                button.transform = .identity
                button.alpha = 1
            }
        }
    }
}

// MARK: - FormaTimePickerDelegate

extension RoutineTimelineView: FormaTimePickerDelegate {
    func timePickerDidSelectTime(_ picker: FormaTimePickerView, date: Date) {
        if picker === startPickerProxy {
            startDate = date
            delegate?.timelineDidUpdateStart(date)
        } else {
            endDate = date
            delegate?.timelineDidUpdateEnd(date)
        }
        refreshBottomRow()
        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        // Bounce duration label
        UIView.animate(withDuration: 0.1, animations: {
            self.durationLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.35, delay: 0,
                           usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
                self.durationLabel.transform = .identity
            }
        }
    }
}

