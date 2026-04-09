import SwiftUI

struct RoutineCompletionSheet: View {
    let routines: [RoutineBlock]
    let onComplete: (String, [String: Bool]) -> Void
    let onDismiss: () -> Void
    
    @State private var currentIndex: Int = 0
    @State private var taskStates: [String: Bool] = [:]
    
    var currentRoutine: RoutineBlock? {
        guard currentIndex >= 0 && currentIndex < routines.count else { return nil }
        return routines[currentIndex]
    }
    
    var sortedTasks: [RoutineTask] {
        guard let routine = currentRoutine else { return [] }
        return routine.tasks
            .filter { !$0.isBreak }
            .sorted { t1, t2 in
                DateManager.shared.convertToSeconds(string: t1.startTime) < DateManager.shared.convertToSeconds(string: t2.startTime)
            }
    }
    
    var completedCount: Int {
        taskStates.values.filter { $0 }.count
    }
    
    var isLastRoutine: Bool {
        routines.isEmpty || currentIndex >= routines.count - 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ROUTINE \(currentIndex + 1) OF \(routines.count)")
                        .font(.system(size: 8, weight: .ultraLight))
                        .tracking(3)
                        .foregroundColor(Color.adaptiveWhiteOpacity(0.3, lightOpacity: 0.35))
                    
                    Text(currentRoutine?.title ?? "")
                        .font(AppFont.display(22))
                        .foregroundColor(AppColor.textPrimary)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.adaptiveWhiteOpacity(0.4, lightOpacity: 0.35))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 16)
            
            Text("Did you complete these tasks?")
                .font(AppFont.ui(13, weight: .regular))
                .foregroundColor(Color.adaptiveWhiteOpacity(0.5, lightOpacity: 0.45))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            
            // Task list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(sortedTasks) { task in
                        taskRow(task: task)
                        
                        if task.id != sortedTasks.last?.id {
                            Rectangle()
                                .fill(Color.adaptiveWhiteOpacity(0.04, lightOpacity: 0.08))
                                .frame(height: 0.5)
                                .padding(.leading, 60)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.adaptiveWhiteOpacity(0.02, lightOpacity: 0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.adaptiveWhiteOpacity(0.06, lightOpacity: 0.1), lineWidth: 0.5)
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 24)
            }
            
            // Progress indicator
            HStack {
                Text("\(completedCount)/\(sortedTasks.count) completed")
                    .font(AppFont.ui(11, weight: .medium))
                    .foregroundColor(AppColor.accentPrimary)
                
                Spacer()
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.adaptiveWhiteOpacity(0.08, lightOpacity: 0.12))
                            .frame(height: 3)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColor.accent)
                            .frame(width: progressWidth(total: geometry.size.width), height: 3)
                    }
                }
                .frame(width: 80, height: 3)
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 14)
            
            // Submit button
            Button(action: submit) {
                Text(isLastRoutine ? "Finish" : "Next Routine")
                    .font(AppFont.ui(14, weight: .medium))
                    .tracking(1)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(AppColor.accent)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
        .background(AppColor.background)
        .onAppear {
            resetTaskStates()
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
    }
    
    private func taskRow(task: RoutineTask) -> some View {
        Button(action: { toggleTask(task.id) }) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(
                        taskStates[task.id] == true ? AppColor.accentPrimary : Color.adaptiveWhiteOpacity(0.2, lightOpacity: 0.25),
                        lineWidth: 1.5
                    )
                    .frame(width: 22, height: 22)
                    .overlay {
                        if taskStates[task.id] == true {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(AppColor.accentPrimary)
                                .frame(width: 22, height: 22)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(AppFont.ui(14, weight: .medium))
                        .foregroundColor(taskStates[task.id] == true ? Color.adaptiveWhiteOpacity(0.4, lightOpacity: 0.35) : AppColor.textPrimary)
                        .strikethrough(taskStates[task.id] == true)
                        
                    Text(task.durationText)
                        .font(AppFont.ui(10, weight: .regular))
                        .foregroundColor(Color.adaptiveWhiteOpacity(0.3, lightOpacity: 0.35))
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleTask(_ id: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            taskStates[id] = !(taskStates[id] ?? false)
        }
    }
    
    private func progressWidth(total: CGFloat) -> CGFloat {
        let totalTasks = sortedTasks.count
        guard totalTasks > 0 else { return 0 }
        return total * CGFloat(completedCount) / CGFloat(totalTasks)
    }
    
    private func submit() {
        guard let routine = currentRoutine else {
            onDismiss()
            return
        }
        
        let routineId = routine.id
        let states = taskStates
        
        Task { @MainActor in
            onComplete(routineId, states)
        }
        
        if !isLastRoutine {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentIndex < routines.count - 1 {
                        currentIndex += 1
                        resetTaskStates()
                    }
                }
            }
        } else {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                onDismiss()
            }
        }
    }
    
    private func resetTaskStates() {
        taskStates = [:]
        for task in sortedTasks {
            taskStates[task.id] = false
        }
    }
}
