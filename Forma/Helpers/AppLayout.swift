import SwiftUI

enum AppRadius {
    static let sm:       CGFloat = 10
    static let md:       CGFloat = 14
    static let lg:       CGFloat = 16
    static let xl:       CGFloat = 20
    static let card:     CGFloat = 20
    static let cardLg:   CGFloat = 24
    static let panel:    CGFloat = 18
    static let button:   CGFloat = 26
    static let buttonSm: CGFloat = 16
    static let capsule:  CGFloat = 999
    static let logo:     CGFloat = 22
    static let toast:    CGFloat = 14
    static let stepperInner: CGFloat = 8
    static let tag:      CGFloat = 6
    static let dot:      CGFloat = 999
}

enum AppSpacing {
    static let screenH:       CGFloat = 28
    static let screenHWide:   CGFloat = 32
    static let screenBottom:  CGFloat = 52
    static let screenTop:     CGFloat = 56
    static let sectionGap:    CGFloat = 20
    static let blockGap:      CGFloat = 16
    static let itemGap:       CGFloat = 12
    static let tightGap:      CGFloat = 8
    static let microGap:      CGFloat = 4
    static let rowV:          CGFloat = 18
    static let rowLeading:    CGFloat = 8
    static let rowTrailing:   CGFloat = 20
    static let panelH:        CGFloat = 24
    static let panelV:        CGFloat = 20
    static let buttonH:        CGFloat = 32
    static let buttonHeight:   CGFloat = 54
    static let buttonHeightLg: CGFloat = 60
    static let stepperH:       CGFloat = 20
    static let stepperV:       CGFloat = 18
    static let dividerLeadingInset: CGFloat = 68
    static let xl:           CGFloat = 32
    static let xxl:          CGFloat = 48
}

enum AppAnimation {
    static let spring      = Animation.spring(response: 0.42, dampingFraction: 0.82)
    static let springFast  = Animation.spring(response: 0.28, dampingFraction: 0.75)
    static let springGentle = Animation.spring(response: 0.55, dampingFraction: 0.82)
    static let springBouncy = Animation.spring(response: 0.45, dampingFraction: 0.75)
    static let easeIn  = Animation.easeInOut(duration: 0.2)
    static let easeStd = Animation.easeOut(duration: 0.4)
    static let easeSlow = Animation.easeOut(duration: 0.6)
    static let appearDelay0: Double = 0.05
    static let appearDelay1: Double = 0.14
    static let appearDelay2: Double = 0.24
    static let press = Animation.easeInOut(duration: 0.1)
    static let fadeSwap = Animation.easeInOut(duration: 0.4)
    static let pressedScale: CGFloat = 0.985
    static let appearFromScale: CGFloat = 0.97
}

enum AppSize {
    static let logoContainer: CGFloat = 72
    static let logoIcon:       CGFloat = 32
    static let dotCore:  CGFloat = 4
    static let dotRing:  CGFloat = 10
    static let iconSm:   CGFloat = 11
    static let iconMd:   CGFloat = 14
    static let iconLg:   CGFloat = 16
    static let iconXLg:  CGFloat = 18
    static let hairline: CGFloat = 0.5
    static let breathingLineW: CGFloat = 24
    static let breathingLineH: CGFloat = 1
    static let completionMarkW: CGFloat = 20
    static let stepperButton: CGFloat = 44
    static let durationArcH: CGFloat = 3
}
