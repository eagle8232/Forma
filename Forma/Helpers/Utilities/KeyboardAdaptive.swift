//
//  KeyboardAdaptive.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI
import Combine

// MARK: - Publisher

extension Publishers {
    /// Emits the visible height of the keyboard (0 when hidden).
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let show = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height
            }
        
        let hide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat.zero }
        
        return show.merge(with: hide)
            .eraseToAnyPublisher()
    }
}

// MARK: - ViewModifier

/// Pads the view's bottom by the keyboard height, animated with the
/// keyboard's own curve and duration so the layout moves in perfect sync.
struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { height in
                // Mirror the keyboard animation exactly
                let duration = 0.25
                withAnimation(.easeOut(duration: duration)) {
                    keyboardHeight = height
                }
            }
    }
}

extension View {
    /// Automatically adds bottom padding equal to the keyboard height.
    func keyboardAdaptive() -> some View {
        modifier(KeyboardAdaptive())
    }
}

