//
//  HomeCoordinator+SleepEdit.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import UIKit
import SwiftUI

extension HomeCoordinator {

    func showSleepScheduleEdit(user: User) {
        guard let preferences = user.preferences else { return }

        let view = SleepScheduleEditView(
            preferences: preferences,
            onCancel: { [weak self] in
                self?.navigationController.popViewController(animated: true)
            },
            onSaved: { [weak self] updatedPreferences in
                if let currentUser = DependencyContainer.shared.currentUser {
                    let updatedUser = User(
                        credentials: currentUser.credentials,
                        preferences: updatedPreferences
                    )
                    DependencyContainer.shared.currentUser = updatedUser
                    CoreDataManager.shared.saveUser(updatedUser)
                }
                self?.navigationController.popViewController(animated: true)
            }
        )

        let vc = UIHostingController(rootView: view)
        vc.view.backgroundColor = UIColor(red: 0.024, green: 0.024, blue: 0.024, alpha: 1)
        vc.navigationItem.hidesBackButton = true
        navigationController.pushViewController(vc, animated: true)
    }
}
