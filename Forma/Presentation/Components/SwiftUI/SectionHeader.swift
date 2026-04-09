import SwiftUI

struct SectionHeader: View {
    let title: String
    var count: Int?
    var actionTitle: String?
    var onAction: (() -> Void)?
    var textColor: Color

    init(
        title: String,
        count: Int? = nil,
        actionTitle: String? = nil,
        onAction: (() -> Void)? = nil,
        textColor: Color = AppColor.textTertiary
    ) {
        self.title = title
        self.count = count
        self.actionTitle = actionTitle
        self.onAction = onAction
        self.textColor = textColor
    }

    var body: some View {
        HStack {
            HStack(spacing: 6) {
                Text(title.uppercased())
                    .font(AppFont.ui(10, weight: .regular))
                    .tracking(2.5)
                    .foregroundStyle(textColor)

                if let count = count {
                    Text("\(count)")
                        .font(AppFont.ui(10, weight: .medium))
                        .foregroundStyle(textColor.opacity(0.6))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(textColor.opacity(0.1))
                        )
                }
            }

            Spacer()

            if let actionTitle = actionTitle, let onAction = onAction {
                Button(action: onAction) {
                    Text(actionTitle.uppercased())
                        .font(AppFont.ui(10, weight: .regular))
                        .tracking(1.8)
                        .foregroundStyle(AppColor.accentPrimary)
                }
            }
        }
    }
}

struct SectionTitle: View {
    let title: String
    var subtitle: String?
    var textColor: Color

    init(
        title: String,
        subtitle: String? = nil,
        textColor: Color = AppColor.textPrimary
    ) {
        self.title = title
        self.subtitle = subtitle
        self.textColor = textColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFont.display(24))
                .foregroundStyle(textColor)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFont.ui(14, weight: .regular))
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }
}
