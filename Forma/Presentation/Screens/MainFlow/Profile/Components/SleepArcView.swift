//
//  SleepArcView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct SleepArcView: View {
    let wakeFormatted: String
    let sleepFormatted: String
    let awakeDuration: String

    private let gold = Color(hex: "#A259FF")
    private let blue = Color(hex: "#5B9CF6")
    private let textPrimary = Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black)
    private let textMuted = Color.adaptive(dark: Color(hex: "#4A4848"), light: Color(hex: "#666666"))

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                let w = geo.size.width
                let h: CGFloat = 70

                ZStack {
                    ArcShape()
                        .stroke(
                            Color.adaptive(dark: Color(hex: "#1C1C1C"), light: Color(hex: "#E5E5E5")),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: w, height: h)

                    ArcShape()
                        .stroke(
                            LinearGradient(
                                colors: [gold, gold.opacity(0.4), blue.opacity(0.4), blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: w, height: h)

                    Circle()
                        .fill(gold.opacity(0.1))
                        .frame(width: 18, height: 18)
                        .offset(x: -w/2 + 24, y: h/2 - 4)

                    Circle()
                        .fill(gold)
                        .frame(width: 10, height: 10)
                        .offset(x: -w/2 + 24, y: h/2 - 4)

                    Text("☀")
                        .font(.system(size: 12))
                        .foregroundColor(gold.opacity(0.5))
                        .offset(x: -w/2 + 24, y: h/2 - 22)

                    Circle()
                        .fill(blue.opacity(0.1))
                        .frame(width: 18, height: 18)
                        .offset(x: w/2 - 24, y: h/2 - 4)

                    Circle()
                        .fill(blue)
                        .frame(width: 10, height: 10)
                        .offset(x: w/2 - 24, y: h/2 - 4)

                    Text("🌙")
                        .font(.system(size: 12))
                        .foregroundColor(blue.opacity(0.5))
                        .offset(x: w/2 - 24, y: h/2 - 22)

                    VStack(spacing: 2) {
                        Text(awakeDuration)
                            .font(.custom("Cormorant Garamond", size: 26))
                            .fontWeight(.ultraLight)
                            .foregroundColor(textPrimary)
                        Text("AWAKE")
                            .font(.custom("Manrope", size: 8))
                            .kerning(2.8)
                            .foregroundColor(textMuted)
                    }
                    .offset(y: -6)
                }
            }
            .frame(height: 70)

            HStack {
                Text(wakeFormatted)
                    .font(.custom("Manrope", size: 9))
                    .tracking(1.5)
                    .foregroundColor(textMuted)
                Spacer()
                Text(sleepFormatted)
                    .font(.custom("Manrope", size: 9))
                    .tracking(1.5)
                    .foregroundColor(textMuted)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startX: CGFloat = 24
        let endX: CGFloat = rect.width - 24
        let bottomY: CGFloat = rect.height - 4
        let controlY: CGFloat = -rect.height * 0.35

        path.move(to: CGPoint(x: startX, y: bottomY))
        path.addQuadCurve(
            to: CGPoint(x: endX, y: bottomY),
            control: CGPoint(x: rect.midX, y: controlY)
        )
        return path
    }
}
