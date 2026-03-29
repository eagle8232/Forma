//
//  AIAssistanView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

struct AIAssistantView: View {

    @StateObject private var vm: AIAssistantViewModel
    @Environment(\.dismiss) private var dismiss

    init(routine: RoutineBlock? = nil, tasks: [RoutineTask] = []) {
        _vm = StateObject(wrappedValue: AIAssistantViewModel(
            routine: routine,
            tasks: tasks
        ))
    }

    private var accent: Color {
        guard let r = vm.routine else { return AppColor.accentPrimary }
        return Color(uiColor: UIColor(hex: r.accentColor))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            GrainOverlay().ignoresSafeArea().allowsHitTesting(false)
            ambientGlow.ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: 0) {
                navBar
                messageArea
                inputSection
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Nav Bar

extension AIAssistantView {

    private var navBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.45))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(AppColor.surfaceFill)
                            .overlay(Circle().stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline))
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text("FORMA AI")
                    .customFont(.microTracked)
                    .tracking(AppTracking.sectionLabel)
                    .foregroundStyle(AppColor.textPrimary)

                HStack(spacing: 4) {
                    Circle()
                        .fill(accent.opacity(0.8))
                        .frame(width: 4, height: 4)
                    Text("Beta")
                        .font(.system(size: 9, weight: .ultraLight))
                        .foregroundStyle(accent.opacity(0.6))
                }
            }

            Spacer()

            Button(action: { vm.clearConversation() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.3))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(AppColor.surfaceFill)
                            .overlay(Circle().stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline))
                    )
            }
            .buttonStyle(.plain)
            .opacity(vm.messages.isEmpty ? 0 : 1)
            .animation(AppAnimation.easeIn, value: vm.messages.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

// MARK: - Message Area

extension AIAssistantView {

    private var messageArea: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    if vm.messages.isEmpty {
                        emptyState
                            .padding(.top, 20)
                    }

                    if vm.showSuggestions {
                        suggestionChips
                            .padding(.top, vm.messages.isEmpty ? 28 : 16)
                    }

                    ForEach(vm.messages) { msg in
                        AIMessageBubble(message: msg, accent: accent)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .id(msg.id)
                    }

                    Spacer().frame(height: 16)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: vm.messages.count) { _, _ in
                if let last = vm.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: vm.messages.last?.content) { _, _ in
                if let last = vm.messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Empty State

extension AIAssistantView {

    private var emptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.1))
                    .overlay(Circle().stroke(accent.opacity(0.22), lineWidth: AppSize.hairline))
                    .frame(width: 56, height: 56)

                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .ultraLight))
                    .foregroundStyle(accent.opacity(0.75))
            }

            VStack(spacing: 6) {
                Text("How can I help today?")
                    .customFont(.heading2)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Ask me anything about your routines")
                    .customFont(.bodySmall)
                    .foregroundStyle(AppColor.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - Suggestion Chips

extension AIAssistantView {

    private var suggestionChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(vm.suggestions, id: \.self) { suggestion in
                    Button(action: { vm.sendSuggestion(suggestion) }) {
                        Text(suggestion)
                            .customFont(.microTracked)
                            .tracking(AppTracking.body)
                            .foregroundStyle(.white.opacity(0.45))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(AppColor.surfaceFill)
                                    .overlay(
                                        Capsule()
                                            .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Input Section

extension AIAssistantView {

    private var inputSection: some View {
        AIInputBar(
            text: $vm.inputText,
            isLoading: vm.isLoading,
            accent: accent,
            onSend: { vm.send() }
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 32)
    }
}

// MARK: - Ambient Glow

extension AIAssistantView {

    private var ambientGlow: some View {
        RadialGradient(
            colors: [accent.opacity(0.09), .clear],
            center: .init(x: 0.5, y: 0.1),
            startRadius: 0,
            endRadius: 300
        )
    }
}
