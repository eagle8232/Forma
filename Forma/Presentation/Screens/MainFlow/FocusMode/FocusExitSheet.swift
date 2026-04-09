//
//  FocusExitSheet.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/6/26.
//

import SwiftUI

struct FocusExitSheet: View {
    let task: RoutineTask
    let elapsedMinutes: Int
    var onSave: (RoutineTask) -> Void
    var onStayIn: () -> Void
    
    private var elapsedMinutesString: String {
        "\(elapsedMinutes)"
    }

    private let textPrimary = Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black)
    private let textMuted = Color.adaptive(dark: Color(hex: "#4A4848"), light: Color(hex: "#666666"))
    private let border = Color.adaptive(dark: Color.white.opacity(0.06), light: Color.black.opacity(0.1))
    private let surface1 = Color.adaptive(dark: Color(hex: "#0E0E0E"), light: Color(hex: "#F5F5F7"))
    private let gold = Color(hex: "#A259FF")
    private let green = Color(hex: "#4CD97B")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.white.opacity(0.09))
                .frame(width: 34, height: 3.5)
                .frame(maxWidth: .infinity)
                .padding(.top, 13)
                .padding(.bottom, 26)

            // Title
            Text("How did it go?")
                .font(AppFont.display(28))
                .foregroundColor(textPrimary)
                .padding(.bottom, 5)

            // Subtitle
            HStack(spacing: 0) {
                Text("You've been focused for ")
                    .foregroundColor(textMuted)
                Text("\(elapsedMinutesString) minutes")
                    .foregroundColor(textPrimary)
                Text(". Forma AI will log this.")
                    .foregroundColor(textMuted)
            }
            .font(AppFont.ui(12, weight: .regular))
            .lineSpacing(3)
            .padding(.bottom, 24)

            // Session stats
            HStack(spacing: 1) {
                snapCell(value: elapsedMinutesString, label: "Minutes", valueColor: textPrimary)
                snapCell(value: "94%", label: "On task", valueColor: green)
                snapCell(value: "3", label: "In a row", valueColor: textPrimary)
            }
            .background(border)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.bottom, 24)

            // Actions
            VStack(spacing: 9) {
                Button(action: { onSave(task) }) {
                    Text("Mark as Done ✓")
                        .font(AppFont.ui(12, weight: .bold))
                        .kerning(1.2)
                        .textCase(.uppercase)
                        .foregroundColor(Color.adaptive(dark: Color(hex: "#060606"), light: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .buttonStyle(.plain)

                Button(action: onStayIn) {
                    Text("Stay in focus")
                        .font(AppFont.ui(10, weight: .regular))
                        .kerning(1.2)
                        .textCase(.uppercase)
                        .foregroundColor(Color(hex: "#282828"))
                        .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private func snapCell(value: String, label: String, valueColor: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(AppFont.display(26))
                .foregroundColor(valueColor)
            Text(label)
                .font(AppFont.ui(9, weight: .regular))
                .kerning(2)
                .textCase(.uppercase)
                .foregroundColor(textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(surface1)
    }
}

#Preview {
    FocusExitSheet(
        task: RoutineTask(id: "1", title: "Test Task", startTime: "09:00", duration: 45, description: nil, state: .inProgress, isBreak: false),
        elapsedMinutes: 32,
        onSave: { _ in },
        onStayIn: {}
    )
    .background(Color.adaptive(dark: Color(hex: "#0B0B0B"), light: Color.white))
}
