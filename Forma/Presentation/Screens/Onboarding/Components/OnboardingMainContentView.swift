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
    func didTapSignInWithApple(_ view: OnboardingMainContentView)
    func didTapSignInWithGoogle(_ view: OnboardingMainContentView)
}

extension OnboardingMainContentViewDelegate {
    func didTapSignInWithApple(_ view: OnboardingMainContentView) {}
    func didTapSignInWithGoogle(_ view: OnboardingMainContentView) {}
}

final class OnboardingMainContentView: UIView {

    weak var delegate: OnboardingMainContentViewDelegate?

    // MARK: - UI

    private lazy var textView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    private lazy var getStartedButton: FormaButton = {
        let button = FormaButton(configuration: .init(title: "Get Started →", backgroundColor: UIColor.clear))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 28
        button.clipsToBounds = true

        button.addTarget(self, action: #selector(getStartedButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    private lazy var separatorLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        return view
    }()

    private lazy var signInLabel: UILabel = createSignInLabel()
    
    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        addSubview(textView)
        addSubview(buttonsStack)
        addSubview(separatorLine)
        
        // Only: Get Started button + sign in link
        buttonsStack.addArrangedSubview(getStartedButton)
        buttonsStack.addArrangedSubview(signInLabel)

        getStartedButton.heightAnchor.constraint(equalToConstant: 56).isActive = true

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -24),

            buttonsStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonsStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separatorLine.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -16),
            separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        
        textView.addHeading(
            "Evolve from managing tasks to architecting rituals.",
            typography: .heading3,
            alignment: .center
        )

        [textView, getStartedButton, signInLabel]
            .enumerated()
            .forEach { index, view in
                view.animateIn(delay: CGFloat(index) * 0.08)
            }
    }

    // MARK: - Sign In Label

    private func createSignInLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center

        let fullText = "Already have an account? Sign in"
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.white.withAlphaComponent(0.45)
            ]
        )
        let signInRange = (fullText as NSString).range(of: "Sign in")
        attributed.addAttributes([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: signInRange)

        label.attributedText = attributed
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInTapped)))
        return label
    }

    // MARK: - Actions

    @objc private func appleButtonTapped() {
        delegate?.didTapSignInWithApple(self)
    }

    @objc private func googleButtonTapped() {
        delegate?.didTapSignInWithGoogle(self)
    }

    @objc private func getStartedButtonTapped() {
        delegate?.didTapGetStarted(self)
    }

    @objc private func signInTapped() {
        delegate?.didTapSignIn(self)
    }

    // MARK: - Button Press Animations

    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.12, delay: 0, options: .curveEaseIn) {
            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            sender.alpha = 0.85
        }
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 6
        ) {
            sender.transform = .identity
            sender.alpha = 1.0
        }
    }
}
