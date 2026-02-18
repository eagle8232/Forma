//
//  ProfessionRole.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import Foundation

enum ProfessionRole: String, CaseIterable {
    case developer           = "Developer"
    case designer            = "Designer"
    case medicalProfessional = "Medical Professional"
    case founderEntrepreneur = "Founder / Entrepreneur"
    case student             = "Student"
    case managerLead         = "Manager / Lead"
    case freelancer          = "Freelancer / Consultant"
    case salesMarketing      = "Sales & Marketing"
    case teacherEducator     = "Teacher / Educator"
    case parentHomemaker     = "Parent / Homemaker"
    case artistCreative      = "Artist / Creative"
    case other               = "Other"
    
    var icon: String {
        switch self {
        case .developer:           return "💻"
        case .designer:            return "🎨"
        case .medicalProfessional: return "⚕️"
        case .founderEntrepreneur: return "🚀"
        case .student:             return "📚"
        case .managerLead:         return "👥"
        case .freelancer:          return "🌐"
        case .salesMarketing:      return "📈"
        case .teacherEducator:     return "🎓"
        case .parentHomemaker:     return "🏡"
        case .artistCreative:      return "✨"
        case .other:               return "⚡️"
        }
    }
    
    // Whether to span full width
    var isWide: Bool {
        return rawValue.count > 18
    }
}
