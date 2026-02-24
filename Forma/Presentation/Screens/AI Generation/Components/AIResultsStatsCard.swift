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

    private var valueLabels: [UILabel] = []

    private var stats: [Stat]

    // MARK: - Init

    init(stats: [Stat]) {
        self.stats = stats
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupBase()
        populate()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup (called once)

    private func setupBase() {
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor
        clipsToBounds = false
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

    /// Builds cells exactly once on init
    private func populate() {
        valueLabels.removeAll()
        stats.forEach { stat in
            let (cell, valueLabel) = makeCell(stat: stat)
            outerStack.addArrangedSubview(cell)
            valueLabels.append(valueLabel)
        }
    }

    // MARK: - Public update (no rebuild, just text swap)

    func updateStats(_ stats: [Stat]) {
        self.stats = stats
        zip(valueLabels, stats).forEach { label, stat in
            guard label.text != stat.value else { return }
            UIView.transition(with: label, duration: 0.25,
                              options: .transitionCrossDissolve) {
                label.text = stat.value
            }
        }
    }

    // MARK: - Cell builder — returns both the view and the label to store

    private func makeCell(stat: Stat) -> (UIView, UILabel) {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = stat.value
        valueLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .center

        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = UIColor.accent.withAlphaComponent(0.7)
        bar.layer.cornerRadius = 1.5

        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCaption(stat.label.uppercased(),
                      color: UIColor(white: 1, alpha: 0.35),
                      alignment: .center)

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

        return (container, valueLabel)
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
