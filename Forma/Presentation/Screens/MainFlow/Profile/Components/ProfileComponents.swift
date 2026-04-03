//
//  ProfileComponents.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import SwiftUI

// MARK: - Section Header

struct FormaSectionHeader: View {
    let title: String
    var actionLabel: String? = nil
    var onAction: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(AppFont.ui(10, weight: .regular))
                .kerning(2.5)
                .foregroundColor(AppColor.textMuted)
            Spacer()
            if let label = actionLabel, let action = onAction {
                Button(action: action) {
                    Text(label)
                        .font(AppFont.ui(10, weight: .regular))
                        .kerning(1.8)
                        .foregroundColor(AppColor.textMuted)
                }
            }
        }
        .padding(.horizontal, AppSpacing.sectionGap)
        .padding(.bottom, AppSpacing.tightGap)
    }
}

// MARK: - Setting Card (Solid rounded rectangle)

enum SettingIconTint {
    case neutral, accent

    var background: Color {
        switch self {
        case .neutral: return AppColor.surface3
        case .accent:  return AppColor.accent.opacity(0.15)
        }
    }

    var iconColor: Color {
        switch self {
        case .neutral: return AppColor.textSecondary
        case .accent:  return AppColor.accent
        }
    }
}

enum SettingTrailing {
    case chevron
    case toggle(isOn: Binding<Bool>, onToggle: ((Bool) -> Void)?)
    case none
}

struct FormaSettingCard: View {
    let icon: String
    let iconTint: SettingIconTint
    let title: String
    let subtitle: String
    var badge: String? = nil
    var badgeStyle: FormaBadgeStyle? = nil
    var trailing: SettingTrailing = .chevron
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconTint.background)
                        .frame(width: 40, height: 40)
                    Text(icon)
                        .font(.system(size: 18))
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(AppFont.ui(15, weight: .medium))
                            .foregroundColor(AppColor.textPrimary)
                        if let badge = badge, let style = badgeStyle {
                            Text(badge)
                                .font(AppFont.ui(9, weight: .semibold))
                                .foregroundColor(badgeTextColor(for: style))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(badgeBgColor(for: style))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    Text(subtitle)
                        .font(AppFont.ui(12, weight: .regular))
                        .foregroundColor(AppColor.textMuted)
                }

                Spacer()

                trailingView
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColor.textMuted2)
        case .toggle(let isOn, let onToggle):
            ZStack {
                Capsule()
                    .fill(isOn.wrappedValue ? AppColor.accent : AppColor.surface3)
                    .frame(width: 44, height: 26)
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                    .offset(x: isOn.wrappedValue ? 9 : -9)
                    .animation(.spring(response: 0.25, dampingFraction: 0.75), value: isOn.wrappedValue)
            }
            .onTapGesture {
                let newVal = !isOn.wrappedValue
                isOn.wrappedValue = newVal
                onToggle?(newVal)
            }
        case .none:
            EmptyView()
        }
    }
}

private func badgeTextColor(for style: FormaBadgeStyle) -> Color {
    switch style {
    case .neutral: return AppColor.textMuted
    case .accent:  return AppColor.accent
    }
}

private func badgeBgColor(for style: FormaBadgeStyle) -> Color {
    switch style {
    case .neutral: return AppColor.surface3
    case .accent:  return AppColor.accent.opacity(0.15)
    }
}

// MARK: - Row Item

struct FormaRowItem: View {

    let icon: String
    let iconTint: FormaRowIconTint
    let title: String
    let subtitle: String
    var badge: FormaRowBadge? = nil
    var trailing: FormaRowTrailing = .chevron
    var action: (() -> Void)? = nil

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconTint.background)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(iconTint.border, lineWidth: 1)
                        )
                        .frame(width: 36, height: 36)
                    Text(icon)
                        .font(.system(size: 16))
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.ui(14, weight: .medium))
                        .foregroundColor(AppColor.textPrimary)
                    Text(subtitle)
                        .font(AppFont.ui(11, weight: .light))
                        .foregroundColor(AppColor.textMuted)
                }

                Spacer()

                // Trailing
                trailingView
            }
            .padding(.horizontal, AppSpacing.blockGap)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(FormaRowButtonStyle())
    }

    @ViewBuilder
    private var trailingView: some View {
        switch trailing {
        case .chevron:
            HStack(spacing: 6) {
                if let badge = badge {
                    FormaBadge(label: badge.label, style: badge.style)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .light))
                    .foregroundColor(AppColor.textMuted2)
            }
        case .toggle(let isOn, let onToggle):
            FormaToggle(isOn: isOn, onToggle: onToggle)
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Row Supporting Types

enum FormaRowIconTint {
    case neutral, gold, purple, green, red

    var background: Color {
        switch self {
        case .neutral: return AppColor.surface2
        case .gold:    return AppColor.gold.opacity(0.1)
        case .purple:  return AppColor.accentLow
        case .green:   return AppColor.greenLow
        case .red:     return Color.hex("#FF5050").opacity(0.1)
        }
    }

    var border: Color {
        switch self {
        case .neutral: return AppColor.border
        case .gold:    return AppColor.gold.opacity(0.22)
        case .purple:  return AppColor.accent.opacity(0.22)
        case .green:   return AppColor.green.opacity(0.22)
        case .red:     return Color.hex("#FF5050").opacity(0.22)
        }
    }
}

enum FormaRowTrailing {
    case chevron
    case toggle(isOn: Binding<Bool>, onToggle: ((Bool) -> Void)?)
    case none
}

struct FormaRowBadge {
    let label: String
    let style: FormaBadgeStyle
}

// MARK: - Badge

enum FormaBadgeStyle { case neutral, accent }

struct FormaBadge: View {
    let label: String
    let style: FormaBadgeStyle

    private var fg: Color {
        switch style {
        case .neutral: return AppColor.textMuted
        case .accent:  return AppColor.accent
        }
    }
    private var bg: Color {
        switch style {
        case .neutral: return AppColor.surface3
        case .accent:  return AppColor.accent.opacity(0.15)
        }
    }

    var body: some View {
        Text(label)
            .font(AppFont.ui(10, weight: .semibold))
            .foregroundColor(fg)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Toggle

struct FormaToggle: View {
    let isOn: Binding<Bool>
    var onToggle: ((Bool) -> Void)? = nil

    var body: some View {
        ZStack {
            Capsule()
                .fill(isOn.wrappedValue ? AppColor.accent : AppColor.surface3)
                .overlay(Capsule().stroke(AppColor.border, lineWidth: 1))
                .frame(width: 40, height: 24)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn.wrappedValue)

            Circle()
                .fill(Color.white)
                .frame(width: 18, height: 18)
                .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
                .offset(x: isOn.wrappedValue ? 8 : -8)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn.wrappedValue)
        }
        .onTapGesture {
            let newVal = !isOn.wrappedValue
            isOn.wrappedValue = newVal
            onToggle?(newVal)
        }
    }
}

// MARK: - Button Style

struct FormaRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed
                ? Color.white.opacity(0.02)
                : Color.clear)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Stat Card

struct FormaStatCard: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let delta: String?
    var deltaPositive: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(icon)
                .font(.system(size: 18))
                .padding(.bottom, 12)

            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(AppFont.display(34))
                    .foregroundColor(AppColor.textPrimary)
                if !unit.isEmpty {
                    Text(unit)
                        .font(AppFont.display(16))
                        .foregroundColor(AppColor.textMuted)
                }
            }

            Text(label.uppercased())
                .font(AppFont.ui(10, weight: .regular))
                .kerning(1.5)
                .foregroundColor(AppColor.textMuted)
                .padding(.top, 2)

            if let delta = delta {
                HStack(spacing: 3) {
                    Text(deltaPositive ? "↑" : "↓")
                    Text(delta)
                }
                .font(AppFont.ui(11, weight: .medium))
                .foregroundColor(deltaPositive ? AppColor.green : AppColor.destructive)
                .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.blockGap)
        .background(AppColor.surface1)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
}
