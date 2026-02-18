//
//  UltimateGoalViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

final class UltimateGoalViewController: OnboardingBaseViewController {
    
    weak var coordinator: OnboardingCoordinator?
    var userPreferences: UserPreferences?
    
    override func setupViews() {
        super.setupViews()
        setupViews(onboardingTitle: "Define your\nultimate goal.",
                   onboardingSubtitle: "Select up to 3 intentions. We will optimize your Al-generated routines to achieve these outcomes.",
                   highlightedWord: "ultimate goal.",
                   buttonTitle: "✨Generate My First Routine")
    }
}
