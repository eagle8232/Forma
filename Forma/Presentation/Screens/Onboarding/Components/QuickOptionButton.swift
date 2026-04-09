//
//  QuickOptionButton.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

// SelectableOptionButton.swift

import UIKit

final class SelectableOptionButton: UIButton {
    
    // MARK: - Properties
    
    private(set) var optionTitle: String
    private(set) var isOptionSelected: Bool = false
    
    // MARK: - Initialization
    
    init(title: String) {
        self.optionTitle = title
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(optionTitle, for: .normal)
        titleLabel?.font = .typography(.buttonMedium)
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        layer.cornerRadius = 14
        applyUnselectedStyle()
    }
    
    // MARK: - Style Methods
    
    func applySelectedStyle() {
        isOptionSelected = true
        backgroundColor = .clear
        layer.borderWidth = 2
        layer.borderColor = UIColor.adaptiveAccent.cgColor
        setTitleColor(.adaptiveAccent, for: .normal)
        layer.shadowColor = UIColor.adaptiveAccent.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 8
        layer.shadowOffset = .zero
    }
    
    func applyUnselectedStyle() {
        isOptionSelected = false
        backgroundColor = .adaptiveBackgroundSecondary
        layer.borderWidth = 1
        layer.borderColor = UIColor.adaptiveBackgroundSecondary.cgColor
        setTitleColor(.adaptiveTextSecondary, for: .normal)
        layer.shadowOpacity = 0
    }
    
    // MARK: - Animation
    
    func animateTap(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    usingSpringWithDamping: 0.6,
                    initialSpringVelocity: 0.5
                ) {
                    self.transform = .identity
                } completion: { _ in
                    completion?()
                }
            }
        )
    }
}
