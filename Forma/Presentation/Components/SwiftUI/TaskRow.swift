//
//  TaskRow.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/15/26.
//

import SwiftUI

struct TaskRow: View {
    let task: RoutineTask
    let index: Int
    @ObservedObject var vm: RoutineDetailViewModel
    
    @State private var editTitle: String = ""
    @State private var editDescription: String = ""
    @State private var draftMinutes: Int = 0
    
    private var isExpanded: Bool { vm.expandedTaskID == task.id }
    private var accent: Color { vm.accent }
    
    private var durationLabel: String {
        formatMinutes(task.duration)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // ── Collapsed / Header row ──
            HStack(spacing: 0) {
                
                // Drag handle
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 10, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(isExpanded ? 0.0 : 0.12))
                    .frame(width: 36)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.white.opacity(isExpanded ? 0.5 : 0.85))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                    
                    HStack(spacing: 6) {
                        // Duration pill
                        Text(durationLabel)
                            .font(.system(size: 10, weight: .light))
                            .tracking(0.3)
                            .foregroundStyle(isExpanded ? accent.opacity(0.6) : .white.opacity(0.22))
                        
                        if !isExpanded {
                            Circle()
                                .fill(.white.opacity(0.1))
                                .frame(width: 2, height: 2)
                            
                            Text(vm.formatTime(task.startTime))
                                .font(.system(size: 10, weight: .light))
                                .tracking(0.3)
                                .foregroundStyle(.white.opacity(0.18))
                        }
                    }
                }
                
                Spacer()
                
                // Right — time + chevron
                HStack(spacing: 10) {
                    if isExpanded {
                        Text(vm.formatTime(task.startTime))
                            .font(.system(size: 10, weight: .ultraLight))
                            .tracking(1)
                            .foregroundStyle(accent.opacity(0.4))
                            .transition(.opacity)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .ultraLight))
                        .foregroundStyle(.white.opacity(isExpanded ? 0.35 : 0.16))
                }
                .padding(.trailing, 20)
            }
            .padding(.leading, 8)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
            .onTapGesture {
                if !isExpanded {
                    editTitle       = task.title
                    editDescription = task.description ?? ""
                    draftMinutes    = task.duration
                }
                vm.expand(task)
            }
            
            // ── Expanded panel ──
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Hairline top separator
                    Rectangle()
                        .fill(.white.opacity(0.05))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                    
                    // ── Title field ──
                    VStack(alignment: .leading, spacing: 6) {
                        Text("TITLE")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.18))
                        
                        TextField("Task title", text: $editTitle)
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(.white.opacity(0.88))
                            .tint(accent)
                            .onChange(of: editTitle) { _, newValue in
                                if newValue.count > 25 {
                                    editTitle = String(newValue.prefix(25))
                                }
                            }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Thin separator
                    Rectangle()
                        .fill(.white.opacity(0.04))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                    
                    // ── Duration stepper ──
                    VStack(alignment: .leading, spacing: 10) {
                        Text("DURATION")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.18))
                        
                        HStack(spacing: 0) {
                            
                            // Decrease button
                            DurationButton(icon: "minus", accent: accent) {
                                adjustDuration(by: -5)
                            } onLongPress: {
                                adjustDuration(by: -15)
                            }
                            
                            Spacer()
                            
                            // Center label
                            VStack(spacing: 3) {
                                Text(formatMinutes(draftMinutes))
                                    .font(.system(size: 22, weight: .ultraLight))
                                    .foregroundStyle(.white.opacity(0.88))
                                    .contentTransition(.numericText())
                                    .animation(.spring(response: 0.28, dampingFraction: 0.75), value: draftMinutes)
                                    .monospacedDigit()
                                
                                // Progress arc — shows proportion of routine window used
                                DurationArc(
                                    minutes: draftMinutes,
                                    totalMinutes: routineWindowMinutes,
                                    accent: accent
                                )
                                .frame(width: 60, height: 3)
                            }
                            
                            Spacer()
                            
                            // Increase button
                            DurationButton(icon: "plus", accent: accent) {
                                adjustDuration(by: 5)
                            } onLongPress: {
                                adjustDuration(by: 15)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    
                    // Thin separator
                    Rectangle()
                        .fill(.white.opacity(0.04))
                        .frame(height: 0.5)
                        .padding(.horizontal, 16)
                    
                    // ── Description field ──
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NOTES")
                            .font(.system(size: 8, weight: .regular))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.18))
                        
                        ZStack(alignment: .topLeading) {
                            if editDescription.isEmpty {
                                Text("Optional notes...")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundStyle(.white.opacity(0.15))
                                    .allowsHitTesting(false)
                            }
                            
                            ZStack(alignment: .bottomTrailing) {
                                TextEditor(text: $editDescription)
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .tint(accent)
                                    .frame(minHeight: 52, maxHeight: 100)
                                    .scrollContentBackground(.hidden)
                                    .background(.clear)
                                
                                Text("\(editTitle.count)/25")
                                    .font(.system(size: 9, weight: .light))
                                    .tracking(1)
                                    .foregroundStyle(
                                        editTitle.count == 25
                                        ? vm.accent.opacity(0.6)
                                        : .white.opacity(0.2)
                                    )
                                    .animation(.easeInOut(duration: 0.2), value: editTitle.count)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                    
                    // ── Action row ──
                    HStack(spacing: 0) {
                        Button {
                            vm.deleteTask(id: task.id)
                        } label: {
                            Text("Delete")
                                .font(.system(size: 11, weight: .light))
                                .tracking(0.5)
                                .foregroundStyle(.white.opacity(0.2))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                        
                        // Save — accent capsule
                        Button {
                            vm.updateTask(
                                id: task.id,
                                title: editTitle,
                                description: editDescription
                            )
                            // Duration is already committed live on each step tap
                        } label: {
                            Text("Save")
                                .font(.system(size: 12, weight: .regular))
                                .tracking(1)
                                .foregroundStyle(accent)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 9)
                                .background(
                                    Capsule()
                                        .fill(accent.opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(accent.opacity(0.2), lineWidth: 0.5)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: isExpanded)
    }
    
    // MARK: - Helpers
    
    private var routineWindowMinutes: Int {
        let start = DateManager.shared.convertToSeconds(vm.routine.startTime)
        let end   = DateManager.shared.convertToSeconds(vm.routine.endTime)
        return Int(max((end - start) / 60, 1))
    }
    
    private func adjustDuration(by delta: Int) {
        let next = max(5, min(draftMinutes + delta, 480))
        guard next != draftMinutes else { return }
        draftMinutes = next
        vm.updateTaskDuration(id: task.id, minutes: next)
    }
    
    private func formatMinutes(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        switch (h, m) {
        case (0, _): return "\(m)m"
        case (_, 0): return "\(h)h"
        default:     return "\(h)h \(m)m"
        }
    }
}

// MARK: - DurationButton

private struct DurationButton: View {
    let icon: String
    let accent: Color
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    @State private var pressing = false
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(.white.opacity(pressing ? 0.07 : 0.03))
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.07), lineWidth: 0.5)
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .ultraLight))
                    .foregroundStyle(accent.opacity(pressing ? 1.0 : 0.55))
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.35)
                .onChanged { _ in pressing = true }
                .onEnded { _ in
                    pressing = false
                    onLongPress()
                }
        )
        .animation(.easeInOut(duration: 0.15), value: pressing)
    }
}

private struct DurationArc: View {
    let minutes: Int
    let totalMinutes: Int
    let accent: Color
    
    private var fraction: CGFloat {
        guard totalMinutes > 0 else { return 0 }
        return min(CGFloat(minutes) / CGFloat(totalMinutes), 1.0)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.07))
                
                // Fill
                RoundedRectangle(cornerRadius: 2)
                    .fill(accent.opacity(fraction > 0.9 ? 0.8 : 0.45))
                    .frame(width: geo.size.width * fraction)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: fraction)
            }
        }
    }
}
