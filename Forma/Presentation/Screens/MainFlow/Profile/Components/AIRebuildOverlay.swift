//
//  AIRebuildOverlay.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct AIRebuildOverlay: View {
    let currentStep: Int

    private let gold = Color(hex: "#A259FF")
    private let textPrimary = Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black)
    private let textMuted = Color.adaptive(dark: Color(hex: "#4A4848"), light: Color(hex: "#666666"))
    private let textMuted2 = Color.adaptive(dark: Color(hex: "#282828"), light: Color(hex: "#CCCCCC"))
    private let green = Color(hex: "#4CD97B")

    private let steps = [
        "Reading preferences",
        "Fetching prayer times",
        "Generating routines",
        "Optimising your day"
    ]

    @State private var isPulsing: Bool = false
    @State private var subtitleOpacity: Double = 0.4

    var body: some View {
        ZStack {
            Color.adaptive(dark: Color(hex: "#060606").opacity(0.96), light: Color.white)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(gold.opacity(0.04), lineWidth: 1)
                        .frame(width: 116, height: 116)
                        .scaleEffect(isPulsing ? 1.06 : 1.0)

                    Circle()
                        .stroke(gold.opacity(0.08), lineWidth: 1)
                        .frame(width: 98, height: 98)

                    Circle()
                        .stroke(gold.opacity(0.2), lineWidth: 1)
                        .frame(width: 80, height: 80)

                    Text("✦")
                        .font(.system(size: 30))
                        .foregroundColor(gold)
                }
                .animation(
                    .easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: isPulsing
                )

                Text("Rebuilding your day")
                    .font(.custom("Cormorant Garamond", size: 30))
                    .fontWeight(.light)
                    .foregroundColor(textPrimary)

                Text(currentStep > 0 && currentStep <= steps.count ? steps[currentStep - 1] : "")
                    .font(.custom("Cormorant Garamond", size: 16))
                    .italic()
                    .foregroundColor(textMuted)
                    .opacity(subtitleOpacity)
                    .animation(.easeInOut(duration: 0.4), value: currentStep)

                VStack(spacing: 10) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(stepColor(for: index))
                                .frame(width: 6, height: 6)

                            Text(step.uppercased())
                                .font(.custom("Manrope", size: 11))
                                .tracking(1.5)
                                .foregroundColor(stepColor(for: index))
                        }
                        .scaleEffect(currentStep == index + 1 ? 1.1 : 1.0)
                        .animation(.easeIn(duration: 0.3), value: currentStep)
                    }
                }
            }
        }
        .onAppear {
            isPulsing = true
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                subtitleOpacity = 0.9
            }
        }
        .onChange(of: currentStep) { _, _ in
            subtitleOpacity = 0.4
            withAnimation(.easeInOut(duration: 0.5)) {
                subtitleOpacity = 0.9
            }
        }
    }

    private func stepColor(for index: Int) -> Color {
        if index + 1 < currentStep {
            return green
        } else if index + 1 == currentStep {
            return gold
        } else {
            return textMuted2
        }
    }
}
