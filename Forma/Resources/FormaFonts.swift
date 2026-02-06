//
//  FormaFonts.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/6/26.
//

import Foundation

enum FormaFonts: String {
    
    case heroHeadline = "PlayfairDisplay-Bold"
    case sectionTitle = "PlayfairDisplay-Medium"
    case bodyPrimary = "Raleway-Regular"
    case capsuleLabel = "Raleway-Medium"
    case callToAction = "Raleway-Bold"
    case statusLabel = "Raleway-Light"
    case footnote = "Raleway-ExtraLight"
    
    var italic: String {

        guard !self.rawValue.hasSuffix("Regular") else {
            let filteredFontName = self.rawValue.replacingOccurrences(of: "Regular", with: "Italic")
            print(filteredFontName)
            return "\(filteredFontName)"
        }
        
        print("\(self.rawValue)Italic")
        return "\(self.rawValue)Italic"
    }
}
