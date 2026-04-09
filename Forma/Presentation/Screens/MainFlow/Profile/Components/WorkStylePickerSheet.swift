//
//  WorkStylePickerSheet.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct WorkStylePickerSheet: View {
    let selectedStyle: String?
    let onSelect: (String) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(WorkStyle.allCases, id: \.self) { style in
                            Button {
                                onSelect(style.rawValue)
                            } label: {
                                HStack(spacing: 16) {
                                    Text(style.icon)
                                        .font(.system(size: 24))
                                    
                                    Text(style.rawValue)
                                        .font(AppFont.ui(16, weight: .medium))
                                        .foregroundColor(AppColor.textPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedStyle == style.rawValue {
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
                                            selectedStyle == style.rawValue ? AppColor.accent : AppColor.border,
                                            lineWidth: selectedStyle == style.rawValue ? 1.5 : 1
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
            .navigationTitle("Work Style")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(AppColor.textMuted)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
