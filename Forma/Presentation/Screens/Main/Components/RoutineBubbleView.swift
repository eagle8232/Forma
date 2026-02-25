//
//  RoutineBubbleView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/24/26.
//

import UIKit

final class RoutineBubbleView: UIView {

    private let icon: String
    private let baseColor: UIColor
    var onTap: (() -> Void)?

    private let size: CGFloat = 35

    // MARK: - Layers
    
    private let unabledLayer = CAGradientLayer()
    private let gradLayer = CAGradientLayer()
    private let iconLabel = UILabel()

    // MARK: - Init

    init(icon: String, color: String) {
        self.icon      = icon
        self.baseColor = UIColor(hex: color)
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        let r = bounds

        // Gradient circle
        unabledLayer.frame = CGRect(
            x: (r.width - size) / 2,
            y: (r.height - size) / 2,
            width: size,
            height: size
        )
        unabledLayer.cornerRadius = size / 2
        
        gradLayer.frame = CGRect(
            x: (r.width - size) / 2,
            y: (r.height - size) / 2,
            width: size,
            height: size
        )
        gradLayer.cornerRadius = size / 2
    }

    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        clipsToBounds = false

        unabledLayer.colors = [
            UIColor.backgroundSecondary.lighter(by: 0.25).cgColor,
            UIColor.backgroundSecondary.cgColor,
            UIColor.backgroundSecondary.darker(by: 0.25).cgColor
        ]
        unabledLayer.locations = [0, 0.5, 1]
        unabledLayer.startPoint = CGPoint(x: 0.3, y: 0)
        unabledLayer.endPoint   = CGPoint(x: 0.7, y: 1)
        layer.addSublayer(unabledLayer)
        
        gradLayer.colors = [
            baseColor.lighter(by: 0.25).cgColor,
            baseColor.cgColor,
            baseColor.darker(by: 0.25).cgColor
        ]
        gradLayer.locations = [0, 0.5, 1]
        gradLayer.startPoint = CGPoint(x: 0.3, y: 0)
        gradLayer.endPoint   = CGPoint(x: 0.7, y: 1)
        layer.addSublayer(gradLayer)


        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text          = icon
        iconLabel.font          = .systemFont(ofSize: size * 0.45)
        iconLabel.textAlignment = .center
        addSubview(iconLabel)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        // --- Tap ---
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
    // MARK: - Public methods
    public func isEnabled(_ isEnabled: Bool = false) {
        self.gradLayer.borderWidth = 3
        self.gradLayer.borderColor = isEnabled ? UIColor.accent.cgColor : UIColor.backgroundSecondary.cgColor
        self.unabledLayer.opacity = isEnabled ? 0 : 0.5
    }

    // MARK: - Tap

    @objc private func didTap() {
        SoundManager.shared.playHaptic()
        SoundManager.shared.playSound(.buttonTap)
        
        onTap?()

        // Spring press animation
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            UIView.animate(withDuration: 0.45, delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.8) {
                self.transform = .identity
            }
        }
    }

}
