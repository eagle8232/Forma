//
//  BreathLineView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

// MARK: - Breathing Line

struct BreathingLineView: View {
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.2

    var body: some View {
        Capsule()
            .fill(.white.opacity(opacity))
            .scaleEffect(x: scale, y: 1)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.6)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.0
                    opacity = 0.5
                }
            }
    }
}
