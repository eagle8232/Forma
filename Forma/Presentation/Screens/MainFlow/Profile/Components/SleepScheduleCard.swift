//
//  SleepScheduleCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/5/26.
//

import SwiftUI

struct SleepScheduleCard: View {
    let wakeTime: Date
    let sleepTime: Date
    var onWakeTap: () -> Void
    var onSleepTap: () -> Void
    
    @State private var wakeHighlighted: Bool = false
    @State private var sleepHighlighted: Bool = false
    
    private let gold = Color(hex: "#A259FF")
    private let blue = Color(hex: "#5B9CF6")
    private let backgroundColor = Color.adaptive(dark: Color(hex: "#0E0E0E"), light: Color(hex: "#F5F5F7"))
    private let textPrimary = Color.adaptive(dark: Color(hex: "#F0ECE6"), light: Color.black)
    private let textMuted = Color.adaptive(dark: Color(hex: "#4A4848"), light: Color(hex: "#666666"))
    
    private var wakeTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: wakeTime)
    }
    
    private var sleepTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: sleepTime)
    }
    
    private var awakeDuration: (hours: Int, minutes: Int) {
        let wakeSeconds = wakeTime.timeIntervalSince1970
        var sleepSeconds = sleepTime.timeIntervalSince1970
        
        if sleepSeconds <= wakeSeconds {
            sleepSeconds += 86400
        }
        
        let duration = sleepSeconds - wakeSeconds
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        
        return (hours, minutes)
    }
    
    private var awakeDurationString: String {
        let h = awakeDuration.hours
        let m = awakeDuration.minutes
        if m == 0 {
            return "\(h)h"
        }
        return "\(h)h \(m)m"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                wakeHalf
                
                Rectangle()
                    .fill(Color.adaptiveWhiteOpacity(0.06, lightOpacity: 0.1))
                    .frame(width: 1)
                    .padding(.vertical, 16)
                
                sleepHalf
            }
            
            arcSection
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.adaptiveWhiteOpacity(0.06, lightOpacity: 0.12), lineWidth: 1)
                )
        )
    }
    
    private var wakeHalf: some View {
        Button {
            withAnimation(.easeOut(duration: 0.5)) {
                wakeHighlighted = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    wakeHighlighted = false
                }
            }
            onWakeTap()
        } label: {
            ZStack {
                if wakeHighlighted {
                    gold.opacity(0.04)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(gold)
                            .frame(width: 5, height: 5)
                            .shadow(color: gold, radius: 4)
                        
                        Text("WAKE")
                            .font(.system(size: 9, weight: .regular))
                            .tracking(0.28)
                            .foregroundColor(textMuted)
                    }
                    
                    Text(wakeTimeString)
                        .font(.system(size: 38, weight: .ultraLight, design: .serif))
                        .tracking(-0.03)
                        .foregroundColor(textPrimary)
                    
                    Text("Daily")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 20)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var sleepHalf: some View {
        Button {
            withAnimation(.easeOut(duration: 0.5)) {
                sleepHighlighted = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    sleepHighlighted = false
                }
            }
            onSleepTap()
        } label: {
            ZStack {
                if sleepHighlighted {
                    blue.opacity(0.04)
                }
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(blue)
                            .frame(width: 5, height: 5)
                            .shadow(color: blue, radius: 4)
                        
                        Text("SLEEP")
                            .font(.system(size: 9, weight: .regular))
                            .tracking(0.28)
                            .foregroundColor(textMuted)
                    }
                    
                    Text(sleepTimeString)
                        .font(.system(size: 38, weight: .ultraLight, design: .serif))
                        .tracking(-0.03)
                        .foregroundColor(textPrimary)
                    
                    Text("Daily")
                        .font(.system(size: 10, weight: .light))
                        .foregroundColor(textMuted)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.trailing, 20)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var arcSection: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                Text(awakeDurationString)
                    .font(.system(size: 22, weight: .light, design: .serif))
                    .foregroundColor(textPrimary)
                
                Text("AWAKE")
                    .font(.system(size: 9, weight: .regular))
                    .tracking(0.22)
                    .foregroundColor(textMuted)
            }
            .padding(.top, 4)
            
            ZStack {
                SleepArcShape()
                    .stroke(
                        Color.adaptive(dark: Color(hex: "#1C1C1C"), light: Color(hex: "#E5E5E5")),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                
                SleepArcShape()
                    .stroke(
                        LinearGradient(
                            colors: [gold, gold.opacity(0.4), blue.opacity(0.4), blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
            }
            .frame(height: 30)
            .padding(.horizontal, 20)
            
            HStack {
                Text(wakeTimeString)
                    .font(.system(size: 9, weight: .light))
                    .tracking(0.15)
                    .foregroundColor(textMuted)
                
                Spacer()
                
                Text(sleepTimeString)
                    .font(.system(size: 9, weight: .light))
                    .tracking(0.15)
                    .foregroundColor(textMuted)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

struct SleepArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let startX: CGFloat = 20
        let endX: CGFloat = rect.width - 20
        let bottomY: CGFloat = rect.height - 2
        let controlY: CGFloat = -rect.height * 0.6
        
        path.move(to: CGPoint(x: startX, y: bottomY))
        path.addQuadCurve(
            to: CGPoint(x: endX, y: bottomY),
            control: CGPoint(x: rect.midX, y: controlY)
        )
        
        return path
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
