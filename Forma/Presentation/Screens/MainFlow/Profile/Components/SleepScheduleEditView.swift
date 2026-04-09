//
//  SleepScheduleEditView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct SleepScheduleEditView: View {
    @StateObject private var viewModel: SleepScheduleEditViewModel
    var onCancel: () -> Void
    var onSaved: (UserPreferences) -> Void

    @State private var wakeHour: Int
    @State private var wakeMinute: Int
    @State private var sleepHour: Int
    @State private var sleepMinute: Int

    private let gold = Color(hex: "#A259FF")
    private let blue = Color(hex: "#5B9CF6")
    private let textPrimary = Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black)
    private let textMuted = Color.adaptive(dark: Color(hex: "#4A4848"), light: Color(hex: "#666666"))
    private let border = Color.adaptive(dark: Color.white.opacity(0.06), light: Color.black.opacity(0.1))
    private let surface1 = Color.adaptive(dark: Color(hex: "#0E0E0E"), light: Color(hex: "#F5F5F7"))
    private let surface2 = Color.adaptive(dark: Color(hex: "#141414"), light: Color(hex: "#FFFFFF"))

    init(preferences: UserPreferences, onCancel: @escaping () -> Void, onSaved: @escaping (UserPreferences) -> Void) {
        let vm = SleepScheduleEditViewModel(preferences: preferences)
        _viewModel = StateObject(wrappedValue: vm)

        let cal = Calendar.current
        _wakeHour = State(initialValue: cal.component(.hour, from: preferences.wakeUpTime))
        _wakeMinute = State(initialValue: cal.component(.minute, from: preferences.wakeUpTime))
        _sleepHour = State(initialValue: cal.component(.hour, from: preferences.sleepTime))
        _sleepMinute = State(initialValue: cal.component(.minute, from: preferences.sleepTime))

        self.onCancel = onCancel
        self.onSaved = onSaved
    }

    var body: some View {
        ZStack {
            Color.adaptive(dark: Color(hex: "#060606"), light: Color.white).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSection

                    arcSummaryCard

                    wakePickerSection

                    sleepPickerSection

                    scopeSelector

                    if viewModel.hasChanges {
                        impactBanner
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }

            if viewModel.showRebuildOverlay {
                AIRebuildOverlay(currentStep: viewModel.rebuildStep)
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: onCancel) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textPrimary)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Sleep Schedule")
                    .font(.custom("Manrope", size: 15))
                    .fontWeight(.medium)
                    .foregroundColor(textPrimary)
            }
        }
        .sheet(isPresented: $viewModel.showImpactSheet) {
            SleepImpactSheet(
                viewModel: viewModel,
                onRebuild: {
                    viewModel.startAIRebuild { updatedPrefs in
                        onSaved(updatedPrefs)
                    }
                },
                onManual: {
                    viewModel.showImpactSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.adaptive(dark: Color(hex: "#0C0C0C"), light: Color.white))
        }
        .onChange(of: wakeHour) { _ in syncTimes() }
        .onChange(of: wakeMinute) { _ in syncTimes() }
        .onChange(of: sleepHour) { _ in syncTimes() }
        .onChange(of: sleepMinute) { _ in syncTimes() }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Adjust your wake & sleep times")
                .font(.custom("Cormorant Garamond", size: 14))
                .italic()
                .foregroundColor(textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var arcSummaryCard: some View {
        VStack(spacing: 12) {
            Text("Your sleep schedule")
                .font(.custom("Cormorant Garamond", size: 14))
                .italic()
                .foregroundColor(textMuted)

            SleepArcView(
                wakeFormatted: viewModel.wakeFormatted,
                sleepFormatted: viewModel.sleepFormatted,
                awakeDuration: viewModel.awakeDuration
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(border, lineWidth: 1)
                )
        )
    }

    private var wakePickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(gold)
                    .frame(width: 6, height: 6)

                Text("WAKE")
                    .font(.custom("Manrope", size: 10))
                    .tracking(2)
                    .foregroundColor(textMuted)

                Spacer()

                Text(viewModel.wakeFormatted)
                    .font(.custom("Cormorant Garamond", size: 18))
                    .fontWeight(.ultraLight)
                    .foregroundColor(gold)
            }

            SleepDrumPicker(
                hour: $wakeHour,
                minute: $wakeMinute,
                accentColor: gold
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(border, lineWidth: 1)
                )
        )
    }

    private var sleepPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(blue)
                    .frame(width: 6, height: 6)

                Text("SLEEP")
                    .font(.custom("Manrope", size: 10))
                    .tracking(2)
                    .foregroundColor(textMuted)

                Spacer()

                Text(viewModel.sleepFormatted)
                    .font(.custom("Cormorant Garamond", size: 18))
                    .fontWeight(.ultraLight)
                    .foregroundColor(blue)
            }

            SleepDrumPicker(
                hour: $sleepHour,
                minute: $sleepMinute,
                accentColor: blue
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(surface1)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(border, lineWidth: 1)
                )
        )
    }

    private var scopeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("APPLY THIS CHANGE TO")
                .font(.custom("Manrope", size: 10))
                .tracking(2.2)
                .foregroundColor(textMuted)

            HStack(spacing: 10) {
                ForEach(SleepScheduleEditViewModel.Scope.allCases, id: \.self) { scope in
                    scopeOption(scope)
                }
            }
        }
    }

    private func scopeOption(_ scope: SleepScheduleEditViewModel.Scope) -> some View {
        let isSelected = viewModel.selectedScope == scope

        return Button {
            withAnimation(.easeOut(duration: 0.2)) {
                viewModel.selectedScope = scope
            }
        } label: {
            VStack(spacing: 6) {
                Text(scope.icon)
                    .font(.system(size: 18))

                Text(scope.subtitle)
                    .font(.custom("Manrope", size: 10))
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? gold : textMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? gold.opacity(0.08) : surface2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? gold.opacity(0.3) : border, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var impactBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(gold)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(viewModel.affectedRoutines.count) routines will be affected")
                    .font(.custom("Manrope", size: 12))
                    .fontWeight(.medium)
                    .foregroundColor(textPrimary)

                Text(viewModel.affectedRoutines.map { $0.name }.joined(separator: ", "))
                    .font(.custom("Manrope", size: 10))
                    .foregroundColor(textMuted)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(gold.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(gold.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var saveButton: some View {
        Button(action: {
            viewModel.didTapSave()
        }) {
            Text("Save changes")
                .font(.custom("Manrope", size: 14))
                .fontWeight(.semibold)
                .tracking(1)
                .foregroundColor(viewModel.hasChanges ? .black : textMuted)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.hasChanges ? gold : surface2)
                )
        }
        .disabled(!viewModel.hasChanges)
    }

    private func syncTimes() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let newWake = calendar.date(bySettingHour: wakeHour, minute: wakeMinute, second: 0, of: today) {
            viewModel.wakeTime = newWake
        }

        if let newSleep = calendar.date(bySettingHour: sleepHour, minute: sleepMinute, second: 0, of: today) {
            viewModel.sleepTime = newSleep
        }
    }
}
