//
//  FocusAIDrawer.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/6/26.
//

import SwiftUI

struct FocusAIDrawer: View {
    @Binding var isExpanded: Bool
    let task: RoutineTask
    var onAddTime: () -> Void

    private let gold = Color(hex: "#A259FF")
    private let surface1 = Color.adaptive(dark: Color(hex: "#0E0E0E"), light: Color(hex: "#F5F5F7"))
    private let border = Color.adaptive(dark: Color.white.opacity(0.06), light: Color.black.opacity(0.1))
    private let textPrimary = Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black)
    private let textMuted = Color.adaptive(dark: Color(hex: "#4A4848"), light: Color(hex: "#666666"))

    var body: some View {
        VStack(spacing: 0) {
            // Handle zone
            VStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.09))
                    .frame(width: 34, height: 3.5)

                HStack(spacing: 7) {
                    Circle()
                        .fill(gold)
                        .frame(width: 4, height: 4)
                        .shadow(color: gold.opacity(0.6), radius: 4)
                    Text("Forma AI · tap for help")
                        .font(AppFont.ui(9, weight: .regular))
                        .kerning(2.4)
                        .textCase(.uppercase)
                        .foregroundColor(textMuted)
                    Circle()
                        .fill(gold)
                        .frame(width: 4, height: 4)
                        .shadow(color: gold.opacity(0.6), radius: 4)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.clear, Color.adaptive(dark: Color(hex: "#0D0D0D"), light: Color.white)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }

            // Drawer content
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .background(Color.adaptive(dark: Color(hex: "#0D0D0D"), light: Color.white))
        .animation(.spring(response: 0.45, dampingFraction: 0.8), value: isExpanded)
    }

    @ViewBuilder
    private var expandedContent: some View {
        VStack(spacing: 12) {
            // AI insight card
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(gold)
                        .frame(width: 5, height: 5)
                        .shadow(color: gold, radius: 4)
                    Text("Forma AI · insight")
                        .font(AppFont.ui(9, weight: .regular))
                        .kerning(2.8)
                        .textCase(.uppercase)
                        .foregroundColor(gold)
                }
                Text("You're 32 minutes in — your deepest \(task.title.lowercased()) work happens in the first 45. Stay with it.")
                    .font(AppFont.displayItalic(14.5))
                    .foregroundColor(textPrimary.opacity(0.72))
                    .lineSpacing(3)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(gold.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(gold.opacity(0.15), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Quick actions grid
            HStack(spacing: 7) {
                actionButton(icon: "⏱", label: "+15 min", action: onAddTime)
                actionButton(icon: "📝", label: "Add note", action: {})
                actionButton(icon: "✅", label: "Subtask", action: {})
                actionButton(icon: "🔁", label: "Reschedule", action: {})
            }

            // Stuck button
            Button {
                // TODO: open AI unblock dialogue
            } label: {
                HStack(spacing: 8) {
                    Text("✦")
                    Text("I'm stuck — help me unblock")
                        .font(AppFont.ui(11.5, weight: .regular))
                        .kerning(0.8)
                        .textCase(.uppercase)
                }
                .foregroundColor(gold.opacity(0.55))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(gold.opacity(0.18), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 20)
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Text(icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(AppFont.ui(9.5, weight: .regular))
                    .foregroundColor(textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(surface1)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 11))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FocusAIDrawer(
        isExpanded: .constant(true),
        task: RoutineTask(
            id: "1",
            title: "Write code review",
            startTime: "09:00",
            duration: 45,
            description: nil,
            state: .inProgress,
            isBreak: false
        ),
        onAddTime: {}
    )
    .background(Color.adaptive(dark: Color(hex: "#0D0D0D"), light: Color.white))
}
