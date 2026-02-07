//
//  CoordinatorProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}
