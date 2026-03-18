//
//  StatusDotView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct StatusDot: View {
    let isDone: Bool
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Outer ring — pulses while active
            Circle()
                .stroke(.white.opacity(isDone ? 0 : 0.15), lineWidth: 0.5)
                .frame(width: 10, height: 10)
                .scaleEffect(pulse ? 1.6 : 1.0)
                .opacity(pulse ? 0 : 1)

            // Core dot
            Circle()
                .fill(.white.opacity(isDone ? 0.25 : 0.55))
                .frame(width: 4, height: 4)
        }
        .onAppear {
            guard !isDone else { return }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: false)) {
                pulse = true
            }
        }
        .onChange(of: isDone, { _, done in
            if done { pulse = false }
        })
    }
}
