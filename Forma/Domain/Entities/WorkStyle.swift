//
//  WorkStyle.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import Foundation

enum WorkStyle: String, CaseIterable {
    case remote = "Remote"
    case hybrid = "Hybrid"
    case office = "Office"
    case flexible = "Flexible"
    
    var icon: String {
        switch self {
        case .remote:   return "🏠"
        case .hybrid:   return "🔄"
        case .office:   return "🏢"
        case .flexible: return "⚡"
        }
    }
}
