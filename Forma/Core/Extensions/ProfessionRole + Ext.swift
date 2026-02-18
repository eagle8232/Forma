//
//  ProfessionRole + Ext.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

extension ProfessionRole {
    var accentColor: UIColor {
        switch self {
        case .developer:           return UIColor(hex: "#4F9EF8")  // Blue
        case .designer:            return UIColor(hex: "#F86F4F")  // Orange
        case .medicalProfessional: return UIColor(hex: "#4FD1A5")  // Teal
        case .founderEntrepreneur: return UIColor(hex: "#F8C44F")  // Gold
        case .student:             return UIColor(hex: "#9B7FE8")  // Purple
        case .managerLead:         return UIColor(hex: "#4FC3F8")  // Light blue
        case .freelancer:          return UIColor(hex: "#F84F9E")  // Pink
        case .salesMarketing:      return UIColor(hex: "#F8814F")  // Deep orange
        case .teacherEducator:     return UIColor(hex: "#81C784")  // Green
        case .parentHomemaker:     return UIColor(hex: "#F8A44F")  // Amber
        case .artistCreative:      return UIColor(hex: "#CE93D8")  // Lavender
        case .other:               return UIColor.accent
        }
    }
}
