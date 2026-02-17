//
//  FocusBeginViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/15/26.
//

import UIKit

final class FocusBeginViewController: BaseViewController {
    
    
    // MARK: - Properties
    weak var coordinator: OnboardingCoordinator?
    var userPreferences: UserPreferences?
    private lazy var textView = FormaTextView()
    
    override func setupViews() {
        super.setupViews()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        guard var userPreferences else {
            print("No user preferences found")
            return
        }
        
        textView.addHeading("Wake up time: \(userPreferences.wakeUpTime.formatted(date: .abbreviated, time: .shortened))\nSleep time: \(userPreferences.sleepTime.formatted(date: .abbreviated, time: .shortened))")
    }
}
