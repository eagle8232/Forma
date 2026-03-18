//
//  AnimatedTopGradient.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/13/26.
//

import SwiftUI

// MARK: - Generation Phase

enum GenerationPhase: Equatable {
    case thinking
    case firstArrived
    case streaming(count: Int)
    case done
}

// MARK: - AI Generation Progress View

struct AIGenerationProgressView: View {
    var phase: GenerationPhase = .thinking

    private var tempo: Double {
        switch phase {
        case .thinking:     return 0.45
        case .firstArrived: return 1.2
        case .streaming:    return 0.75
        case .done:         return 0.28
        }
    }

    private var intensity: Double {
        switch phase {
        case .thinking:     return 0.5
        case .firstArrived: return 1.0
        case .streaming:    return 0.72
        case .done:         return 0.32
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.10)
                .ignoresSafeArea()

            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                FluidCanvas(t: t * tempo, intensity: intensity)
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 2.5), value: tempo)

            if phase == .firstArrived {
                RippleView()
                    .transition(.opacity)
            }
        }
    }
}

// MARK: - Fluid Cxnvas

struct FluidCanvas: View {
    let t: Double
    let intensity: Double

    var body: some View {
        Canvas { ctx, size in
            // Dark base
            ctx.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .color(Color(red: 0.04, green: 0.05, blue: 0.10))
            )

            let w = size.width
            let h = size.height

            // --- Light source 1: large, slow, deep blue ---
            drawLight(
                ctx: ctx,
                x: w * (0.5 + sin(t * 0.38) * 0.28 + sin(t * 0.91) * 0.08),
                y: h * (0.4 + cos(t * 0.29 + 1.1) * 0.22 + cos(t * 0.73) * 0.06),
                radiusX: w * (0.55 + sin(t * 0.61) * 0.08),
                radiusY: h * (0.48 + cos(t * 0.51) * 0.09),
                color: Color(red: 0.08, green: 0.16, blue: 0.62),
                opacity: 0.38 * intensity,
                blur: 90
            )

            // --- Light source 2: medium, drifts opposite ---
            drawLight(
                ctx: ctx,
                x: w * (0.5 + cos(t * 0.44 + 2.3) * 0.22 + cos(t * 1.05) * 0.06),
                y: h * (0.55 + sin(t * 0.37 + 3.3) * 0.20 + sin(t * 0.82) * 0.05),
                radiusX: w * (0.40 + cos(t * 0.72) * 0.07),
                radiusY: h * (0.38 + sin(t * 0.59) * 0.08),
                color: Color(red: 0.05, green: 0.11, blue: 0.48),
                opacity: 0.32 * intensity,
                blur: 75
            )

            // --- Light source 3: accent, brighter blue ---
            drawLight(
                ctx: ctx,
                x: w * (0.5 + sin(t * 0.51 + 4.8) * 0.30 + sin(t * 1.2) * 0.05),
                y: h * (0.45 + cos(t * 0.46 + 1.2) * 0.25 + cos(t * 0.95) * 0.05),
                radiusX: w * (0.32 + sin(t * 0.83) * 0.06),
                radiusY: h * (0.30 + cos(t * 0.94) * 0.07),
                color: Color(red: 0.14, green: 0.26, blue: 0.75),
                opacity: 0.28 * intensity,
                blur: 85
            )

            // --- Light source 4: small, quick shimmer ---
            drawLight(
                ctx: ctx,
                x: w * (0.5 + sin(t * 0.72 + 2.7) * 0.18 + sin(t * 1.55) * 0.04),
                y: h * (0.5 + cos(t * 0.65 + 1.9) * 0.16 + cos(t * 1.38) * 0.04),
                radiusX: w * (0.22 + sin(t * 1.1) * 0.05),
                radiusY: h * (0.20 + cos(t * 1.25) * 0.05),
                color: Color(red: 0.20, green: 0.38, blue: 0.88),
                opacity: 0.22 * intensity,
                blur: 65
            )

            // --- Top vignette — pulls light away from edges ---
            drawVignette(ctx: ctx, size: size)
        }
    }

    private func drawLight(
        ctx: GraphicsContext,
        x: Double,
        y: Double,
        radiusX: Double,
        radiusY: Double,
        color: Color,
        opacity: Double,
        blur: Double
    ) {
        var c = ctx
        c.addFilter(.blur(radius: blur))

        let rect = CGRect(
            x: x - radiusX,
            y: y - radiusY,
            width: radiusX * 2,
            height: radiusY * 2
        )

        c.fill(
            Path(ellipseIn: rect),
            with: .color(color.opacity(opacity))
        )
    }

    private func drawVignette(ctx: GraphicsContext, size: CGSize) {
        // Four corner fades to push light toward center
        let corners: [(CGFloat, CGFloat)] = [(0,0),(1,0),(0,1),(1,1)]
        for (cx, cy) in corners {
            var c = ctx
            c.addFilter(.blur(radius: 80))
            let rect = CGRect(
                x: cx == 0 ? -60 : size.width - 60,
                y: cy == 0 ? -60 : size.height - 60,
                width: 180,
                height: 180
            )
            c.fill(
                Path(ellipseIn: rect),
                with: .color(Color(red: 0.02, green: 0.03, blue: 0.07).opacity(0.9))
            )
        }
    }
}

// MARK: - Ripple View

struct RippleView: View {
    @State private var scale: CGFloat = 0.85
    @State private var opacity: Double = 0.28

    var body: some View {
        Circle()
            .stroke(Color.white.opacity(opacity), lineWidth: 0.5)
            .frame(width: 180, height: 180)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 2.8)) {
                    scale = 2.2
                    opacity = 0
                }
            }
    }
}
