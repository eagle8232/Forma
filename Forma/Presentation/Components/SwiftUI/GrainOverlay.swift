//
//  GrainOverLay.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

// MARK: - GrainOverlay
// Deterministic noise rendered with SwiftUI Canvas — no UIKit, no image assets.
// Adds material depth to pure black backgrounds.
// Usage: GrainOverlay().ignoresSafeArea().allowsHitTesting(false)

struct GrainOverlay: View {
    var body: some View {
        Canvas { context, size in
            var rng = SeededRNG(seed: 137)
            let cols = Int(size.width)
            let rows = Int(size.height)
            let count = Int(CGFloat(cols * rows) * AppOpacity.grainDensity)

            for _ in 0..<count {
                let x = CGFloat(rng.next() % UInt64(cols))
                let y = CGFloat(rng.next() % UInt64(rows))
                let alpha = AppOpacity.grainAlphaMin
                          + (AppOpacity.grainAlphaMax - AppOpacity.grainAlphaMin)
                          * Double(rng.next() % 100) / 100.0

                context.fill(
                    Path(CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(.white.opacity(alpha))
                )
            }
        }
    }
}

// MARK: - SeededRNG
// xorshift64 — fast, deterministic, no imports.
// Same seed always produces the same grain pattern (no frame-to-frame flicker).

struct SeededRNG {
    var state: UInt64
    init(seed: UInt64) { state = seed == 0 ? 1 : seed }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

