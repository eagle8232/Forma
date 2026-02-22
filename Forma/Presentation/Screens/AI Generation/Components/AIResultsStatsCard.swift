//
//  AIResultsStatsCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/20/26.
//

import UIKit

final class AIResultsStatsCard: UIView {

    // MARK: - Data

    struct Stat {
        let value: String
        let label: String
    }

    // MARK: - UI

    private let blurView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        return v
    }()

    private let outerStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.distribution = .fillEqually
        s.alignment = .center
        return s
    }()

    // MARK: - Init

    init(stats: [Stat]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupBase()
        populate(stats: stats)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupBase() {
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor
        clipsToBounds = false

        // Subtle glow shadow
        layer.shadowColor = UIColor.accent.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 20
        layer.shadowOffset = .zero

        addSubview(blurView)
        addSubview(outerStack)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            outerStack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            outerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            outerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            outerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func populate(stats: [Stat]) {
        stats.forEach { stat in
            outerStack.addArrangedSubview(makeCell(stat: stat))
        }
    }

    // MARK: - Cell Builder

    private func makeCell(stat: Stat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Large value
        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = stat.value
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center

        // Accent underline bar
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = UIColor.accent.withAlphaComponent(0.7)
        bar.layer.cornerRadius = 1.5

        // Label
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCaption(
            stat.label.uppercased(),
            color: UIColor(white: 1, alpha: 0.35),
            alignment: .center
        )

        [valueLabel, bar, tv].forEach { container.addSubview($0) }

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            bar.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 5),
            bar.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            bar.widthAnchor.constraint(equalToConstant: 20),
            bar.heightAnchor.constraint(equalToConstant: 3),

            tv.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 6),
            tv.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            tv.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
            tv.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    // MARK: - Animate In

    func animateIn(delay: TimeInterval = 0) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.65, delay: delay,
                       usingSpringWithDamping: 0.8, initialSpringVelocity: 0) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}
