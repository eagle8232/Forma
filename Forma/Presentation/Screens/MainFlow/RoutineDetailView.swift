//
//  RoutineDetailView.swift
//  Forma
//

import SwiftUI

struct RoutineDetailView: View {
    @StateObject private var vm: RoutineDetailViewModel
    var onSave: ((RoutineBlock) -> Void)?
    
    init(routine: RoutineBlock, onSave: ((RoutineBlock) -> Void)? = nil) {
        _vm = StateObject(wrappedValue: RoutineDetailViewModel(routine: routine))
        self.onSave = onSave
    }
    
    var body: some View {
        ZStack {
            AIGenerationProgressView(phase: .thinking)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    heroSection
                    timelineSection
                    mismatchBanner
                    taskSection
                    addButton
                        .padding(.top, 16)
                        .padding(.bottom, 48)
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .keyboardAdaptive()
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                saveButton
            }
        })
        .alert("Changes saved", isPresented: $vm.showSuccessAlert) {
            Button("OK", role: .cancel) { vm.detectChanges() }
        } message: {
            Text("Your routine has been saved successfully.")
        }
        // Error alert
        .alert("Saving not possible", isPresented: $vm.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.validationErrorMessage)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { vm.triggerAppear() }
    }
}

// MARK: - Hero

extension RoutineDetailView {
    
    private var heroSection: some View {
        VStack(spacing: 0) {
            Text(vm.routine.icon)
                .font(.system(size: 60))
                .padding(.top, 28)
                .padding(.bottom, 18)
                .opacity(vm.appeared ? 1 : 0)
                .scaleEffect(vm.appeared ? 1 : 0.85)
                .animation(.spring(response: 0.55, dampingFraction: 0.75), value: vm.appeared)
            
            // Editable title
            ZStack {
                // Invisible sizing ghost — keeps layout stable while typing
                Text(vm.routine.title.isEmpty ? " " : vm.routine.title)
                    .customFont(.displaySmall)
                    .tracking(-0.3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(0)
                
                TextField("Routine title", text: $vm.routine.title, axis: .vertical)
                    .customFont(.displayMedium)
                    .foregroundStyle(.white.opacity(0.92))
                    .tracking(-0.3)
                    .multilineTextAlignment(.center)
                    .tint(vm.accent)
                    .padding(.horizontal, 32)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(vm.accent.opacity(vm.isTitleFocused ? 0.5 : 0.0))
                            .frame(height: 0.5)
                            .padding(.horizontal, 32)
                            .animation(.easeInOut(duration: 0.2), value: vm.isTitleFocused)
                    }
                    .onChange(of: vm.routine.title) { _, newValue in
                        if newValue.count > 25 {
                            vm.routine.title = String(newValue.prefix(25))
                        }
                        vm.detectChanges()
                    }
            }
            .opacity(vm.appeared ? 1 : 0)
            .offset(y: vm.appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.08), value: vm.appeared)
            
            HStack(alignment: .center, spacing: 0) {
                VStack(spacing: 5) {
                    Text("START")
                        .font(.system(size: 9, weight: .regular))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.2))
                    Text(vm.formatTime(vm.routine.startTime))
                        .customFont(.heading2)
                        .fontWeight(.regular)
                        .foregroundStyle(vm.accent.opacity(0.9))
                        .tracking(2)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(.white.opacity(i == 0 ? 0.15 : 0.06))
                            .frame(width: i == 0 ? 3 : 2, height: i == 0 ? 3 : 2)
                    }
                }
                
                VStack(spacing: 5) {
                    Text("END")
                        .font(.system(size: 9, weight: .regular))
                        .tracking(3)
                        .foregroundStyle(.white.opacity(0.2))
                    Text(vm.formatTime(vm.routine.endTime))
                        .customFont(.heading2)
                        .fontWeight(.regular)
                        .foregroundStyle(vm.accent.opacity(0.9))
                        .tracking(2)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 20)
            .padding(.bottom, 28)
            .padding(.horizontal, 32)
            .opacity(vm.appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.14), value: vm.appeared)
            
            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 0.5)
                .padding(.horizontal, 24)
        }
    }
}

// MARK: - Timeline Section

extension RoutineDetailView {
    
    private var timelineSection: some View {
        VStack(spacing: 20) {
            TimelineBarView(
                tasks: vm.tasks,
                startRaw: vm.routine.startTime,
                endRaw: vm.routine.endTime,
                accent: vm.accent,
                vm: vm
            )
            .frame(height: 120)
            .opacity(vm.appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.2), value: vm.appeared)
            
            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 0.5)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Task Section

extension RoutineDetailView {
    
    private var taskSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("ACTIVITIES")
                    .font(.system(size: 10, weight: .regular))
                    .tracking(4)
                    .foregroundStyle(.white.opacity(0.2))
                Spacer()
                Text("\(vm.tasks.count)")
                    .font(.system(size: 10, weight: .regular))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.2))
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 14)
            
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(vm.tasks, id: \.id) { task in
                        let index = vm.tasks.firstIndex(where: { $0.id == task.id }) ?? 0
                        
                        TaskRow(task: task, index: index, vm: vm)
                            .background(
                                vm.draggingTargetID == task.id
                                ? vm.accent.opacity(0.08)
                                : Color.clear
                            )
                            .onDrag {
                                vm.draggingTaskID = task.id
                                return NSItemProvider(object: task.id as NSString)
                            }
                            .onDrop(
                                of: [.text],
                                delegate: TaskDropDelegate(
                                    task: task,
                                    vm: vm
                                )
                            )
                    }
                }
            }
            .scrollDisabled(true)
            .environment(\.editMode, .constant(.active))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.07), lineWidth: 0.5)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 20)
            .opacity(vm.appeared ? 1 : 0)
            .offset(y: vm.appeared ? 0 : 20)
            .animation(.easeOut(duration: 0.55).delay(0.28), value: vm.appeared)
        }
    }
    
    private var listHeight: CGFloat {
        let minHeight = CGFloat(vm.tasks.count * 80)
        let maxHeight = CGFloat(vm.tasks.count * 100)
        
        return vm.expandedTaskID != nil ? maxHeight : minHeight
    }
}

// MARK: - Buttons

extension RoutineDetailView {
    
    private var addButton: some View {
        Button(action: { vm.addTask() }) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .light))
                Text("Add task")
                    .font(.system(size: 14, weight: .light))
                    .tracking(0.5)
            }
            .foregroundStyle(Color(uiColor: UIColor(hex: vm.routine.accentColor)))
            .frame(height: 52)
            .padding(.horizontal, 32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .shadow(radius: 5)
                    .opacity(0.8)
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var saveButton: some View {
        Button {
            guard vm.isValid else {
                vm.validationErrorMessage = vm.validationError
                vm.showErrorAlert = true
                return
            }
            onSave?(vm.routine)
            vm.showSuccessAlert = true
        } label: {
            Text("Save")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(
                    !vm.isSaveButtonDisabled
                        ? vm.accent
                        : .white.opacity(0.2)
                )
        }
        .disabled(vm.isSaveButtonDisabled)
    }
     
}

// MARK: - Mismatch Banner

extension RoutineDetailView {

    var mismatchBanner: some View {
        Group {
            if let mismatch = vm.durationMismatch {
                DurationMismatchBanner(mismatch: mismatch)
                    .padding(.bottom, 12)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: vm.durationMismatch == nil)
    }
}
