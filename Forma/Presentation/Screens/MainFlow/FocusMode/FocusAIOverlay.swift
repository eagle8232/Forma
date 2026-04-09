import SwiftUI

struct FocusAIOverlay: View {

    let taskTitle: String
    var onClose: () -> Void

    @State private var messages: [ChatMessage] = [
        ChatMessage(
            text: "You're deep into your session. What do you need?",
            role: .ai
        )
    ]
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    @State private var isRecording: Bool = false
    @FocusState private var inputFocused: Bool
    @State private var aiResponseIndex: Int = 0

    private let aiResponses = [
        "Start with the most critical logic — aesthetic issues can wait.",
        "If a section is unclear, try explaining it in one sentence first.",
        "Deep review quality peaks around 45 minutes. You have time.",
        "Look for the 'why' behind decisions, not just the 'what'.",
        "You need to catch the important things — not everything.",
        "Smaller PRs are better PRs. It's okay to say so.",
        "You're doing good work. Keep going.",
    ]

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .background(Color(hex: "#020204").opacity(0.94))
                .ignoresSafeArea()

            PrismaticEdges()

            VStack(spacing: 0) {
                headerView
                    .padding(.horizontal, 24)
                    .padding(.top, 52)
                    .padding(.bottom, 16)

                messagesView

                inputView
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
            }
        }
        .ignoresSafeArea()
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color(hex: "#A259FF"))
                    .frame(width: 9, height: 9)
                    .shadow(color: Color(hex: "#A259FF").opacity(0.9), radius: 8)
                    .shadow(color: Color(hex: "#A259FF").opacity(0.4), radius: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Forma AI")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(FormaTheme.Palette.textPrimary)
                    Text("Ask anything about your task")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(FormaTheme.Palette.textMuted)
                }
            }

            Spacer()

            Button(action: onClose) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.06))
                        .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
                        .frame(width: 32, height: 32)
                    Text("✕")
                        .font(.system(size: 14))
                        .foregroundColor(FormaTheme.Palette.textMuted)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { msg in
                        ChatBubble(message: msg)
                            .id(msg.id)
                    }
                    if isTyping {
                        TypingIndicator()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .id("typing")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .onChange(of: messages.count) { _ in
                withAnimation { proxy.scrollTo(messages.last?.id, anchor: .bottom) }
            }
            .onChange(of: isTyping) { _ in
                withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
            }
        }
    }

    private var inputView: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Ask Forma AI…", text: $inputText, axis: .vertical)
                .font(.system(size: 15))
                .foregroundColor(FormaTheme.Palette.textPrimary)
                .lineLimit(1...5)
                .focused($inputFocused)
                .onSubmit { if !inputText.isEmpty { sendMessage() } }

            HStack(spacing: 6) {
                Button(action: toggleVoice) {
                    ZStack {
                        Circle()
                            .fill(isRecording
                                  ? Color.red.opacity(0.2)
                                  : Color.white.opacity(0.06))
                            .overlay(
                                Circle().stroke(
                                    isRecording
                                        ? Color.red.opacity(0.5)
                                        : Color.white.opacity(0.09),
                                    lineWidth: 1
                                )
                            )
                            .frame(width: 36, height: 36)
                        Text(isRecording ? "⏹" : "🎙")
                            .font(.system(size: 16))
                    }
                }
                .buttonStyle(.plain)

                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#A259FF"))
                            .frame(width: 36, height: 36)
                            .shadow(color: Color(hex: "#A259FF").opacity(0.4), radius: 8)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(inputText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.3 : 1)
                .animation(.easeOut(duration: 0.15), value: inputText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )
        )
    }

    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messages.append(ChatMessage(text: text, role: .user))
        inputText = ""
        isTyping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1 + Double.random(in: 0...0.7)) {
            isTyping = false
            let response = aiResponses[aiResponseIndex % aiResponses.count]
            aiResponseIndex += 1
            messages.append(ChatMessage(text: response, role: .ai))
        }
    }

    private func toggleVoice() {
        isRecording.toggle()
    }
}

// MARK: - Supporting Types

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let role: Role

    enum Role { case user, ai }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 60) }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 3) {
                Text(message.text)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(message.role == .user ? .white : FormaTheme.Palette.textPrimary)
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(
                        message.role == .user
                            ? AnyShapeStyle(Color(hex: "#A259FF"))
                            : AnyShapeStyle(.ultraThinMaterial)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(
                        color: message.role == .user
                            ? Color(hex: "#A259FF").opacity(0.35)
                            : .clear,
                        radius: 8, y: 2
                    )

                Text("Now")
                    .font(.system(size: 10))
                    .foregroundColor(FormaTheme.Palette.textMuted)
                    .padding(.horizontal, 4)
            }

            if message.role == .ai { Spacer(minLength: 60) }
        }
        .transition(.opacity.combined(with: .offset(y: 8)))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: message.id)
    }
}

struct TypingIndicator: View {
    @State private var phase: Int = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "#48484A"))
                    .frame(width: 6, height: 6)
                    .scaleEffect(phase == i ? 1.3 : 1.0)
                    .opacity(phase == i ? 1.0 : 0.4)
                    .animation(.easeInOut(duration: 0.3), value: phase)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }
}

// MARK: - PrismaticEdges

struct PrismaticEdges: View {
    var body: some View {
        ZStack {
            leftEdge
            rightEdge
            topEdge
            bottomEdge
            cornerBlooms
        }
        .ignoresSafeArea()
    }

    private var leftEdge: some View {
        LinearGradient(
            colors: [.clear,
                     Color(red: 0.71, green: 0, blue: 0.47).opacity(0.65),
                     Color(red: 0.31, green: 0.12, blue: 1.0).opacity(0.50),
                     Color(red: 0, green: 0.39, blue: 1.0).opacity(0.40),
                     Color(red: 0, green: 0.75, blue: 0.67).opacity(0.45),
                     .clear],
            startPoint: .top, endPoint: .bottom
        )
        .frame(width: 100)
        .blur(radius: 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .allowsHitTesting(false)
    }

    private var rightEdge: some View {
        LinearGradient(
            colors: [.clear,
                     Color(red: 1.0, green: 0.24, blue: 0).opacity(0.55),
                     Color(red: 0.86, green: 0, blue: 0.31).opacity(0.45),
                     Color(red: 1.0, green: 0.39, blue: 0).opacity(0.50),
                     Color(red: 1.0, green: 0.78, blue: 0).opacity(0.50),
                     .clear],
            startPoint: .top, endPoint: .bottom
        )
        .frame(width: 90)
        .blur(radius: 26)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .allowsHitTesting(false)
    }

    private var topEdge: some View {
        LinearGradient(
            colors: [
                Color(red: 0.86, green: 0, blue: 0.47).opacity(0.40),
                Color(red: 0.71, green: 0.16, blue: 0.87).opacity(0.50),
                Color(red: 0.31, green: 0.12, blue: 1.0).opacity(0.42),
                Color(red: 0, green: 0.55, blue: 1.0).opacity(0.38),
                Color(red: 0.86, green: 0, blue: 0.47).opacity(0.40),
            ],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(height: 70)
        .blur(radius: 22)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
    }

    private var bottomEdge: some View {
        LinearGradient(
            colors: [
                Color(red: 0, green: 0.75, blue: 0.75).opacity(0.38),
                Color(red: 1.0, green: 0.47, blue: 0).opacity(0.50),
                Color(red: 1.0, green: 0, blue: 0.31).opacity(0.44),
                Color(red: 1.0, green: 0.75, blue: 0).opacity(0.50),
                Color(red: 0, green: 0.75, blue: 0.75).opacity(0.38),
            ],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(height: 80)
        .blur(radius: 26)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .allowsHitTesting(false)
    }

    private var cornerBlooms: some View {
        ZStack {
            RadialGradient(colors: [Color(red: 0.78, green: 0.16, blue: 0.86).opacity(0.50), .clear], center: .topLeading, startRadius: 0, endRadius: 140)
                .frame(width: 140, height: 140)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            RadialGradient(colors: [Color(red: 1.0, green: 0.78, blue: 0).opacity(0.42), .clear], center: .topTrailing, startRadius: 0, endRadius: 130)
                .frame(width: 130, height: 130)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            RadialGradient(colors: [Color(red: 0, green: 0.71, blue: 0.78).opacity(0.42), .clear], center: .bottomLeading, startRadius: 0, endRadius: 120)
                .frame(width: 120, height: 120)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            RadialGradient(colors: [Color(red: 1.0, green: 0.39, blue: 0).opacity(0.42), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 160)
                .frame(width: 160, height: 160)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    FocusAIOverlay(
        taskTitle: "Code Review",
        onClose: {}
    )
}
