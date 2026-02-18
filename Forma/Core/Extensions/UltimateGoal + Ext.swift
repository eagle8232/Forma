//
//  UltimateGoal + Ext.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

extension UltimateGoal {
    var accentColor: UIColor {
        switch self {
        case .masterDailyStructure: return UIColor(hex: "#4F9EF8")
        case .stopProcrastinating:  return UIColor(hex: "#F8C44F")
        case .deepWorkFocus:        return UIColor(hex: "#4FD1A5")
        case .reduceOverwhelm:      return UIColor(hex: "#9B7FE8")
        case .improveSleepHygiene:  return UIColor(hex: "#6C8EF8")
        case .buildHealthyHabits:   return UIColor(hex: "#81C784")
        case .consistentExercise:   return UIColor(hex: "#F86F4F")
        case .workLifeBalance:      return UIColor(hex: "#F84F9E")
        case .gainClarity:          return UIColor(hex: "#F8A44F")
        }
    }
}
