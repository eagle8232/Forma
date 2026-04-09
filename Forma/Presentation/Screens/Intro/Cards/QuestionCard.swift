import SwiftUI

struct QuestionOption {
    let label: String
    var emoji: String? = nil
    let action: () -> Void
}

struct QuestionCard: View {
    let questionNumber: String
    let title: String
    let options: [QuestionOption]
    let isActive: Bool

    @State private var selectedIndex: Int? = nil

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {

                Text(questionNumber.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2.8)
                    .foregroundColor(.white.opacity(0.28))
                    .padding(.bottom, 16)

                Text(title)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .tracking(-0.6)
                    .lineSpacing(2)
                    .padding(.bottom, 36)

                VStack(spacing: 11) {
                    ForEach(options.indices, id: \.self) { i in
                        optionRow(at: i)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 38)
            .padding(.top, 120)
        }
        .opacity(isActive ? 1 : 0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }

    @ViewBuilder
    private func optionRow(at index: Int) -> some View {
        let option = options[index]
        let isSelected = selectedIndex == index

        ZStack {
            RoundedRectangle(cornerRadius: 13)
                .fill(isSelected ? Color.white.opacity(0.09) : Color.clear)
            RoundedRectangle(cornerRadius: 13)
                .stroke(
                    isSelected ? Color.white.opacity(0.42) : Color.white.opacity(0.12),
                    lineWidth: 1
                )
        }
        .frame(height: 50)
        .overlay(alignment: .leading) {
            HStack {
                Text(option.label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .tracking(-0.3)
                Spacer()
                if let emoji = option.emoji {
                    Text(emoji).font(.system(size: 16))
                }
            }
            .padding(.horizontal, 20)
        }
        .contentShape(Rectangle())
        .opacity(isActive ? 1 : 0)
        .offset(y: isActive ? 0 : 10)
        .animation(
            .spring(response: 0.45, dampingFraction: 0.8)
            .delay(0.16 + Double(index) * 0.08),
            value: isActive
        )
        .onTapGesture {
            selectedIndex = index
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                option.action()
                selectedIndex = nil
            }
        }
    }
}

#Preview {
    QuestionCard(
        questionNumber: "Question 1 of 3",
        title: "When do you usually wake up?",
        options: [
            QuestionOption(label: "Before 6AM", emoji: "🌅") {},
            QuestionOption(label: "6AM – 8AM") {},
            QuestionOption(label: "After 8AM") {}
        ],
        isActive: true
    )
    .preferredColorScheme(.dark)
}
