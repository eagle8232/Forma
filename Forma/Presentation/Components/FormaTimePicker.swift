//
//  FormaTimePicker.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/16/26.
//

import UIKit

protocol FormaTimePickerDelegate: AnyObject {
    func timePickerDidSelectTime(_ picker: FormaTimePickerView, date: Date)
}

final class FormaTimePickerView: UIView {
    
    // MARK: - Configuration
    
    enum PickerType {
        case wakeTime
        case sleepTime
        
        var icon: String {
            switch self {
            case .wakeTime: return "☀️"
            case .sleepTime: return "🌙"
            }
        }
        
        var title: String {
            switch self {
            case .wakeTime: return "WAKE TIME"
            case .sleepTime: return "SLEEP TIME"
            }
        }
        
        var defaultHour: Int {
            switch self {
            case .wakeTime: return 6
            case .sleepTime: return 22
            }
        }
        
        var defaultMinute: Int {
            switch self {
            case .wakeTime: return 30
            case .sleepTime: return 45
            }
        }
        
        var pickerTitle: String {
            switch self {
            case .wakeTime: return "Wake Time"
            case .sleepTime: return "Sleep Time"
            }
        }
        
        var pickerSubtitle: String {
            switch self {
            case .wakeTime:
                return "Choose when you typically wake up. This helps us schedule your morning routines at the optimal time."
            case .sleepTime:
                return "Choose when you typically go to bed. This helps us schedule your evening wind-down routines."
            }
        }
    }
    
    // MARK: - Properties
    
    weak var delegate: FormaTimePickerDelegate?
    private let pickerType: PickerType
    var selectedDate: Date
    private var hasAppliedGradient = false
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundPrimary
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .accent
        let symbolName = pickerType == .wakeTime ? "sunrise.fill" : "moon.fill"
        imageView.image = UIImage(systemName: symbolName)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = pickerType.title
        label.font = .typography(.caption)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.textColor = .textPrimary
        return label
    }()
    
    private lazy var periodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .textSecondary
        return label
    }()
    
    // MARK: - Initialization
    
    init(type: PickerType) {
        self.pickerType = type
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = type.defaultHour
        components.minute = type.defaultMinute
        self.selectedDate = Calendar.current.date(from: components) ?? Date()
        
        super.init(frame: .zero)
        setup()
        updateTimeDisplay()
    }
    
    required init?(coder: NSCoder) {
        self.pickerType = .wakeTime
        self.selectedDate = Date()
        super.init(coder: coder)
        setup()
        updateTimeDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !hasAppliedGradient else { return }
        hasAppliedGradient = true
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.accent.withAlphaComponent(0.5).cgColor,
            UIColor.accent.withAlphaComponent(0.3).cgColor,
            UIColor.accent.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = containerView.bounds
        gradientLayer.cornerRadius = 30
        containerView.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Public Methods
    
    func setTime(_ date: Date) {
        selectedDate = date
        updateTimeDisplay()
    }

    /// Programmatically presents the time picker modal.
    /// Use this when the view is hidden (e.g. used as a proxy trigger).
    /// All other VCs that use FormaTimePickerView via tap are unaffected.
    func showPicker() {
        showTimePicker()
    }
    
    // MARK: - Private Methods
    
    private func updateTimeDisplay() {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: selectedDate)
        let minute = calendar.component(.minute, from: selectedDate)
        
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        let period = hour >= 12 ? "PM" : "AM"
        
        timeLabel.text = String(format: "%d:%02d", displayHour, minute)
        periodLabel.text = period
    }
    
    @objc private func cardTapped() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        SoundManager.shared.playSound(.buttonTap)
        showTimePicker()
    }
    
    private func showTimePicker() {
        guard let window = window else { return }
        
        let pickerView = FormaTimePickerModal(
            title: pickerType.pickerTitle,
            subtitle: pickerType.pickerSubtitle,
            initialDate: selectedDate
        )
        
        pickerView.onDateSelected = { [weak self] date in
            guard let self = self else { return }
            self.selectedDate = date
            self.updateTimeDisplay()
            self.delegate?.timePickerDidSelectTime(self, date: date)
        }
        
        window.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: window.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
        
        pickerView.show()
    }
}

// MARK: - Container Setup
extension FormaTimePickerView {
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(periodLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            timeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            periodLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            periodLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            periodLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
}
