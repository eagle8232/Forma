//
//  RoutineCardView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/13/26.
//

import SwiftUI

struct RoutineCardView: View {
    let icon: String
    let title: String
    let timeRange: String
    let description: String
    var glowColor: Color = Color(red: 1.0, green: 0.6, blue: 0.2)

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {

            // Icon stage
            ZStack {
                // Radial glow from icon
                RadialGradient(
                    colors: [glowColor.opacity(0.22), .clear],
                    center: UnitPoint(x: 0.5, y: 0.65),
                    startRadius: 0,
                    endRadius: 110
                )

                // Concentric rings
                Circle()
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                    .frame(width: 100, height: 100)

                Circle()
                    .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                    .frame(width: 152, height: 152)

                // Icon
                Text(icon)
                    .font(.system(size: 58))
                    .shadow(color: glowColor.opacity(0.6), radius: 24, x: 0, y: 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 148)
            .clipped()

            // Hairline divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.10), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 20)

            // Text body
            VStack(alignment: .leading, spacing: 6) {
                Text(timeRange.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(1.8)
                    .foregroundColor(glowColor.opacity(0.8))

                Text(title)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.93))
                    .tracking(-0.4)

                Text(description)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.42))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 22)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.07, blue: 0.20),
                    Color(red: 0.03, green: 0.02, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.7), radius: 40, x: 0, y: 24)
        .frame(width: 300)
        .scaleEffect(appeared ? 1 : 0.92)
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.05), value: appeared)
        .onAppear { appeared = true }
    }
}
