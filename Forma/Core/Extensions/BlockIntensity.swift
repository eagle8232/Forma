//
//  BlockIntensity.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

import UIKit

extension BlockIntensity {
    var color: UIColor {
        switch self {
        case .low: return UIColor(hex: "#4FD1A5")
        case .medium: return UIColor(hex: "#F8C44F")
        case .high: return UIColor(hex: "#F86F4F")
        }
    }
}
