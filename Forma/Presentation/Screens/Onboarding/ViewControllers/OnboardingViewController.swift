//
//  OnboardingViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/10/26.
//

import UIKit
import Lottie

final class OnboardingViewController: BaseViewController {
    
    weak var coordinator: OnboardingCoordinator?
    
    // MARK: - Properties
    private var animationView: LottieAnimationView?
    private var contentView: OnboardingMainContentView!
    private var bottomGradientView: UIView!
    private var gradientLayer: CAGradientLayer!
    private var userPreferences: UserPreferences?
    
    // MARK: - Lifecycle
    override func setupViews() {
        super.setupViews()
        
        setupAnimation()
        setupGradient()
        setupContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = bottomGradientView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animationView?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        animationView?.pause()
    }
    
    deinit {
        animationView?.stop()
        animationView = nil
    }
    
    private func setupContent() {
        contentView = OnboardingMainContentView()
        contentView.delegate = self
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
}

// MARK: - Animation Setup
extension OnboardingViewController {
    private func setupAnimation() {
        animationView = LottieAnimationView(name: "onboarding_bg")
        
        guard let animationView = animationView else {
            print("❌ Failed to load Lottie animation")
            return
        }
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.8
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.alpha = 0
        
        view.insertSubview(animationView, at: 0)
        
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        UIView.animate(withDuration: 1) {
            animationView.alpha = 1
        }
    }
    
}

// MARK: - Gradient Layer Setup
extension OnboardingViewController {
    private func setupGradient() {
        // Create container view for gradient
        bottomGradientView = UIView()
        bottomGradientView.translatesAutoresizingMaskIntoConstraints = false
        bottomGradientView.isUserInteractionEnabled = false
        
        // Create gradient layer
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.adaptiveBackground.withAlphaComponent(0.85).cgColor,
            UIColor.adaptiveBackground.cgColor
        ]
        gradientLayer.locations = [0.0, 0.4, 0.7, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        bottomGradientView.layer.addSublayer(gradientLayer)
        
        // Add gradient view
        view.addSubview(bottomGradientView)
        
        NSLayoutConstraint.activate([
            bottomGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomGradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomGradientView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
        ])
        
    }
}


// MARK: - OnboardingContentViewDelegate
extension OnboardingViewController: OnboardingMainContentViewDelegate {
    
    func didTapGetStarted(_ view: OnboardingMainContentView) {
        coordinator?.showEnergyPeakScreen()
    }
    
    func didTapSignIn(_ view: OnboardingMainContentView) {
        print("[OnboardingVC] didTapSignIn called")
        coordinator?.didTapSignIn()
    }
}

