//
//  OnboardingContentView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/14/26.
//

import UIKit

protocol OnboardingMainContentViewDelegate: AnyObject {
    func didTapGetStarted(_ view: OnboardingMainContentView)
    func didTapSignIn(_ view: OnboardingMainContentView)
}

final class OnboardingMainContentView: UIView {
    
    weak var delegate: OnboardingMainContentViewDelegate?
    
    private lazy var verticalStackView = UIStackView()
    private lazy var signInLabel = UILabel()
    private lazy var textView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    private lazy var button: FormaButton = {
        let button = FormaButton.primary(title: "Get started")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        setupButton()
        setupTextView()
        [textView, button, signInLabel].enumerated().forEach { index, view in
            view.animateIn(delay: CGFloat(index * 10)) // a bit longer
        }
    }
    
    private func setupTextView() {
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: verticalStackView.topAnchor, constant: -24)
        ])
        
        textView
            .addHeading("Evolve from managing tasks to architecting rituals.",
                     alignment: .center)
    }
    
    private func setupButton() {
        verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 12
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .fill
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Get started button
        button.addTarget(self, action: #selector(getStartedButtonTapped), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        // Sign in label
        signInLabel = createSignInLabel()
        
        // Add to stack
        verticalStackView.addArrangedSubview(button)
        verticalStackView.addArrangedSubview(signInLabel)
        
        addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            verticalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        [button, signInLabel].enumerated().forEach { index, view in
            view.animateIn(delay: CGFloat(index))
        }
    }
    
    private func createSignInLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
        
        let fullText = "Already have an account? Sign in"
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.typography(.caption),
                .foregroundColor: UIColor.textSecondary
            ]
        )
        
        let signInRange = (fullText as NSString).range(of: "Sign in")
        attributedString.addAttributes([
            .font: UIFont.typography(.caption),
            .foregroundColor: UIColor.accent
        ], range: signInRange)
        
        label.attributedText = attributedString
        label.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(signInTapped))
        label.addGestureRecognizer(tapGesture)
        
        return label
    }
    
    @objc private func getStartedButtonTapped() {
        print("Continue button tapped")
        delegate?.didTapGetStarted(self)
    }
    
    @objc private func signInTapped() {
        delegate?.didTapSignIn(self)
    }
}
