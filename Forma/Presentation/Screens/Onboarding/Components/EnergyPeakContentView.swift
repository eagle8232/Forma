//
//  EnergyPeakContentView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/16/26.
//

import UIKit

protocol EnergyPeakContentViewDelegate: AnyObject {
    func energyPeakContentView(_ view: EnergyPeakContentView, didSelectWakeTime date: Date)
    func energyPeakContentView(_ view: EnergyPeakContentView, didSelectSleepTime date: Date)
}

final class EnergyPeakContentView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: EnergyPeakContentViewDelegate?
    private var tipTimer: Timer?
    private var currentTipIndex = 0
    
    private lazy var wakeTimeCard: FormaTimePickerView = {
        let card = FormaTimePickerView(type: .wakeTime)
        card.delegate = self
        return card
    }()
    
    private lazy var sleepTimeCard: FormaTimePickerView = {
        let card = FormaTimePickerView(type: .sleepTime)
        card.delegate = self
        return card
    }()
    
    private lazy var tipView = FormaTipView(tips: Constants.energyPeakTips)
    
    private lazy var qualityContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.adaptiveTextSecondary.withAlphaComponent(0.06).cgColor
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var qualityBgView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.adaptiveTextSecondary.withAlphaComponent(0.04)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var qualityTopRow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var qualityTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SLEEP QUALITY"
        label.font = .systemFont(ofSize: 9, weight: .semibold)
        label.textColor = .adaptiveTextSecondary
        label.letterSpacing(1.2)
        return label
    }()
    
    private lazy var qualityValueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.typography(.label)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var qualityDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.typography(.overline)
        label.textColor = .adaptiveTextSecondary
        label.textAlignment = .right
        return label
    }()
    
    private lazy var trackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.adaptiveTextSecondary.withAlphaComponent(0.07)
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var fillView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var fillGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.cornerRadius = 4
        return layer
    }()
    
    // Markers at 6h and 9h positions
    private lazy var marker6h: UIView = makeMarker(label: "6h")
    private lazy var marker9h: UIView = makeMarker(label: "9h")
    
    private var marker6hConstraint: NSLayoutConstraint?
    private var marker9hConstraint: NSLayoutConstraint?
    
    
    private var fillWidthConstraint: NSLayoutConstraint?
    
    
    // MARK: - Initialization
    
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
        // Position markers after layout
        let trackW = trackView.bounds.width
        if trackW > 0 {
            marker6hConstraint?.constant = trackW * (6.0 / 12.0)
            marker9hConstraint?.constant = trackW * (9.0 / 12.0)
            fillGradientLayer.frame = fillView.bounds
        }
    }
    
    
    deinit {
        tipTimer?.invalidate()
    }
    
    // MARK: - Public Methods
    
    func getWakeUpTime() -> Date? { wakeTimeCard.selectedDate }
    func getSleepTime() -> Date? { sleepTimeCard.selectedDate }
}

// MARK: - FormaTimePickerDelegate

extension EnergyPeakContentView: FormaTimePickerDelegate {
    func timePickerDidSelectTime(_ picker: FormaTimePickerView, date: Date) {
        if picker == wakeTimeCard {
            delegate?.energyPeakContentView(self, didSelectWakeTime: date)
        } else {
            delegate?.energyPeakContentView(self, didSelectSleepTime: date)
        }
        // Always recalculate with latest values
        if let wake = wakeTimeCard.selectedDate as Date?,
           let sleep = sleepTimeCard.selectedDate as Date? {
            updateSleepQuality(wake: wake, sleep: sleep)
        }
    }
}

// MARK: - Setup

extension EnergyPeakContentView {
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        let cardsStackView = UIStackView(arrangedSubviews: [wakeTimeCard, sleepTimeCard])
        cardsStackView.translatesAutoresizingMaskIntoConstraints = false
        cardsStackView.axis = .horizontal
        cardsStackView.spacing = 16
        cardsStackView.distribution = .fillEqually
        
        setupQualityBar()
        
        let lowerStack = UIStackView(arrangedSubviews: [qualityContainerView, tipView])
        lowerStack.translatesAutoresizingMaskIntoConstraints = false
        lowerStack.axis = .vertical
        lowerStack.spacing = 12
        
        addSubview(cardsStackView)
        addSubview(lowerStack)
        
        NSLayoutConstraint.activate([
            cardsStackView.topAnchor.constraint(equalTo: topAnchor),
            cardsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardsStackView.heightAnchor.constraint(equalToConstant: 200),
            
            
            lowerStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            lowerStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            lowerStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        cardsStackView.subviews.enumerated().forEach { index, view in
            view.animateIn(delay: CGFloat(index) * 10)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.tipView.startRotation()
            // Trigger initial quality calculation
            if let wake = self?.wakeTimeCard.selectedDate,
               let sleep = self?.sleepTimeCard.selectedDate {
                self?.updateSleepQuality(wake: wake, sleep: sleep)
            }
        }
    }
}

// MARK: - Sleep Quality Bar
extension EnergyPeakContentView {
    
    private func makeMarker(label text: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let line = UIView()
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(white: 1, alpha: 0.15)
        line.widthAnchor.constraint(equalToConstant: 1).isActive = true
        line.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 9, weight: .medium)
        label.textColor = UIColor(white: 1, alpha: 0.25)
        
        container.addSubview(line)
        container.addSubview(label)
        
        NSLayoutConstraint.activate([
            line.topAnchor.constraint(equalTo: container.topAnchor),
            line.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 3),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        return container
    }
    
    // MARK: - Quality Bar Setup & Update
    
    private func setupQualityBar() {
        qualityContainerView.addSubview(qualityBgView)
        qualityContainerView.addSubview(qualityTitleLabel)
        qualityContainerView.addSubview(qualityValueLabel)
        qualityContainerView.addSubview(qualityDurationLabel)
        qualityContainerView.addSubview(trackView)
        trackView.addSubview(fillView)
        fillView.layer.addSublayer(fillGradientLayer)
        trackView.addSubview(marker6h)
        trackView.addSubview(marker9h)
        
        NSLayoutConstraint.activate([
            qualityBgView.topAnchor.constraint(equalTo: qualityContainerView.topAnchor),
            qualityBgView.leadingAnchor.constraint(equalTo: qualityContainerView.leadingAnchor),
            qualityBgView.trailingAnchor.constraint(equalTo: qualityContainerView.trailingAnchor),
            qualityBgView.bottomAnchor.constraint(equalTo: qualityContainerView.bottomAnchor),
            
            qualityTitleLabel.topAnchor.constraint(equalTo: qualityContainerView.topAnchor, constant: 14),
            qualityTitleLabel.leadingAnchor.constraint(equalTo: qualityContainerView.leadingAnchor, constant: 16),
            
            qualityValueLabel.centerYAnchor.constraint(equalTo: qualityTitleLabel.centerYAnchor),
            qualityValueLabel.trailingAnchor.constraint(equalTo: qualityContainerView.trailingAnchor, constant: -16),
            
            qualityDurationLabel.topAnchor.constraint(equalTo: qualityValueLabel.bottomAnchor, constant: 1),
            qualityDurationLabel.trailingAnchor.constraint(equalTo: qualityContainerView.trailingAnchor, constant: -16),
            
            trackView.topAnchor.constraint(equalTo: qualityTitleLabel.bottomAnchor, constant: 16),
            trackView.leadingAnchor.constraint(equalTo: qualityContainerView.leadingAnchor, constant: 16),
            trackView.trailingAnchor.constraint(equalTo: qualityContainerView.trailingAnchor, constant: -16),
            trackView.heightAnchor.constraint(equalToConstant: 8),
            trackView.bottomAnchor.constraint(equalTo: qualityContainerView.bottomAnchor, constant: -20),
            
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
        ])
        
        // Fill width — will be animated
        fillWidthConstraint = fillView.widthAnchor.constraint(equalToConstant: 0)
        fillWidthConstraint?.isActive = true
        
        // Markers at 6h = 50% and 9h = 75% of 12h max
        marker6hConstraint = marker6h.centerXAnchor.constraint(equalTo: trackView.leadingAnchor)
        marker9hConstraint = marker9h.centerXAnchor.constraint(equalTo: trackView.leadingAnchor)
        marker6h.topAnchor.constraint(equalTo: trackView.bottomAnchor, constant: 4).isActive = true
        marker9h.topAnchor.constraint(equalTo: trackView.bottomAnchor, constant: 4).isActive = true
        marker6hConstraint?.isActive = true
        marker9hConstraint?.isActive = true
    }
    
    func updateSleepQuality(wake: Date, sleep: Date) {
        let calendar = Calendar.current
        let sleepMins = calendar.component(.hour, from: sleep) * 60 + calendar.component(.minute, from: sleep)
        var wakeMins = calendar.component(.hour, from: wake) * 60 + calendar.component(.minute, from: wake)
        if sleepMins > wakeMins { wakeMins += 24 * 60 }
        let durationHours = Double(wakeMins - sleepMins) / 60.0
        
        // Quality rating
        let quality: SleepQuality
        switch durationHours {
        case ..<5:       quality = .poor
        case 5..<6:      quality = .fair
        case 6..<7:      quality = .okay
        case 7..<9:      quality = .optimal
        default:         quality = .fair   // over 9h also not ideal
        }
        
        let progress = min(durationHours / 12.0, 1.0)
        let h = Int(durationHours)
        let m = Int((durationHours - Double(h)) * 60)
        let durStr = m > 0 ? "\(h)h \(m)m" : "\(h)h"
        
        // Animate fill
        layoutIfNeeded()
        let trackW = trackView.bounds.width
        fillWidthConstraint?.constant = trackW * CGFloat(progress)
        fillGradientLayer.colors = quality.gradientColors
        
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.3) {
            self.layoutIfNeeded()
            self.fillGradientLayer.frame = self.fillView.bounds
        }
        
        // Animate label change
        UIView.transition(with: qualityValueLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.qualityValueLabel.text = quality.label
            self.qualityValueLabel.textColor = quality.color
        }
        UIView.transition(with: qualityDurationLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.qualityDurationLabel.text = durStr
        }
    }
    
    // MARK: - Sleep Quality Enum
    
    private enum SleepQuality {
        case poor, fair, okay, optimal
        
        var label: String {
            switch self {
            case .poor:    return "Poor"
            case .fair:    return "Fair"
            case .okay:    return "Good"
            case .optimal: return "Optimal ✦"
            }
        }
        
        var color: UIColor {
            switch self {
            case .poor:    return UIColor(red: 1, green: 0.35, blue: 0.35, alpha: 1)
            case .fair:    return UIColor(red: 1, green: 0.65, blue: 0.2, alpha: 1)
            case .okay:    return UIColor(red: 0.4, green: 0.85, blue: 0.6, alpha: 1)
            case .optimal: return .adaptiveAccent
            }
        }
        
        var gradientColors: [CGColor] {
            switch self {
            case .poor:
                return [UIColor(red: 1, green: 0.35, blue: 0.35, alpha: 1).cgColor,
                        UIColor(red: 1, green: 0.5, blue: 0.35, alpha: 1).cgColor]
            case .fair:
                return [UIColor(red: 1, green: 0.55, blue: 0.1, alpha: 1).cgColor,
                        UIColor(red: 1, green: 0.75, blue: 0.2, alpha: 1).cgColor]
            case .okay:
                return [UIColor(red: 0.2, green: 0.75, blue: 0.5, alpha: 1).cgColor,
                        UIColor(red: 0.4, green: 0.9, blue: 0.65, alpha: 1).cgColor]
            case .optimal:
                return [UIColor.adaptiveAccent.cgColor, UIColor.adaptiveAccent.cgColor]
            }
        }
    }
}
