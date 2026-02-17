//
//  EnergyPeakViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

final class EnergyPeakViewController: BaseViewController {
    
    // MARK: Coordinator
    weak var coordinator: OnboardingCoordinator?
    
    // MARK: Properties
    private var wakeUpTime: Date?
    private var sleepTime: Date?
    
    private lazy var textView = FormaTextView()
    private lazy var energyPeakContentView = EnergyPeakContentView()
    private lazy var continueButton = FormaButton()
    
    override func setupViews() {
        super.setupViews()
        textViewSetup()
        energyPeakContentViewSetup()
        continueButtonSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set default values
        self.wakeUpTime = energyPeakContentView.getWakeUpTime()
        self.sleepTime = energyPeakContentView.getSleepTime()
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

// MARK: - TextView Setup
extension EnergyPeakViewController {
    
    private func textViewSetup() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setAlignment(.leading)
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        textView.addTitleWithHighlight("When does your\nenergy peak?",
                                       markWords: [("energy peak?", UIColor.accent)],
                                       typography: .displayLarge,
                                       alignment: .left,
                                       lineSpacing: 1)
        textView.addBody("Help us align your routines with your natural rhythm.",
                         color: UIColor.textSecondary)
    }
}

// MARK: - EnergyPeakContentView Setup
extension EnergyPeakViewController {
    private func energyPeakContentViewSetup() {
        energyPeakContentView.delegate = self
        energyPeakContentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(energyPeakContentView)
        
        NSLayoutConstraint.activate([
            energyPeakContentView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 64),
            energyPeakContentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            energyPeakContentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
    }
}

// MARK: - Continue Button Setup
extension EnergyPeakViewController {
    private func continueButtonSetup() {
        continueButton.setTitle("Next")
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            continueButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            continueButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            continueButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }
    
    @objc func didTapContinue() {
        guard let wakeUpTime, let sleepTime else {
            print("Nothing was selected")
            return
        }
        
        let newUserPreferences = UserPreferences(profession: "No profession selected",
                                                 sleepTime: sleepTime,
                                                 wakeUpTime: wakeUpTime,
                                                 focusTime: Date(),
                                                 goal: "No goal selected")
        coordinator?.showFocusBeginScreen(newUserPreferences)
    }
}
