//
//  CircleProgressView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct CircleProgressView<Center: View>: View {

    // MARK: - Parameters
    let progress: Double           // 0.0 – 1.0
    var size: CGFloat              // overall diameter
    var strokeWidth: CGFloat       // arc stroke width
    var accent: Color              // routine accent color
    var center: () -> Center       // center content

    // MARK: - Init — generic center
    init(
        progress: Double,
        size: CGFloat = 220,
        strokeWidth: CGFloat = 3.5,
        accent: Color = AppColor.accentPrimary,
        @ViewBuilder center: @escaping () -> Center
    ) {
        self.progress    = progress.clamped(to: 0...1)
        self.size        = size
        self.strokeWidth = strokeWidth
        self.accent      = accent
        self.center      = center
    }

    // MARK: - Animated progress state
    @State private var animatedProgress: Double = 0

    // MARK: - Derived geometry
    private var radius: CGFloat { (size - strokeWidth) / 2 }
    private var circumference: CGFloat { 2 * .pi * radius }

    // Offset so arc starts at top (–90°) and fills clockwise
    private var dashOffset: CGFloat {
        circumference * (1 - animatedProgress)
    }

    // Leading dot angle in radians, mapped from top
    private var dotAngle: Double {
        animatedProgress * 2 * .pi - (.pi / 2)
    }

    private var dotX: CGFloat { size / 2 + radius * CGFloat(cos(dotAngle)) }
    private var dotY: CGFloat { size / 2 + radius * CGFloat(sin(dotAngle)) }

    // MARK: - Body

    var body: some View {
        ZStack {
            Canvas { ctx, _ in
                drawRing(in: ctx)
            }
            .frame(width: size, height: size)

            center()
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue.clamped(to: 0...1)
        }
    }

    // MARK: - Canvas drawing

    private func drawRing(in ctx: GraphicsContext) {
        let center = CGPoint(x: size / 2, y: size / 2)
        
        // Ghost track color - adaptive for light/dark mode
        let trackColor = Color.adaptive(dark: Color.white.opacity(0.07), light: Color.black.opacity(0.12))
        // Tip dot color - adaptive for light/dark mode
        let tipColor = Color.adaptive(dark: Color.white.opacity(0.85), light: accent)

        // ── Ghost track — single hairline ──
        drawArc(ctx: ctx, center: center, r: radius,
                color: trackColor, width: 3,
                dashOffset: 0)

        // ── Progress arc — thin, clean ──
        drawArc(ctx: ctx, center: center, r: radius,
                color: accent, width: 3.5,
                dashOffset: dashOffset)

        // ── Tip dot ──
        if animatedProgress > 0.01 {
            ctx.fill(
                dotPath(r: 3),
                with: .color(tipColor)
            )
        }
    }

    // MARK: - Drawing helpers

    private func drawArc(
        ctx: GraphicsContext,
        center: CGPoint,
        r: CGFloat,
        color: Color? = nil,
        gradient: Gradient? = nil,
        width: CGFloat,
        dashOffset: CGFloat,
        blur: CGFloat = 0
    ) {
        var path = Path()
        path.addArc(center: center, radius: r,
                    startAngle: .degrees(-90), endAngle: .degrees(270), clockwise: false)

        let style = StrokeStyle(
            lineWidth: width,
            lineCap: .round,
            dash: [circumference],
            dashPhase: dashOffset
        )

        var copy = ctx
        if blur > 0 { copy.addFilter(.blur(radius: blur)) }

        if let gradient {
            copy.stroke(
                path,
                with: .linearGradient(
                    gradient,
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: size, y: size)
                ),
                style: style
            )
        } else if let color {
            copy.stroke(path, with: .color(color), style: style)
        }
    }

    private func dotPath(r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: dotX - r, y: dotY - r,
            width: r * 2, height: r * 2
        ))
    }

}

// MARK: - Default init

extension CircleProgressView where Center == DefaultRingCenter {
    init(
        progress: Double,
        size: CGFloat = 220,
        strokeWidth: CGFloat = 1.5,
        accent: Color = AppColor.accentPrimary
    ) {
        self.init(progress: progress, size: size, strokeWidth: strokeWidth, accent: accent) {
            DefaultRingCenter(progress: progress, accent: accent)
        }
    }
}

// MARK: - DefaultRingCenter

struct DefaultRingCenter: View {
    let progress: Double
    var accent: Color = AppColor.accentPrimary

    var body: some View {
        VStack(spacing: 3) {
            HStack {
                Text("\(Int(progress * 100))")
                    .customFont(.displayThin)
                    .tracking(AppTracking.display)
                    .foregroundStyle(AppColor.textPrimary)
                
                Text("%")
                    .customFont(.heading2)
                    .foregroundStyle(accent.opacity(0.5))
            }
            Text("complete")
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textTertiary)
        }
    }
}

// MARK: - Clamped helper

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
