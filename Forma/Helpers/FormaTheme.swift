import SwiftUI

enum FormaTheme {
    
    enum Palette {
        static let accent = Color.adaptive(dark: Color.hex("#A259FF"), light: Color.black)
        static let accentPrimary = Color.adaptive(dark: Color(red: 0.55, green: 0.40, blue: 1.00), light: Color.black)
        static let accentSecondary = Color.adaptive(dark: Color(red: 0.30, green: 0.55, blue: 1.00), light: Color.black)
        
        static var background: Color { Color.adaptive(dark: Color.hex("#060606"), light: Color.white) }
        static var secondaryBackground: Color { Color.adaptive(dark: Color.hex("#0E0E0E"), light: Color.hex("#F5F5F7")) }
        static var tertiaryBackground: Color { Color.adaptive(dark: Color.hex("#141414"), light: Color.hex("#FFFFFF")) }
        
        static var surface1: Color { Color.adaptive(dark: Color.hex("#1A1A1A"), light: Color.hex("#F5F5F7")) }
        static var surface2: Color { Color.adaptive(dark: Color.hex("#222222"), light: Color.hex("#FFFFFF")) }
        static var surface3: Color { Color.adaptive(dark: Color.hex("#2A2A2A"), light: Color.hex("#E5E5E5")) }
        
        static var border: Color { Color.adaptive(dark: Color.white.opacity(0.10), light: Color.black.opacity(0.1)) }
        static var border2: Color { Color.adaptive(dark: Color.white.opacity(0.15), light: Color.black.opacity(0.15)) }
        
        static var textPrimary: Color { Color.adaptive(dark: Color.white, light: Color.black) }
        static var textSecondary: Color { Color.adaptive(dark: Color.white.opacity(0.75), light: Color.black.opacity(0.75)) }
        static var textTertiary: Color { Color.adaptive(dark: Color.white.opacity(0.50), light: Color.black.opacity(0.50)) }
        static var textDisabled: Color { Color.adaptive(dark: Color.white.opacity(0.35), light: Color.black.opacity(0.35)) }
        
        static var textMuted: Color { Color.adaptive(dark: Color.hex("#888888"), light: Color.hex("#666666")) }
        static var textMuted2: Color { Color.adaptive(dark: Color.hex("#505050"), light: Color.hex("#999999")) }
        
        static let green = Color.hex("#4CD97B")
        static let error = Color(red: 1.0, green: 0.2, blue: 0.3)
        
        static var shadow: Color { Color.adaptive(dark: Color.clear, light: Color.black.opacity(0.1)) }
        static var overlay: Color { Color.adaptive(dark: Color.black.opacity(0.5), light: Color.black.opacity(0.3)) }
        
        static var white: Color { Color.white }
        static var black: Color { Color.black }
    }
    
    static var adaptiveBackground: Color {
        Color.adaptive(dark: Color.hex("#060606"), light: Color.white)
    }
    
    static var adaptiveSurface1: Color {
        Color.adaptive(dark: Color.hex("#1A1A1A"), light: Color.hex("#F5F5F7"))
    }
    
    static var adaptiveSurface2: Color {
        Color.adaptive(dark: Color.hex("#222222"), light: Color.hex("#FFFFFF"))
    }
    
    static var adaptiveBorder: Color {
        Color.adaptive(dark: Color.white.opacity(0.1), light: Color.black.opacity(0.1))
    }
    
    static var adaptiveTextPrimary: Color {
        Color.adaptive(dark: Color.white, light: Color.black)
    }
    
    static var adaptiveTextSecondary: Color {
        Color.adaptive(dark: Color.white.opacity(0.7), light: Color.black.opacity(0.7))
    }
    
    static var adaptiveTextMuted: Color {
        Color.adaptive(dark: Color.white.opacity(0.5), light: Color.black.opacity(0.5))
    }
}

extension View {
    @ViewBuilder
    func adaptiveBackground(dark: Color, light: Color) -> some View {
        self.modifier(AdaptiveBackgroundModifier(dark: dark, light: light))
    }
    
    @ViewBuilder
    func adaptiveForeground(dark: Color, light: Color) -> some View {
        self.modifier(AdaptiveForegroundModifier(dark: dark, light: light))
    }
}

private struct AdaptiveBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let dark: Color
    let light: Color
    
    func body(content: Content) -> some View {
        content.background(colorScheme == .dark ? dark : light)
    }
}

private struct AdaptiveForegroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let dark: Color
    let light: Color
    
    func body(content: Content) -> some View {
        content.foregroundColor(colorScheme == .dark ? dark : light)
    }
}
