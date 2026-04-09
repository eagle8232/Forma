//
//  AppearancePickerSheet.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct AppearancePickerSheet: View {
    @Binding var selectedMode: AppearanceMode
    var onSelect: ((AppearanceMode) -> Void)?
    var onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(AppearanceMode.allCases, id: \.self) { mode in
                            Button {
                                selectedMode = mode
                                onSelect?(mode)
                            } label: {
                                HStack(spacing: 16) {
                                    IconView(for: mode)
                                    
                                    Text(mode.rawValue)
                                        .font(AppFont.ui(16, weight: .medium))
                                        .foregroundColor(AppColor.textPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedMode == mode {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColor.accent)
                                            .font(.system(size: 22))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(AppColor.surface1)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            selectedMode == mode ? AppColor.accent : AppColor.border,
                                            lineWidth: selectedMode == mode ? 1.5 : 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        onDismiss()
                    }
                    .foregroundColor(AppColor.accent)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    private func IconView(for mode: AppearanceMode) -> some View {
        switch mode {
        case .system:
            Image(systemName: "iphone")
                .font(.system(size: 22))
                .foregroundColor(AppColor.textMuted)
        case .dark:
            Image(systemName: "moon.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColor.accent)
        case .light:
            Image(systemName: "sun.max.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.orange)
        }
    }
}
