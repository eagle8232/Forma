//
//  EnergyPeakViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

final class EnergyPeakViewController: OnboardingBaseViewController {
    
    // MARK: Coordinator
    weak var coordinator: OnboardingCoordinator?
    
    // MARK: Properties
    private var wakeUpTime: Date?
    private var sleepTime: Date?
    
    private lazy var energyPeakContentView = EnergyPeakContentView()
    
    override func setupViews() {
        super.setupViews()
        setup()
        energyPeakContentViewSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set default values
        self.wakeUpTime = energyPeakContentView.getWakeUpTime()
        self.sleepTime = energyPeakContentView.getSleepTime()
    }
    
    private func setup() {
        setupViews(onboardingTitle: "When does your\nenergy peak?",
                   onboardingSubtitle: "Help us align your routines with your natural rhythm.",
                   highlightedWord: "energy peak?",
                   buttonTitle:  "Next")
        delegate = self
    }
}

extension EnergyPeakViewController: OnboardingBaseViewControllerDelegate {
    func didTapButton(_ view: OnboardingBaseViewController) {
        guard let wakeUpTime = self.wakeUpTime,
              let sleepTime = self.sleepTime else {
            return
        }
        
        let newUserPreferences = UserPreferences(profession: "No profession selected",
                                                 sleepTime: sleepTime,
                                                 wakeUpTime: wakeUpTime,
                                                 focusTime: Date(),
                                                 goal: [])
        
        self.coordinator?.showFocusBeginScreen(newUserPreferences)
    }
}

// MARK: - EnergyPeakContentViewDelegate
extension EnergyPeakViewController: EnergyPeakContentViewDelegate {
    func energyPeakContentView(_ view: EnergyPeakContentView, didSelectWakeTime date: Date) {
        self.wakeUpTime = date
    }
    
    func energyPeakContentView(_ view: EnergyPeakContentView, didSelectSleepTime date: Date) {
        self.sleepTime = date
    }
}

// MARK: - EnergyPeakContentView Setup
extension EnergyPeakViewController {
    private func energyPeakContentViewSetup() {
        energyPeakContentView.delegate = self
        energyPeakContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(energyPeakContentView)
        
        NSLayoutConstraint.activate([
            energyPeakContentView.topAnchor.constraint(equalTo: self.textView.bottomAnchor, constant: 16),
            energyPeakContentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            energyPeakContentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            energyPeakContentView.bottomAnchor.constraint(equalTo: self.bottomGradientView.topAnchor, constant: -8)
        ])
        
    }
}

