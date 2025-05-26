//
//  WidgetView.swift
//  codingtest
//
//  Created by NgocThai on 2025/05/17.
//

import SwiftUI

struct WidgetView: View {
    let colors: [Color] = [.init("blue"), .init("pink"), .init("yellow"), .init("green"), .init("orange")]
    @State var currentColor: Color = .clear
    @State var dragLocation: CGPoint = .zero
    @State var isDragging = false
    @State var isMute = false
    @StateObject var viewModel = MyViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                GeometryReader { proxy in
                    ZStack {
                        if viewModel.items.isEmpty {
                            greetingView
                        }
                        canvas
                        overlay
                    }
                    .onAppear {
                        viewModel.setContextSize(proxy.size)
                    }
                    .onChange(of: dragLocation) { newValue in
                        let frame = proxy.frame(in: .global)
                        if frame.contains(newValue) { // drag inside
                            let localLocation = CGPoint(x: newValue.x - frame.minX,
                                                        y: newValue.y - frame.minY)
                            viewModel.dragInside(with: currentColor, at: localLocation)
                        } else {
                            viewModel.dragOutside()
                        }
                    }
                    .onChange(of: isDragging) { newValue in
                        if !newValue {
                            let frame = proxy.frame(in: .global)
                            if frame.contains(dragLocation) { // drag inside
                                let localLocation = CGPoint(x: dragLocation.x - frame.minX,
                                                            y: dragLocation.y - frame.minY)
                                viewModel.endDragging(at: localLocation)
                            }
                        }
                    }
                }
                .aspectRatio(1.0, contentMode: .fit)

                Spacer()

                HStack {
                    Spacer()
                    ForEach(colors, id: \.self) { color in
                        ColorCircle(color: color, dragLocation: $dragLocation, currentColor: $currentColor, isDragging: $isDragging)
                        Spacer()
                    }
                }
            }
            .padding()
            .toolbar { toolBarView }
        }
    }

    var greetingView: some View {
        VStack(spacing: 20) {
            Text("👋")
                .font(.system(size: 70))
            Text("Hi! Drag and drop your widgets to unleash your creativity!")
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }

    var canvas: some View {
        Group {
            Canvas { context, size in
                for (item) in viewModel.items {
                    var path = Path()
                    path.addRoundedRect(in: item.rect,
                                        cornerSize: CGSize(width: 36, height: 36))
                    context.fill(path, with: .color(item.color))
                }
            }
            if let tempItem = viewModel.draggingItem {
                Path { path in
                    path.addRoundedRect(in: tempItem.rect,
                                        cornerSize: CGSize(width: 36, height: 36))
                }
                .fill(tempItem.color)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 2, y: 2)
            }
        }
    }

    var overlay: some View {
        RoundedRectangle(cornerRadius: 36)
            .stroke(viewModel.items.isEmpty ? Color.gray : Color.clear,
                    style: StrokeStyle(lineWidth: 3,
                                       lineCap: .round,
                                       lineJoin: .miter,
                                       miterLimit: 0,
                                       dash: [6, 10],
                                       dashPhase: 0))
    }

    var toolBarView: some ToolbarContent {
        Group {
            ToolbarItem {
                Button {
                    isMute.toggle()
                    viewModel.setMute(isMute: isMute)
                } label: {
                    Image(systemName: isMute ? "speaker.slash.fill" : "speaker.wave.3.fill")
                }
            }

            ToolbarItem {
                Button {
                    viewModel.reset()
                } label: {
                    Text("Reset")
                }
            }
        }
    }
}
