//
//  CarouselRingSection.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

struct CarouselRingSection: View {

    let routines: [RoutineBlock]
    @Binding var selectedIndex: Int
    var progressFor: (RoutineBlock) -> Double
    var onSelect: (Int) -> Void

    // Live drag offset
    @State private var dragOffset: CGFloat = 0

    // Layout constants
    private let centerSize:  CGFloat = 220
    private let sideSize:    CGFloat = 130
    private let sideOpacity: Double  = 0.35
    // How far the side ring centres sit from the screen centre
    private let sideSpread:  CGFloat = 155

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Render prev, center, next only — anything further is invisible
                ForEach(visibleIndices, id: \.self) { index in
                    ringItem(index: index, geo: geo)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(dragGesture)
        }
    }

    // MARK: - Visible indices (prev, current, next)

    private var visibleIndices: [Int] {
        var result: [Int] = [selectedIndex]
        if selectedIndex > 0                   { result.append(selectedIndex - 1) }
        if selectedIndex < routines.count - 1  { result.append(selectedIndex + 1) }
        return result
    }

    // MARK: - Ring item

    private func ringItem(index: Int, geo: GeometryProxy) -> some View {
        let routine       = routines[index]
        let accent        = Color(uiColor: UIColor(hex: routine.accentColor))
        let offset        = itemOffset(for: index, in: geo)
        let isCenter      = index == selectedIndex
        let size: CGFloat = isCenter ? centerSize : sideSize
        let opacity       = itemOpacity(for: index)

        return CircleProgressView(
            progress: progressFor(routine),
            size: size,
            strokeWidth: isCenter ? 5 : 3,
            accent: accent
        ) {
            if isCenter {
                centerLabel(routine: routine)
            } else {
                sideLabel(routine: routine, accent: accent)
            }
        }
        .opacity(opacity)
        .offset(x: offset)
        .animation(AppAnimation.springGentle, value: selectedIndex)
        .animation(AppAnimation.springGentle, value: dragOffset)
        // Tap on a side ring to select it directly
        .onTapGesture {
            guard !isCenter else { return }
            withAnimation(AppAnimation.springGentle) {
                selectedIndex = index
            }
            onSelect(index)
        }
        .allowsHitTesting(true)
        .zIndex(isCenter ? 1 : 0)
    }

    // MARK: - Labels

    private func centerLabel(routine: RoutineBlock) -> some View {
        VStack(spacing: 3) {
            Text("\(Int(progressFor(routine) * 100))")
                .customFont(.displayThin)
                .tracking(AppTracking.display)
                .foregroundStyle(AppColor.textPrimary)

            Text("%")
                .customFont(.heading2)
                .foregroundStyle(AppColor.textDisabled)

            Text("complete")
                .customFont(.microTracked)
                .tracking(AppTracking.sectionLabel)
                .foregroundStyle(AppColor.textTertiary)
        }
    }

    private func sideLabel(routine: RoutineBlock, accent: Color) -> some View {
        VStack(spacing: 4) {
            Text(routine.icon)
                .font(.system(size: 16))
                .opacity(0.6)

            Text(routine.title)
                .customFont(.microTracked)
                .tracking(AppTracking.microLabel)
                .foregroundStyle(accent.opacity(0.4))
                .lineLimit(1)
                .frame(maxWidth: sideSize * 0.7)
        }
    }

    // MARK: - Offset calculation
    // Each ring slides from its resting position plus a parallax fraction of dragOffset.

    private func itemOffset(for index: Int, in geo: GeometryProxy) -> CGFloat {
        let restingX = restingOffset(for: index)
        // Side rings move at 0.6x speed relative to center for parallax feel
        let parallaxFactor: CGFloat = index == selectedIndex ? 1.0 : 0.55
        return restingX + dragOffset * parallaxFactor
    }

    private func restingOffset(for index: Int) -> CGFloat {
        let delta = index - selectedIndex
        switch delta {
        case 0:  return 0
        case -1: return -sideSpread
        case 1:  return  sideSpread
        default:
            // Push unseen rings off-screen in the right direction
            return delta < 0 ? -sideSpread * 2 : sideSpread * 2
        }
    }

    private func itemOpacity(for index: Int) -> Double {
        let delta  = abs(index - selectedIndex)
        let drag   = abs(dragOffset)
        let reveal = min(drag / 60, 1.0)   // fade in as user drags

        switch delta {
        case 0: return 1.0
        case 1: return sideOpacity + reveal * (0.55 - sideOpacity)
        default: return 0
        }
    }

    // MARK: - Drag gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                // Resist at the edges
                let isAtStart = selectedIndex == 0            && value.translation.width > 0
                let isAtEnd   = selectedIndex == routines.count - 1 && value.translation.width < 0
                let resistance: CGFloat = 0.25
                dragOffset = (isAtStart || isAtEnd)
                    ? value.translation.width * resistance
                    : value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 55
                let velocity           = value.predictedEndTranslation.width

                let shouldAdvance = velocity < -threshold || (value.translation.width < -threshold && velocity < 0)
                let shouldRetreat = velocity >  threshold || (value.translation.width >  threshold && velocity > 0)

                withAnimation(AppAnimation.springGentle) {
                    dragOffset = 0
                    if shouldAdvance && selectedIndex < routines.count - 1 {
                        selectedIndex += 1
                        onSelect(selectedIndex)
                    } else if shouldRetreat && selectedIndex > 0 {
                        selectedIndex -= 1
                        onSelect(selectedIndex)
                    }
                }
            }
    }
}
