//
//  RegionPickerSheet.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct RegionPickerSheet: View {
    let onDismiss: () -> Void
    
    @State private var selectedRegion: String = TimeZone.current.identifier
    
    private let commonRegions: [(id: String, name: String, offset: String)] = [
        ("America/New_York", "New York", "EST"),
        ("America/Chicago", "Chicago", "CST"),
        ("America/Denver", "Denver", "MST"),
        ("America/Los_Angeles", "Los Angeles", "PST"),
        ("Europe/London", "London", "GMT"),
        ("Europe/Paris", "Paris", "CET"),
        ("Europe/Moscow", "Moscow", "MSK"),
        ("Asia/Dubai", "Dubai", "GST"),
        ("Asia/Baku", "Baku", "AZT"),
        ("Asia/Tashkent", "Tashkent", "UZT"),
        ("Asia/Kolkata", "Mumbai", "IST"),
        ("Asia/Shanghai", "Shanghai", "CST"),
        ("Asia/Tokyo", "Tokyo", "JST"),
        ("Australia/Sydney", "Sydney", "AEST"),
        ("Pacific/Auckland", "Auckland", "NZST"),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(commonRegions, id: \.id) { region in
                            Button {
                                selectedRegion = region.id
                                applyRegion(region.id)
                                onDismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(region.name)
                                            .font(AppFont.ui(15, weight: .medium))
                                            .foregroundColor(AppColor.textPrimary)
                                        
                                        Text(region.offset)
                                            .font(AppFont.ui(11, weight: .regular))
                                            .foregroundColor(AppColor.textMuted)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedRegion == region.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColor.accent)
                                            .font(.system(size: 20))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                            }
                            .buttonStyle(.plain)
                            
                            if region.id != commonRegions.last?.id {
                                Rectangle()
                                    .fill(AppColor.border)
                                    .frame(height: 0.5)
                                    .padding(.leading, 54)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Region")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                    .foregroundColor(AppColor.textMuted)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func applyRegion(_ identifier: String) {
        guard let user = DependencyContainer.shared.currentUser,
              var prefs = user.preferences else { return }
        
        prefs.timezone = identifier
        
        let updatedUser = User(credentials: user.credentials, preferences: prefs)
        DependencyContainer.shared.updateUser(updatedUser)
        
        CoreDataManager.shared.saveUser(updatedUser)
        
        Task {
            try? await UserRepository().saveUser(updatedUser)
        }
    }
}
