//
//  SleepImpactSheet.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct SleepImpactSheet: View {
    @ObservedObject var viewModel: SleepScheduleEditViewModel
    var onRebuild: () -> Void
    var onManual: () -> Void

    private let gold = Color(hex: "#A259FF")
    private let textPrimary = Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black)
    private let textMuted = Color.adaptive(dark: Color(hex: "#4A4848"), light: Color(hex: "#666666"))
    private let border = Color.adaptive(dark: Color.white.opacity(0.06), light: Color.black.opacity(0.1))
    private let surface2 = Color.adaptive(dark: Color(hex: "#141414"), light: Color(hex: "#FFFFFF"))

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.1))
                .frame(width: 36, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 24)

            Text("Before you save")
                .font(.custom("Cormorant Garamond", size: 30))
                .fontWeight(.light)
                .foregroundColor(textPrimary)

            Text("Moving wake to \(viewModel.wakeFormatted) affects \(viewModel.affectedRoutines.count) routines")
                .font(.custom("Manrope", size: 12))
                .fontWeight(.light)
                .foregroundColor(textMuted)
                .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(viewModel.affectedRoutines) { routine in
                    AffectedRoutineRow(routine: routine)
                }
            }
            .padding(.top, 24)

            Spacer()

            Button(action: onRebuild) {
                HStack(spacing: 10) {
                    Text("✦")
                        .foregroundColor(gold)
                    Text("Rebuild with AI")
                        .font(.custom("Manrope", size: 13))
                        .fontWeight(.bold)
                        .kerning(1.2)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button(action: onManual) {
                Text("Edit manually")
                    .font(.custom("Manrope", size: 12))
                    .kerning(1)
                    .foregroundColor(textMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(border, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .background(Color.adaptive(dark: Color(hex: "#0C0C0C"), light: Color.white))
    }
}

struct AffectedRoutineRow: View {
    let routine: AffectedRoutine

    private let textPrimary = Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black)
    private let textMuted = Color.adaptive(dark: Color(hex: "#4A4848"), light: Color(hex: "#666666"))
    private let surface2 = Color.adaptive(dark: Color(hex: "#141414"), light: Color(hex: "#FFFFFF"))

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(surface2)
                    .frame(width: 34, height: 34)
                Text(routine.icon)
                    .font(.system(size: 16))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(routine.name)
                    .font(.custom("Manrope", size: 13))
                    .fontWeight(.semibold)
                    .foregroundColor(textPrimary)

                HStack(spacing: 4) {
                    Text(routine.before)
                        .font(.custom("Manrope", size: 11))
                        .foregroundColor(textMuted)
                        .strikethrough(routine.impact == .removed)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 8))
                        .foregroundColor(textMuted)

                    Text(routine.after)
                        .font(.custom("Manrope", size: 11))
                        .foregroundColor(routine.impact == .removed ? Color(hex: "#FF5050") : gold)
                }
            }

            Spacer()

            Text(routine.impact.label.uppercased())
                .font(.custom("Manrope", size: 9))
                .fontWeight(.semibold)
                .foregroundColor(routine.impact.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(routine.impact.background)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.adaptive(dark: Color(hex: "#0E0E0E"), light: Color(hex: "#F5F5F7")))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(border, lineWidth: 1)
                )
        )
    }

    private let gold = Color(hex: "#A259FF")
    private let border = Color.adaptive(dark: Color.white.opacity(0.06), light: Color.black.opacity(0.1))
}
