//
//  ShimmerOverlay.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct ShimmerOverlay: View {
    let isActive: Bool
    @State private var offset: CGFloat = -300

    var body: some View {
        GeometryReader { geo in
            if isActive {
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.04),
                        .white.opacity(0.07),
                        .white.opacity(0.04),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 160)
                .offset(x: offset)
                .onAppear {
                    withAnimation(
                        .linear(duration: 2.2)
                        .repeatForever(autoreverses: false)
                    ) {
                        offset = geo.size.width + 160
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
