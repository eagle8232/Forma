//
//  DurationPickerView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/21/26.
//

import UIKit

protocol DurationPickerViewDelegate: AnyObject {
    func durationPickerDidSelect(_ picker: DurationPickerView, hours: Int, minutes: Int)
}

final class DurationPickerView: UIView {

    weak var delegate: DurationPickerViewDelegate?

    // MARK: - State

    private(set) var selectedHours: Int = 0
    private(set) var selectedMinutes: Int = 10

    var durationString: String {
        if selectedHours == 0 {
            return "\(selectedMinutes) min"
        } else if selectedMinutes == 0 {
            return "\(selectedHours) hr"
        } else {
            return "\(selectedHours) hr \(selectedMinutes) min"
        }
    }

    // MARK: - UI

    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 1, alpha: 0.07)
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(white: 1, alpha: 0.12).cgColor
        return v
    }()

    private let clockIcon: UIImageView = {
        let conf = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "timer", withConfiguration: conf))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = UIColor.accent
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let durationLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .semibold)
        l.textColor = UIColor(white: 1, alpha: 0.75)
        return l
    }()

    private let chevronIcon: UIImageView = {
        let conf = UIImage.SymbolConfiguration(pointSize: 9, weight: .medium)
        let iv = UIImageView(image: UIImage(systemName: "chevron.up.chevron.down", withConfiguration: conf))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = UIColor(white: 1, alpha: 0.3)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        containerView.addSubview(clockIcon)
        containerView.addSubview(durationLabel)
        containerView.addSubview(chevronIcon)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            clockIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            clockIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            clockIcon.widthAnchor.constraint(equalToConstant: 13),
            clockIcon.heightAnchor.constraint(equalToConstant: 13),

            durationLabel.leadingAnchor.constraint(equalTo: clockIcon.trailingAnchor, constant: 6),
            durationLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            chevronIcon.leadingAnchor.constraint(equalTo: durationLabel.trailingAnchor, constant: 6),
            chevronIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            chevronIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronIcon.widthAnchor.constraint(equalToConstant: 11),

            containerView.heightAnchor.constraint(equalToConstant: 36)
        ])

        updateLabel()

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        containerView.addGestureRecognizer(tap)
        containerView.isUserInteractionEnabled = true
    }

    // MARK: - Public

    func set(hours: Int, minutes: Int) {
        selectedHours = hours
        selectedMinutes = minutes
        updateLabel()
    }

    /// Parse a legacy string like "10 min" or "1 hr 30 min" back into hours/minutes.
    func setFromInt(_ duration: Int) {
        let totalMinutes = Int(duration)
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        set(hours: h, minutes: m)
    }

    // MARK: - Private

    private func updateLabel() {
        durationLabel.text = durationString
    }

    @objc private func tapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // Pulse
        UIView.animate(withDuration: 0.1, animations: {
            self.containerView.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            self.containerView.backgroundColor = UIColor(white: 1, alpha: 0.13)
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0,
                           usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                self.containerView.transform = .identity
                self.containerView.backgroundColor = UIColor(white: 1, alpha: 0.07)
            }
        }

        presentModal()
    }

    private func presentModal() {
        guard let window = window else { return }

        let modal = DurationPickerModal(initialHours: selectedHours, initialMinutes: selectedMinutes)
        modal.onConfirm = { [weak self] hours, minutes in
            guard let self else { return }
            self.selectedHours = hours
            self.selectedMinutes = minutes
            self.updateLabel()
            self.delegate?.durationPickerDidSelect(self, hours: hours, minutes: minutes)

            // Green flash feedback
            UIView.animate(withDuration: 0.2) {
                self.containerView.backgroundColor = UIColor.accent.withAlphaComponent(0.18)
                self.containerView.layer.borderColor = UIColor.accent.withAlphaComponent(0.4).cgColor
            } completion: { _ in
                UIView.animate(withDuration: 0.4) {
                    self.containerView.backgroundColor = UIColor(white: 1, alpha: 0.07)
                    self.containerView.layer.borderColor = UIColor(white: 1, alpha: 0.12).cgColor
                }
            }
        }

        window.addSubview(modal)
        NSLayoutConstraint.activate([
            modal.topAnchor.constraint(equalTo: window.topAnchor),
            modal.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            modal.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            modal.bottomAnchor.constraint(equalTo: window.bottomAnchor)
        ])
        modal.show()
    }
}

// MARK: - DurationPickerModal

final class DurationPickerModal: UIView {

    var onConfirm: ((Int, Int) -> Void)?

    private let initialHours: Int
    private let initialMinutes: Int

    // MARK: - UI

    private let backdrop: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return v
    }()

    private let sheet: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.12, alpha: 1)
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor
        return v
    }()

    private let grabber: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 1, alpha: 0.2)
        v.layer.cornerRadius = 2.5
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "DURATION"
        l.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .bold)
        l.textColor = UIColor(white: 1, alpha: 0.35)
        l.textAlignment = .center
        return l
    }()

    // Two UIPickerViews side by side (hours | minutes)
    private let hoursPicker = UIPickerView()
    private let minutesPicker = UIPickerView()

    private let hoursLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "hr"
        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        l.textColor = UIColor(white: 1, alpha: 0.4)
        return l
    }()

    private let minutesLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "min"
        l.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        l.textColor = UIColor(white: 1, alpha: 0.4)
        return l
    }()

    private lazy var confirmButton: FormaButton = {
        let btn = FormaButton.primary(title: "Confirm")
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        return btn
    }()

    private var sheetBottomConstraint: NSLayoutConstraint!

    // MARK: - Init

    init(initialHours: Int, initialMinutes: Int) {
        self.initialHours = initialHours
        self.initialMinutes = initialMinutes
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        addSubview(backdrop)
        addSubview(sheet)

        sheet.addSubview(grabber)
        sheet.addSubview(titleLabel)
        sheet.addSubview(hoursPicker)
        sheet.addSubview(hoursLabel)
        sheet.addSubview(minutesPicker)
        sheet.addSubview(minutesLabel)
        sheet.addSubview(confirmButton)

        hoursPicker.translatesAutoresizingMaskIntoConstraints = false
        minutesPicker.translatesAutoresizingMaskIntoConstraints = false
        hoursPicker.dataSource = self
        hoursPicker.delegate   = self
        minutesPicker.dataSource = self
        minutesPicker.delegate   = self
        hoursPicker.tag   = 0
        minutesPicker.tag = 1

        // Style pickers
        [hoursPicker, minutesPicker].forEach {
            $0.setValue(UIColor.white, forKey: "textColor")
        }

        sheetBottomConstraint = sheet.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 400)

        NSLayoutConstraint.activate([
            backdrop.topAnchor.constraint(equalTo: topAnchor),
            backdrop.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdrop.bottomAnchor.constraint(equalTo: bottomAnchor),

            sheet.leadingAnchor.constraint(equalTo: leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: trailingAnchor),
            sheetBottomConstraint,

            grabber.topAnchor.constraint(equalTo: sheet.topAnchor, constant: 12),
            grabber.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 36),
            grabber.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 18),
            titleLabel.centerXAnchor.constraint(equalTo: sheet.centerXAnchor),

            // Pickers side by side, centered
            hoursPicker.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            hoursPicker.centerXAnchor.constraint(equalTo: sheet.centerXAnchor, constant: -70),
            hoursPicker.widthAnchor.constraint(equalToConstant: 80),
            hoursPicker.heightAnchor.constraint(equalToConstant: 160),

            hoursLabel.centerYAnchor.constraint(equalTo: hoursPicker.centerYAnchor),
            hoursLabel.leadingAnchor.constraint(equalTo: hoursPicker.trailingAnchor, constant: 4),

            minutesPicker.topAnchor.constraint(equalTo: hoursPicker.topAnchor),
            minutesPicker.centerXAnchor.constraint(equalTo: sheet.centerXAnchor, constant: 70),
            minutesPicker.widthAnchor.constraint(equalToConstant: 80),
            minutesPicker.heightAnchor.constraint(equalToConstant: 160),

            minutesLabel.centerYAnchor.constraint(equalTo: minutesPicker.centerYAnchor),
            minutesLabel.leadingAnchor.constraint(equalTo: minutesPicker.trailingAnchor, constant: 4),

            confirmButton.topAnchor.constraint(equalTo: hoursPicker.bottomAnchor, constant: 20),
            confirmButton.leadingAnchor.constraint(equalTo: sheet.leadingAnchor, constant: 24),
            confirmButton.trailingAnchor.constraint(equalTo: sheet.trailingAnchor, constant: -24),
            confirmButton.heightAnchor.constraint(equalToConstant: 56),
            confirmButton.bottomAnchor.constraint(equalTo: sheet.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        // Backdrop tap dismisses
        let tap = UITapGestureRecognizer(target: self, action: #selector(backdropTapped))
        backdrop.addGestureRecognizer(tap)

        // Scroll to initial values after layout
        DispatchQueue.main.async {
            self.hoursPicker.selectRow(self.initialHours, inComponent: 0, animated: false)
            self.minutesPicker.selectRow(self.initialMinutes, inComponent: 0, animated: false)
        }
    }

    // MARK: - Show / Hide

    func show() {
        layoutIfNeeded()
        sheetBottomConstraint.constant = 0
        backdrop.alpha = 0

        UIView.animate(withDuration: 0.45, delay: 0,
                       usingSpringWithDamping: 0.82, initialSpringVelocity: 0) {
            self.backdrop.alpha = 1
            self.layoutIfNeeded()
        }
    }

    private func dismiss(then completion: (() -> Void)? = nil) {
        sheetBottomConstraint.constant = 400
        UIView.animate(withDuration: 0.35, delay: 0,
                       usingSpringWithDamping: 0.9, initialSpringVelocity: 0,
                       animations: {
            self.backdrop.alpha = 0
            self.layoutIfNeeded()
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }

    // MARK: - Actions

    @objc private func confirmTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let hours   = hoursPicker.selectedRow(inComponent: 0)
        let minutes = minutesPicker.selectedRow(inComponent: 0)
        dismiss { [weak self] in
            self?.onConfirm?(hours, minutes)
        }
    }

    @objc private func backdropTapped() {
        dismiss()
    }
}

// MARK: - UIPickerViewDataSource & Delegate

extension DurationPickerModal: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        pickerView.tag == 0 ? 24 : 60  // 0-23 hours, 0-59 minutes
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.textAlignment = .center
        label.font = UIFont.monospacedSystemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.text = String(format: "%02d", row)
        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat { 44 }
}
