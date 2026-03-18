//
//  RoutineRow.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct RoutineRow: View {
    let routine: RoutineBlock
    let index: Int

    @State private var appeared = false

    var body: some View {
        HStack(spacing: 16) {

            // Icon — no box, just the emoji floating
            Text(routine.icon)
                .font(.system(size: 22))
                .frame(width: 44, height: 44)
                .opacity(0.85)

            // Text block
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)

                Text("\(routine.startTime) – \(routine.endTime)")
                    .font(.system(size: 11, weight: .regular))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.28))
            }

            Spacer()

            // Arrow — barely there
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.15))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.55).delay(Double(index) * 0.09)) {
                appeared = true
            }
        }
    }
}
