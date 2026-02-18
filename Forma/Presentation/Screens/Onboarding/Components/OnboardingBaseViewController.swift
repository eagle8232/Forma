//
//  OnboardingBaseViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

protocol OnboardingBaseViewControllerDelegate: AnyObject {
    func didTapButton(_ view: OnboardingBaseViewController)
}

class OnboardingBaseViewController: BaseViewController {
    
    weak var delegate: OnboardingBaseViewControllerDelegate?
    private var bottomGradientView: UIView!
    lazy var textView = FormaTextView()
    lazy var button = FormaButton()
    
    override func setupViews() {
        super.setupViews()
    }
    
    func setupViews(
        onboardingTitle: String,
        onboardingSubtitle: String,
        highlightedWord: String,
        buttonTitle: String,
    ) {
        textViewSetup(onboardingTitle: onboardingTitle,
                      onboardingSubtitle: onboardingSubtitle,
                      highlightedWord: highlightedWord)
        buttonSetup(buttonTitle: buttonTitle)
    }
}

extension OnboardingBaseViewController {
    private func textViewSetup(
        onboardingTitle: String,
        onboardingSubtitle: String,
        highlightedWord: String
    ) {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setAlignment(.leading)
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        textView.addTitleWithHighlight(onboardingTitle,
                                       markWords: [(highlightedWord, UIColor.accent)],
                                       typography: .displayLarge,
                                       alignment: .left,
                                       lineSpacing: 1)
        textView.addBody(onboardingSubtitle,
                         color: UIColor.textSecondary)
    }
}

// MARK: - Continue Button Setup
extension OnboardingBaseViewController {
    private func buttonSetup(buttonTitle: String) {
        // - Add shadow to the button
        bottomGradientView = UIView()
        bottomGradientView.translatesAutoresizingMaskIntoConstraints = false
        bottomGradientView.isUserInteractionEnabled = false
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.backgroundPrimary.withAlphaComponent(0.85).cgColor,
            UIColor.backgroundPrimary.cgColor
        ]
        gradientLayer.locations = [0.0, 0.4, 0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        bottomGradientView.layer.addSublayer(gradientLayer)
        
        button.setTitle(buttonTitle)
        button.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        view.addSubview(bottomGradientView)
        
        NSLayoutConstraint.activate([
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            
            bottomGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomGradientView.heightAnchor.constraint(equalToConstant: Constants.buttonHeight + 10),
        ])
    }
    
    @objc private func didTapContinue() {
        delegate?.didTapButton(self)
    }
}
