//
//  RoutineHeroCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/20/26.
//

import UIKit

final class RoutineHeroCard: UIView {

    var currentTitle: String { titleField.textField.text ?? "" }
    var currentDescription: String { descriptionView.text ?? "" }
    var currentIcon: String { iconLabel.text ?? "" }

    private let blurView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 24
        v.clipsToBounds = true
        v.isUserInteractionEnabled = false
        return v
    }()

    private let accentBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.accent
        v.layer.cornerRadius = 2
        return v
    }()

    private lazy var iconButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.cornerRadius = 20
        b.backgroundColor = UIColor.accent.withAlphaComponent(0.15)
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.accent.withAlphaComponent(0.3).cgColor
        b.addTarget(self, action: #selector(iconTapped), for: .touchUpInside)
        return b
    }()

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 30)
        l.textAlignment = .center
        l.isUserInteractionEnabled = false
        return l
    }()

    private let editIconHint: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "TAP TO CHANGE"
        l.font = UIFont.monospacedSystemFont(ofSize: 8, weight: .medium)
        l.textColor = UIColor(white: 1, alpha: 0.25)
        l.textAlignment = .center
        return l
    }()

    private lazy var titleField: FormaTextField = {
        let f = FormaTextField(
            placeholder: "Routine name...",
            configuration: .init(keyboardType: .default, returnKeyType: .next)
        )
        f.translatesAutoresizingMaskIntoConstraints = false
        f.textField.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        f.textField.textColor = .white
        return f
    }()

    private let goalLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "GOAL"
        l.font = UIFont.monospacedSystemFont(ofSize: 9, weight: .semibold)
        l.textColor = UIColor.accent.withAlphaComponent(0.7)
        return l
    }()

    private let descriptionView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tv.textColor = UIColor(white: 1, alpha: 0.6)
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    private let descPlaceholder: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "What's the goal you want to reach with this routine?"
        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(white: 1, alpha: 0.22)
        l.numberOfLines = 2
        return l
    }()

    private let charCountLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(white: 1, alpha: 0.2)
        l.textAlignment = .right
        l.text = "0 / 200"
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, description: String, icon: String) {
        titleField.setText(title)
        iconLabel.text = icon.isEmpty ? "✦" : icon
        descriptionView.text = description
        descPlaceholder.isHidden = !description.isEmpty
        updateCharCount()
    }

    private func setup() {
        backgroundColor = UIColor(white: 1, alpha: 0.05)
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor

        iconButton.addSubview(iconLabel)
        descriptionView.delegate = self

        let eyebrow = UILabel()
        eyebrow.translatesAutoresizingMaskIntoConstraints = false
        eyebrow.text = "EDITING ROUTINE"
        eyebrow.font = UIFont.monospacedSystemFont(ofSize: 9, weight: .medium)
        eyebrow.textColor = UIColor(white: 1, alpha: 0.3)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(white: 1, alpha: 0.07)

        [blurView, accentBar, eyebrow, iconButton, editIconHint,
         titleField, divider, goalLabel, descriptionView,
         descPlaceholder, charCountLabel].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),

            accentBar.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            accentBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            accentBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            accentBar.widthAnchor.constraint(equalToConstant: 3),

            eyebrow.topAnchor.constraint(equalTo: topAnchor, constant: 22),
            eyebrow.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 16),

            iconButton.topAnchor.constraint(equalTo: eyebrow.bottomAnchor, constant: 14),
            iconButton.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 16),
            iconButton.widthAnchor.constraint(equalToConstant: 60),
            iconButton.heightAnchor.constraint(equalToConstant: 60),

            iconLabel.centerXAnchor.constraint(equalTo: iconButton.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconButton.centerYAnchor),

            editIconHint.topAnchor.constraint(equalTo: iconButton.bottomAnchor, constant: 4),
            editIconHint.centerXAnchor.constraint(equalTo: iconButton.centerXAnchor),

            titleField.centerYAnchor.constraint(equalTo: iconButton.centerYAnchor),
            titleField.leadingAnchor.constraint(equalTo: iconButton.trailingAnchor, constant: 14),
            titleField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            divider.topAnchor.constraint(equalTo: editIconHint.bottomAnchor, constant: 20),
            divider.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            divider.heightAnchor.constraint(equalToConstant: 1),

            goalLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            goalLabel.leadingAnchor.constraint(equalTo: divider.leadingAnchor),

            descriptionView.topAnchor.constraint(equalTo: goalLabel.bottomAnchor, constant: 8),
            descriptionView.leadingAnchor.constraint(equalTo: divider.leadingAnchor),
            descriptionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),

            descPlaceholder.topAnchor.constraint(equalTo: descriptionView.topAnchor),
            descPlaceholder.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor),
            descPlaceholder.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor),

            charCountLabel.topAnchor.constraint(equalTo: descriptionView.bottomAnchor, constant: 8),
            charCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
            charCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18)
        ])
    }

    private func updateCharCount() {
        let count = descriptionView.text.count
        charCountLabel.text = "\(count) / 200"
        charCountLabel.textColor = count > 180
            ? UIColor(red: 1, green: 0.5, blue: 0.3, alpha: 0.8)
            : UIColor(white: 1, alpha: 0.2)
    }

    @objc private func iconTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.12, animations: {
            self.iconButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            UIView.animate(withDuration: 0.35, delay: 0,
                           usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8) {
                self.iconButton.transform = .identity
            }
        }
        descriptionView.becomeFirstResponder()
    }
}

extension RoutineHeroCard: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        descPlaceholder.isHidden = !textView.text.isEmpty
        if textView.text.count > 200 { textView.text = String(textView.text.prefix(200)) }
        updateCharCount()
    }
}
