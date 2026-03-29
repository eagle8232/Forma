//
//  AIMessageBubble.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/21/26.
//

import SwiftUI

struct AIMessageBubble: View {

    let message: AIMessage
    var accent: Color = AppColor.accentPrimary

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if message.role == .assistant {
                avatar
                bubble
                Spacer(minLength: 40)
            } else {
                Spacer(minLength: 40)
                bubble
                userAvatar
            }
        }
    }

    // MARK: - Bubbles

    private var bubble: some View {
        Group {
            if message.isStreaming && message.content.isEmpty {
                typingIndicator
            } else {
                Text(message.content)
                    .customFont(.bodySmall)
                    .foregroundStyle(
                        message.role == .assistant
                        ? AppColor.textPrimary.opacity(0.82)
                        : .white.opacity(0.88)
                    )
                    .lineSpacing(3)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(bubbleBackground)
            }
        }
    }

    private var bubbleBackground: some View {
        Group {
            if message.role == .assistant {
                RoundedRectangle(cornerRadius: 18)
                    .fill(AppColor.surfaceFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                    )
                    // Flatten bottom-left corner
                    .clipShape(
                        .rect(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 4,
                            bottomTrailingRadius: 18,
                            topTrailingRadius: 18
                        )
                    )
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(accent.opacity(0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(accent.opacity(0.28), lineWidth: AppSize.hairline)
                    )
                    .clipShape(
                        .rect(
                            topLeadingRadius: 18,
                            bottomLeadingRadius: 18,
                            bottomTrailingRadius: 4,
                            topTrailingRadius: 18
                        )
                    )
            }
        }
    }

    // MARK: - Typing indicator

    private var typingIndicator: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                TypingDot(delay: Double(i) * 0.18)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.surfaceFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                )
                .clipShape(
                    .rect(
                        topLeadingRadius: 18,
                        bottomLeadingRadius: 4,
                        bottomTrailingRadius: 18,
                        topTrailingRadius: 18
                    )
                )
        )
    }

    // MARK: - Avatars

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.12))
                .overlay(Circle().stroke(accent.opacity(0.25), lineWidth: AppSize.hairline))
                .frame(width: 28, height: 28)

            Image(systemName: "sparkles")
                .font(.system(size: 11, weight: .light))
                .foregroundStyle(accent.opacity(0.8))
        }
    }

    private var userAvatar: some View {
        ZStack {
            Circle()
                .fill(AppColor.surfaceFill)
                .overlay(Circle().stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline))
                .frame(width: 28, height: 28)

            Image(systemName: "person")
                .font(.system(size: 11, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.4))
        }
    }
}

// MARK: - TypingDot

private struct TypingDot: View {
    let delay: Double
    @State private var offset: CGFloat = 0

    var body: some View {
        Circle()
            .fill(.white.opacity(0.3))
            .frame(width: 4, height: 4)
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = -4
                }
            }
    }
}
