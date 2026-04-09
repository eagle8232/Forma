//
//  SleepDrumPicker.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct SleepDrumPicker: View {
    @Binding var hour: Int
    @Binding var minute: Int
    var accentColor: Color = Color(hex: "#A259FF")

    @State private var startHour: Int = 0
    @State private var startMinute: Int = 0
    @State private var isDragging: Bool = false

    private let hours = Array(0...23)
    private let minuteSteps = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]

    private let itemHeight: CGFloat = 44

    var body: some View {
        HStack(spacing: 8) {
            hourColumn
            Text(":")
                .font(AppFont.display(36))
                .foregroundColor(Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black).opacity(0.6))
            minuteColumn
        }
        .padding(.vertical, 8)
        .mask(
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.25),
                    .init(color: .black, location: 0.75),
                    .init(color: .clear, location: 1)
                ]),
                startPoint: .top, endPoint: .bottom
            )
        )
    }

    private var hourColumn: some View {
        GeometryReader { geo in
            let centerY = geo.size.height / 2

            ZStack {
                ForEach(Array(hours.enumerated()), id: \.element) { index, h in
                    let offset = CGFloat(index - hour) * itemHeight
                    let distance = abs(offset)
                    let opacity: Double = distance < itemHeight ? 1.0 : distance < itemHeight * 2 ? 0.4 : 0.15
                    let fontSize: CGFloat = distance < itemHeight ? 36 : distance < itemHeight * 2 ? 30 : 24

                    if distance < itemHeight * 3 {
                        Text(String(format: "%02d", h))
                            .font(AppFont.display(fontSize))
                            .foregroundColor(Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black).opacity(opacity))
                            .offset(y: centerY + offset - itemHeight / 2)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    hour = h
                                }
                            }
                    }
                }

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.04))
                    .frame(height: itemHeight)
                    .position(x: geo.size.width / 2, y: centerY)

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: geo.size.width - 16, height: 1)
                    .position(x: geo.size.width / 2, y: centerY - itemHeight / 2)

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: geo.size.width - 16, height: 1)
                    .position(x: geo.size.width / 2, y: centerY + itemHeight / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            startHour = hour
                        }
                        let delta = -value.translation.height
                        let steps = Int(delta / itemHeight)
                        var newHour = startHour + steps
                        while newHour < 0 { newHour += 24 }
                        while newHour >= 24 { newHour -= 24 }
                        hour = newHour
                    }
                    .onEnded { _ in
                        isDragging = false
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        }
                    }
            )
        }
        .frame(width: 80, height: itemHeight * 5)
    }

    private var minuteColumn: some View {
        GeometryReader { geo in
            let centerY = geo.size.height / 2
            let currentIndex = minuteSteps.firstIndex(of: minute) ?? 0

            ZStack {
                ForEach(Array(minuteSteps.enumerated()), id: \.element) { index, m in
                    let offset = CGFloat(index - currentIndex) * itemHeight
                    let distance = abs(offset)
                    let opacity: Double = distance < itemHeight ? 1.0 : distance < itemHeight * 2 ? 0.4 : 0.15
                    let fontSize: CGFloat = distance < itemHeight ? 36 : distance < itemHeight * 2 ? 30 : 24

                    if distance < itemHeight * 3 {
                        Text(String(format: "%02d", m))
                            .font(AppFont.display(fontSize))
                            .foregroundColor(Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black).opacity(opacity))
                            .offset(y: centerY + offset - itemHeight / 2)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    minute = m
                                }
                            }
                    }
                }

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.adaptive(dark: Color.white.opacity(0.04), light: Color.black.opacity(0.05)))
                    .frame(height: itemHeight)
                    .position(x: geo.size.width / 2, y: centerY)

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.adaptive(dark: Color.white.opacity(0.1), light: Color.black.opacity(0.1)))
                    .frame(width: geo.size.width - 16, height: 1)
                    .position(x: geo.size.width / 2, y: centerY - itemHeight / 2)

                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.adaptive(dark: Color.white.opacity(0.1), light: Color.black.opacity(0.1)))
                    .frame(width: geo.size.width - 16, height: 1)
                    .position(x: geo.size.width / 2, y: centerY + itemHeight / 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 4)
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            startMinute = minute
                        }
                        let delta = -value.translation.height
                        let steps = Int(delta / itemHeight)
                        let currentIdx = minuteSteps.firstIndex(of: startMinute) ?? 0
                        var newIdx = currentIdx + steps
                        while newIdx < 0 { newIdx += minuteSteps.count }
                        while newIdx >= minuteSteps.count { newIdx -= minuteSteps.count }
                        minute = minuteSteps[newIdx]
                    }
                    .onEnded { _ in
                        isDragging = false
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        }
                    }
            )
        }
        .frame(width: 80, height: itemHeight * 5)
    }
}
