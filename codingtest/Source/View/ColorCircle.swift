//
//  ColorCircle.swift
//  codingtest
//
//  Created by NgocThai on 2025/05/25.
//

import SwiftUI

struct ColorCircle: View {
    let color: Color
    @Binding var dragLocation: CGPoint
    @Binding var currentColor: Color
    @Binding var isDragging: Bool
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            Circle()
                .fill(color)
                .frame(width: 50)
                .shadow(radius: dragOffset != .zero ? 10 : 0)
                .aspectRatio(1.0, contentMode: .fit)
                .offset(dragOffset)
                .gesture(dragGesture)

            Circle()
                .stroke(dragOffset != .zero ? color : .clear,
                        style: StrokeStyle(lineWidth: 2,
                                           lineCap: .round,
                                           lineJoin: .miter,
                                           miterLimit: 0,
                                           dash: [3, 5],
                                           dashPhase: 0))
                .frame(width: 50)
                .aspectRatio(1.0, contentMode: .fit)
        }
    }

    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { gesture in
                dragOffset = gesture.translation
                dragLocation = gesture.location
                currentColor = color
                isDragging = true
            }
            .onEnded { gesture in
                dragOffset = .zero
                currentColor = .clear
                isDragging = false
            }
    }
}

struct ColorCircle_Previews: PreviewProvider {
    static var previews: some View {
        ColorCircle(color: .blue, dragLocation: .constant(.zero), currentColor: .constant(.black), isDragging: .constant(false))
    }
}
