//
//  RoutineTimelineCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/22/26.
//

//
//  RoutineTimelineCard.swift
//  Forma
//

import UIKit

protocol RoutineTimelineCardDelegate: AnyObject {
    func didSetStartTime(_ date: Date)
    func didSetEndTime(_ date: Date)
}

final class RoutineTimelineCard: UIView {

    weak var delegate: RoutineTimelineCardDelegate?

    private(set) var startDate: Date
    private(set) var endDate: Date
    private var tasks: [RoutineTask]

    private lazy var timelineView: RoutineTimelineView = {
        let v = RoutineTimelineView(startDate: startDate, endDate: endDate, tasks: tasks)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        return v
    }()

    // MARK: - Remaining time pill

    private let remainingPill: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 10
        v.clipsToBounds = true
        return v
    }()

    private let remainingLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .semibold)
        l.textAlignment = .center
        return l
    }()

    // MARK: - Init

    init(startDate: Date, endDate: Date, tasks: [RoutineTask] = []) {
        self.startDate = startDate
        self.endDate   = endDate
        self.tasks     = tasks
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
        updateRemainingPill()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public

    func updateTasks(_ tasks: [RoutineTask]) {
        self.tasks = tasks
        timelineView.setTasks(tasks)
        updateRemainingPill()
    }

    // MARK: - Remaining pill logic

    private func updateRemainingPill() {
        let windowMins  = Int(max(endDate.timeIntervalSince(startDate) / 60, 0))
        let usedMins    = tasks.reduce(0) { $0 + Int($1.duration) }
        let remaining   = windowMins - usedMins

        UIView.animate(withDuration: 0.25) {
            if remaining <= 0 {
                // Fully filled — or overflow
                if remaining < 0 {
                    // Overflow: warn in red
                    self.remainingPill.backgroundColor = UIColor(red: 1, green: 0.35, blue: 0.35, alpha: 0.15)
                    self.remainingPill.layer.borderWidth = 1
                    self.remainingPill.layer.borderColor = UIColor(red: 1, green: 0.35, blue: 0.35, alpha: 0.4).cgColor
                    self.remainingLabel.textColor = UIColor(red: 1, green: 0.45, blue: 0.45, alpha: 1)
                    self.remainingLabel.text = "⚠ \(DurationFormatter.format(abs(remaining))) over"
                } else {
                    // Exactly filled
                    self.remainingPill.backgroundColor = UIColor(red: 0.3, green: 0.9, blue: 0.55, alpha: 0.12)
                    self.remainingPill.layer.borderWidth = 1
                    self.remainingPill.layer.borderColor = UIColor(red: 0.3, green: 0.9, blue: 0.55, alpha: 0.35).cgColor
                    self.remainingLabel.textColor = UIColor(red: 0.4, green: 0.95, blue: 0.6, alpha: 1)
                    self.remainingLabel.text = "✓ Fully scheduled"
                }
            } else {
                // Time still remaining — neutral/accent tint
                self.remainingPill.backgroundColor = UIColor(white: 1, alpha: 0.06)
                self.remainingPill.layer.borderWidth = 1
                self.remainingPill.layer.borderColor = UIColor(white: 1, alpha: 0.12).cgColor
                self.remainingLabel.textColor = UIColor(white: 1, alpha: 0.45)
                self.remainingLabel.text = "\(DurationFormatter.format(remaining)) remaining"
            }
        }
    }
    
    private func parseDuration(_ string: String) -> Int {
        let parts = string.lowercased().components(separatedBy: " ")
        var total = 0, i = 0
        while i < parts.count {
            if let value = Int(parts[i]) {
                let unit = i + 1 < parts.count ? parts[i + 1] : ""
                if unit.hasPrefix("hr") || unit.hasPrefix("hour") { total += value * 60 }
                else if unit.hasPrefix("min") { total += value }
                i += 2
            } else { i += 1 }
        }
        return total
    }
}

// MARK: - RoutineTimelineViewDelegate

extension RoutineTimelineCard: RoutineTimelineViewDelegate {
    func timelineDidUpdateStart(_ date: Date) {
        startDate = date
        updateRemainingPill()
        delegate?.didSetStartTime(date)
    }

    func timelineDidUpdateEnd(_ date: Date) {
        endDate = date
        updateRemainingPill()
        delegate?.didSetEndTime(date)
    }
}

// MARK: - Setup
extension RoutineTimelineCard {
    private func setup() {
        backgroundColor = .backgroundSecondary
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.backgroundSecondary.withAlphaComponent(0.1).cgColor
        
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
        
        let titleView = FormaTextView()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addCaption("TIME WINDOW", typography: .monospacedSmall)
        
        let editHint = FormaTextView()
        editHint.translatesAutoresizingMaskIntoConstraints = false
        editHint.addCaption("TAP EDGES TO EDIT", typography: .caption, color: UIColor.textTertiary)
        
        let headerStack = UIStackView(arrangedSubviews: [icon, titleView])
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center
        
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.backgroundSecondary.withAlphaComponent(0.07)
        
        // Remaining pill
        remainingPill.addSubview(remainingLabel)
        
        insertSubview(blur, at: 0)
        addSubview(headerStack)
        addSubview(editHint)
        addSubview(remainingPill)
        addSubview(divider)
        addSubview(timelineView)
        
        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Header
            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14),
            
            editHint.centerYAnchor.constraint(equalTo: headerStack.centerYAnchor),
            editHint.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            
            // Remaining pill — sits between header and divider, trailing aligned
            remainingPill.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 10),
            remainingPill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            
            remainingLabel.topAnchor.constraint(equalTo: remainingPill.topAnchor, constant: 5),
            remainingLabel.leadingAnchor.constraint(equalTo: remainingPill.leadingAnchor, constant: 10),
            remainingLabel.trailingAnchor.constraint(equalTo: remainingPill.trailingAnchor, constant: -10),
            remainingLabel.bottomAnchor.constraint(equalTo: remainingPill.bottomAnchor, constant: -5),
            
            // Divider below pill
            divider.topAnchor.constraint(equalTo: remainingPill.bottomAnchor, constant: 10),
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
