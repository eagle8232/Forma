//
//  FormaTipView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/2/26.
//

import UIKit

final class FormaTipView: UIView {

    private let tips: [(icon: String, text: String)]
    private var currentIndex = 0
    private var timer: Timer?

    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.accent.withAlphaComponent(0.12).cgColor,
            UIColor.accentGradient.withAlphaComponent(0.06).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.cornerRadius = 16
        return layer
    }()

    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "DID YOU KNOW"
        label.font = .systemFont(ofSize: 9, weight: .semibold)
        label.textColor = .accent
        label.alpha = 0.8
        label.letterSpacing(1.2)
        return label
    }()

    private lazy var iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.alpha = 0
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .textSecondary
        label.numberOfLines = 2
        label.alpha = 0
        return label
    }()

    // MARK: - Init

    init(tips: [(icon: String, text: String)]) {
        self.tips = tips
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    deinit { timer?.invalidate() }

    // MARK: - Public

    func startRotation(interval: TimeInterval = 4.0) {
        showTip(animated: false)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.currentIndex = (self.currentIndex + 1) % self.tips.count
            self.showTip(animated: true)
        }
    }

    func stopRotation() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private

    private func showTip(animated: Bool) {
        let tip = tips[currentIndex]
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.textLabel.alpha = 0
                self.iconLabel.alpha = 0
                self.textLabel.transform = CGAffineTransform(translationX: 0, y: -6)
            } completion: { _ in
                self.iconLabel.text = tip.icon
                self.textLabel.text = tip.text
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
                    self.textLabel.alpha = 1
                    self.iconLabel.alpha = 1
                    self.textLabel.transform = .identity
                }
            }
        } else {
            iconLabel.text = tip.icon
            textLabel.text = tip.text
            textLabel.alpha = 1
            iconLabel.alpha = 1
        }
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = UIColor.accent.withAlphaComponent(0.2).cgColor
        clipsToBounds = true

        layer.addSublayer(gradientLayer)
        addSubview(badgeLabel)
        addSubview(iconLabel)
        addSubview(textLabel)

        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            badgeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconLabel.widthAnchor.constraint(equalToConstant: 28),

            textLabel.topAnchor.constraint(equalTo: badgeLabel.bottomAnchor, constant: 6),
            textLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 10),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
        ])
    }
}
