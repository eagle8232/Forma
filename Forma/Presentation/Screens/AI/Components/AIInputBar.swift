//
//  AIInputBar.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

struct AIInputBar: View {

    @Binding var text: String
    var isLoading: Bool = false
    var accent: Color = AppColor.accentPrimary
    var onSend: () -> Void

    @FocusState private var focused: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {

            // ── Text input ──
            TextField("Ask anything...", text: $text, axis: .vertical)
                .customFont(.bodySmall)
                .foregroundStyle(AppColor.textPrimary)
                .tint(accent)
                .lineLimit(1...5)
                .focused($focused)
                .submitLabel(.send)
                .onSubmit {
                    guard !isLoading else { return }
                    onSend()
                }
                .padding(.leading, 4)

            // ── Send button ──
            Button(action: {
                guard !isLoading else { return }
                onSend()
                focused = true
            }) {
                ZStack {
                    Circle()
                        .fill(text.trimmingCharacters(in: .whitespaces).isEmpty
                              ? AppColor.surfaceFill
                              : accent.opacity(0.8))
                        .frame(width: 36, height: 36)
                        .animation(AppAnimation.easeIn, value: text.isEmpty)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white.opacity(0.7))
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(
                                text.trimmingCharacters(in: .whitespaces).isEmpty
                                ? .white.opacity(0.2)
                                : .white
                            )
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(AppColor.surfaceFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            focused
                            ? accent.opacity(0.35)
                            : AppColor.surfaceBorder,
                            lineWidth: AppSize.hairline
                        )
                )
                .animation(AppAnimation.easeIn, value: focused)
        )
    }
}
