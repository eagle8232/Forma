//
//  DependencyContainer.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/9/26.
//

import Foundation

class DependencyContainer {
    
    static let shared = DependencyContainer()
    private var services: [String: Any] = [:]
    
    private init() {}
    
    func register<Service>(_ type: Service.Type, service: Service) {
        let key = String(describing: type)
        services[key] = service
    }
    
    func resolve<Service>(_ type: Service) -> Service {
        let key = String(describing: type)
        guard let service = services[key] as? Service else {
            fatalError("Dependency for \(type) not found! Ensure it is registered.")
        }
        return service
    }
}
