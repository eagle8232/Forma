//
//  FocusInsightView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/6/26.
//

import SwiftUI

struct FocusInsightView: View {
    let text: String
    let phase: FocusModeViewModel.InsightPhase

    private let purple = Color(hex: "#A259FF")

    var body: some View {
        Text(text)
            .font(AppFont.displayItalic(12.5))
            .foregroundColor(.white.opacity(textOpacity))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .shadow(color: purple.opacity(0.9), radius: 20)
            .shadow(color: purple.opacity(0.5), radius: 40)
            .offset(y: yOffset)
            .scaleEffect(scale)
            .blur(radius: blurRadius)
            .frame(width: 120)
            .allowsHitTesting(false)
    }

    private var textOpacity: Double {
        switch phase {
        case .hidden:   return 0
        case .entering: return 1
        case .floating: return 1
        case .leaving:  return 0
        }
    }

    private var yOffset: CGFloat {
        switch phase {
        case .hidden:   return 20
        case .entering: return 0
        case .floating: return -8
        case .leaving:  return -22
        }
    }

    private var scale: CGFloat {
        switch phase {
        case .hidden:   return 0.85
        case .entering: return 1.0
        case .floating: return 1.0
        case .leaving:  return 0.88
        }
    }

    private var blurRadius: CGFloat {
        switch phase {
        case .hidden:   return 4
        case .entering: return 0
        case .floating: return 0
        case .leaving:  return 3
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        FocusInsightView(text: "Break it into the\nsmallest next step", phase: .entering)
            .frame(width: 200, height: 200)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
        
        FocusInsightView(text: "Stay with it\na little longer", phase: .floating)
            .frame(width: 200, height: 200)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
    }
    .padding()
    .background(Color.adaptive(dark: Color(hex: "#0D0D0D"), light: Color.white))
}
