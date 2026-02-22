//
//  RoutineTimelineView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/20/26.
//

//
//  RoutineTimelineView.swift
//  Forma
//

import UIKit

// MARK: - Delegate

protocol RoutineTimelineViewDelegate: AnyObject {
    func timelineDidUpdateStart(_ date: Date)
    func timelineDidUpdateEnd(_ date: Date)
}

// MARK: - RoutineTimelineView

final class RoutineTimelineView: UIView {

    weak var delegate: RoutineTimelineViewDelegate?

    // MARK: - State

    private(set) var startDate: Date
    private(set) var endDate: Date
    private var tasks: [RoutineTask]

    // Palette for task segments — cycles if more tasks than colors
    private let palette: [UIColor] = [
        UIColor(red: 0.40, green: 0.75, blue: 1.00, alpha: 1),   // sky blue
        UIColor(red: 0.55, green: 1.00, blue: 0.75, alpha: 1),   // mint
        UIColor(red: 1.00, green: 0.75, blue: 0.40, alpha: 1),   // amber
        UIColor(red: 0.80, green: 0.55, blue: 1.00, alpha: 1),   // lavender
        UIColor(red: 1.00, green: 0.55, blue: 0.55, alpha: 1),   // coral
        UIColor(red: 0.55, green: 0.90, blue: 1.00, alpha: 1),   // cyan
    ]

    // MARK: - Track

    /// The full-width track container (clips children)
    private let trackContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 1, alpha: 0.06)
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        return v
    }()

    /// Segments are added here as subviews, laid out manually in layoutSubviews
    private var segmentViews: [UIView] = []

    // MARK: - Task number bubbles (above track, non-interactive)

    private var taskBubbles: [UIView] = []
    private let bubblesContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isUserInteractionEnabled = false
        return v
    }()

    // MARK: - Time labels (below track)

    private let timeRangeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        l.textColor = .textSecondary
        l.textAlignment = .center
        return l
    }()

    // MARK: - Hidden picker proxies

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

    // Tap areas for start/end (invisible, sit over track ends)
    private lazy var startTapZone: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .clear
        b.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        return b
    }()

    private lazy var endTapZone: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = .clear
        b.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
        return b
    }()

    // MARK: - Init

    init(startDate: Date, endDate: Date, tasks: [RoutineTask] = []) {
        self.startDate = startDate
        self.endDate   = endDate
        self.tasks     = tasks
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
        updateTimeLabel()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func setTasks(_ tasks: [RoutineTask]) {
        self.tasks = tasks
        setNeedsLayout()
    }

    func updateDates(start: Date, end: Date) {
        startDate = start
        endDate   = end
        startPickerProxy.setTime(start)
        endPickerProxy.setTime(end)
        updateTimeLabel()
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
        addSubview(timeRangeLabel)
        addSubview(startTapZone)
        addSubview(endTapZone)
        addSubview(startPickerProxy)
        addSubview(endPickerProxy)

        let trackH: CGFloat = 18

        NSLayoutConstraint.activate([
            // Bubbles sit above track
            bubblesContainer.topAnchor.constraint(equalTo: topAnchor),
            bubblesContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bubblesContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bubblesContainer.heightAnchor.constraint(equalToConstant: 26),

            // Track
            trackContainer.topAnchor.constraint(equalTo: bubblesContainer.bottomAnchor, constant: 8),
            trackContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackContainer.heightAnchor.constraint(equalToConstant: trackH),

            // Time label below track
            timeRangeLabel.topAnchor.constraint(equalTo: trackContainer.bottomAnchor, constant: 10),
            timeRangeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeRangeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            timeRangeLabel.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Tap zones over left/right thirds of track
            startTapZone.leadingAnchor.constraint(equalTo: trackContainer.leadingAnchor),
            startTapZone.topAnchor.constraint(equalTo: trackContainer.topAnchor),
            startTapZone.bottomAnchor.constraint(equalTo: trackContainer.bottomAnchor),
            startTapZone.widthAnchor.constraint(equalTo: trackContainer.widthAnchor, multiplier: 0.25),

            endTapZone.trailingAnchor.constraint(equalTo: trackContainer.trailingAnchor),
            endTapZone.topAnchor.constraint(equalTo: trackContainer.topAnchor),
            endTapZone.bottomAnchor.constraint(equalTo: trackContainer.bottomAnchor),
            endTapZone.widthAnchor.constraint(equalTo: trackContainer.widthAnchor, multiplier: 0.25),
        ])
    }

    // MARK: - Segments

    /// Total routine window in minutes
    private var windowMinutes: Double {
        let diff = endDate.timeIntervalSince(startDate)
        return max(diff / 60, 1)
    }

    /// Parses a duration string like "40 min", "1 hr", "1 hr 30 min" → minutes
    private func minutes(from duration: String) -> Double {
        let s = duration.lowercased()
        var total = 0.0
        if let range = s.range(of: #"(\d+)\s*hr"#, options: .regularExpression) {
            total += Double(s[range].filter(\.isNumber)) ?? 0
            total *= 60
        }
        if let range = s.range(of: #"(\d+)\s*min"#, options: .regularExpression) {
            total += Double(s[range].filter(\.isNumber)) ?? 0
        }
        if total == 0, let plain = Double(s.filter(\.isNumber)) {
            total = plain // bare number treated as minutes
        }
        return max(total, 0)
    }

    private func rebuildSegments() {
        segmentViews.forEach { $0.removeFromSuperview() }
        segmentViews = []

        let totalWidth  = trackContainer.bounds.width
        let totalHeight = trackContainer.bounds.height
        let window      = windowMinutes

        // Calculate each task's width fraction
        var usedWidth: CGFloat = 0

        let validTasks = tasks.filter { !$0.title.isEmpty }

        for (index, task) in validTasks.enumerated() {
            let mins     = minutes(from: task.duration)
            let fraction = CGFloat(min(mins / window, 1.0))
            let width    = fraction * totalWidth

            // Don't overflow the track
            let clampedWidth = min(width, totalWidth - usedWidth)
            guard clampedWidth > 0 else { break }

            let color = palette[index % palette.count]

            let segment = UIView()
            segment.backgroundColor = color.withAlphaComponent(0.85)

            // Left-most gets rounded left corners, right-most (or last segment touching right edge) gets rounded right
            var maskedCorners: CACornerMask = []
            if usedWidth == 0 {
                maskedCorners.formUnion([.layerMinXMinYCorner, .layerMinXMaxYCorner])
            }
            let isLast = index == validTasks.count - 1 || usedWidth + clampedWidth >= totalWidth
            if isLast {
                maskedCorners.formUnion([.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
            }
            segment.layer.cornerRadius = 10
            segment.layer.maskedCorners = maskedCorners
            segment.clipsToBounds = true

            // Subtle inner gradient for depth
            let grad = CAGradientLayer()
            grad.colors = [color.cgColor, color.withAlphaComponent(0.6).cgColor]
            grad.startPoint = CGPoint(x: 0, y: 0)
            grad.endPoint   = CGPoint(x: 1, y: 0)
            grad.cornerRadius = 10
            grad.maskedCorners = maskedCorners
            grad.frame = CGRect(x: 0, y: 0, width: clampedWidth, height: totalHeight)
            segment.layer.insertSublayer(grad, at: 0)

            // Thin separator line between segments (not on first)
            if usedWidth > 0 {
                let sep = UIView()
                sep.backgroundColor = UIColor(white: 0, alpha: 0.3)
                sep.frame = CGRect(x: 0, y: 0, width: 1, height: totalHeight)
                segment.addSubview(sep)
            }

            segment.frame = CGRect(x: usedWidth, y: 0, width: clampedWidth, height: totalHeight)
            trackContainer.insertSubview(segment, at: 0)
            segmentViews.append(segment)

            usedWidth += clampedWidth
        }
    }

    // MARK: - Bubbles

    private func rebuildBubbles() {
        taskBubbles.forEach { $0.removeFromSuperview() }
        taskBubbles = []

        let totalWidth = bubblesContainer.bounds.width
        let window     = windowMinutes
        let validTasks = tasks.filter { !$0.title.isEmpty }
        guard totalWidth > 0, !validTasks.isEmpty else { return }

        let bubbleSize: CGFloat = 22
        var usedMinutes: Double = 0

        for (index, task) in validTasks.enumerated() {
            let mins = minutes(from: task.duration)
            // Centre bubble at midpoint of its segment
            let segMidFraction = CGFloat((usedMinutes + mins / 2) / window)
            let xCenter = segMidFraction * totalWidth
            let x = min(max(xCenter - bubbleSize / 2, 0), totalWidth - bubbleSize)
            let y = (bubblesContainer.bounds.height - bubbleSize) / 2

            let color = palette[index % palette.count]
            let bubble = makeBubble(number: index + 1, color: color)
            bubble.frame = CGRect(x: x, y: y, width: bubbleSize, height: bubbleSize)
            bubblesContainer.addSubview(bubble)
            taskBubbles.append(bubble)

            usedMinutes += mins
            if usedMinutes >= window { break }
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

    // MARK: - Time label

    private func updateTimeLabel() {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm"
        let amPmFmt = DateFormatter()
        amPmFmt.dateFormat = "a"

        let startStr = fmt.string(from: startDate)
        let endStr   = fmt.string(from: endDate)
        let period   = amPmFmt.string(from: endDate)

        // Duration
        let mins = Int(max(endDate.timeIntervalSince(startDate) / 60, 0))
        let h = mins / 60, m = mins % 60
        let durStr: String
        switch (h, m) {
        case (0, let m): durStr = "\(m) min"
        case (let h, 0): durStr = "\(h) hr"
        default:         durStr = "\(h) hr \(m) min"
        }

        timeRangeLabel.text = "\(startStr) – \(endStr) \(period)  ·  \(durStr)"
    }

    // MARK: - Actions

    @objc private func startTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        startPickerProxy.showPicker()
    }

    @objc private func endTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        endPickerProxy.showPicker()
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
        updateTimeLabel()

        // Animate rebuild
        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}

// MARK: - RoutineTimelineCard

final class RoutineTimelineCard: UIView {

    private(set) var startDate: Date
    private(set) var endDate: Date
    private var tasks: [RoutineTask]

    private lazy var timelineView: RoutineTimelineView = {
        let v = RoutineTimelineView(startDate: startDate, endDate: endDate, tasks: tasks)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        return v
    }()

    init(startDate: Date, endDate: Date, tasks: [RoutineTask] = []) {
        self.startDate = startDate
        self.endDate   = endDate
        self.tasks     = tasks
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func updateTasks(_ tasks: [RoutineTask]) {
        self.tasks = tasks
        timelineView.setTasks(tasks)
    }

    private func setup() {
        backgroundColor = UIColor(white: 1, alpha: 0.05)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 20
        blur.clipsToBounds = true
        blur.isUserInteractionEnabled = false

        let conf = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let icon = UIImageView(image: UIImage(systemName: "timeline.selection", withConfiguration: conf))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.tintColor = UIColor.accent.withAlphaComponent(0.8)
        icon.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "TIME WINDOW"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .semibold)
        titleLabel.textColor = UIColor(white: 1, alpha: 0.35)

        // Small hint that tapping track edges edits the times
        let editHint = UILabel()
        editHint.translatesAutoresizingMaskIntoConstraints = false
        editHint.text = "TAP EDGES TO EDIT"
        editHint.font = UIFont.monospacedSystemFont(ofSize: 8, weight: .medium)
        editHint.textColor = UIColor(white: 1, alpha: 0.18)

        let headerStack = UIStackView(arrangedSubviews: [icon, titleLabel])
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(white: 1, alpha: 0.07)

        insertSubview(blur, at: 0)
        addSubview(headerStack)
        addSubview(editHint)
        addSubview(divider)
        addSubview(timelineView)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14),

            editHint.centerYAnchor.constraint(equalTo: headerStack.centerYAnchor),
            editHint.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            divider.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 14),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),

            timelineView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 18),
            timelineView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            timelineView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            timelineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
    }
}

extension RoutineTimelineCard: RoutineTimelineViewDelegate {
    func timelineDidUpdateStart(_ date: Date) { startDate = date }
    func timelineDidUpdateEnd(_ date: Date)   { endDate = date }
}
