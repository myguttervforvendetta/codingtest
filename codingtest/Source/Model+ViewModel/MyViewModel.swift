//
//  MyViewModel.swift
//  codingtest
//
//  Created by NgocThai on 2025/05/17.
//

import SwiftUI
import AVFoundation

enum Side {
    case top, bottom, left, right, none
}

enum Zone {
    case all, onlyVertical, onlyHorizontal
}

class MyViewModel: ObservableObject {
    var contextSize = CGSize()
    var stack = Stack()
    @Published var items: [ColorItem] = []
    @Published var draggingItem: ColorItem?

    var player: AVAudioPlayer?

    init() {
        initSound()
    }

    var contextRect: CGRect {
        CGRect(origin: .zero, size: contextSize)
    }

    var allColorItems: [ColorItem] {
        return stack.getColorItems(in: contextRect)
    }

    var allStacks: [Stack] {
        return stack.getStacks()
    }

    var allStackRects: [(Stack, CGRect)] {
        return stack.getStack(in: contextRect)
    }

    func setContextSize(_ size: CGSize) {
        contextSize = size
    }

    private func hitTest(in rect: CGRect, withDragLocation location: CGPoint) -> (Side, Axis) {
        guard rect.contains(location) else { return (.none, .horizontal) }
        let m = (rect.maxY - rect.minY)/(rect.maxX - rect.minX)
        let y1 = location.x * m + (rect.minY - m * rect.minX)
        let y2 = rect.maxY - y1 + rect.minY
        if location.y < y1 {
            return location.y < y2 ? (.top, .vertical) : (.right, .horizontal)
        } else {
            return location.y < y2 ? (.left, .horizontal) : (.bottom, .vertical)
        }
    }

    private func getTouchItem(at location: CGPoint) -> ColorItem? {
        return allColorItems.first(where: { $0.rect.contains(location) })
    }

    private func getTouchStackRect(at touchedItem: ColorItem) -> (Stack, CGRect)? {
        return allStackRects.first(where: { $0.0.contents.contains { $0.id == touchedItem.id } })
    }

    private func initSound() {
        guard let path = Bundle.main.path(forResource: "d6", ofType:"m4a") else {
            return }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 0.6
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension MyViewModel {
    func dragInside(with color: Color, at location: CGPoint) {
        guard let tempItem = draggingItem else {
            draggingItem = ColorItem(rect: .zero, color: color)
            return
        }
        if allColorItems.isEmpty {
            tempItem.rect = contextRect
        }
        guard let touchedItem = getTouchItem(at: location) else { return }
        guard let (touchedStack, stackRect) = getTouchStackRect(at: touchedItem) else { return }
        let (_, touchStackAxis) = hitTest(in: stackRect, withDragLocation: location)
        let (_, touchItemAxis) = hitTest(in: touchedItem.rect, withDragLocation: location)
        if touchItemAxis == touchedStack.axis {
            var smallRects = stackRect.split(into: touchedStack.contents.count + 1, in: touchedStack.axis)
            if let touchIndex = smallRects.firstIndex(where: { $0.contains(location) }) {
                tempItem.rect = smallRects[touchIndex]
                smallRects.remove(at: touchIndex)
                for (i, rect) in smallRects.enumerated() {
                    touchedStack.contents[i].rect = rect
                }
            }
        } else { // touchItemAxis != touchedStack.axis
            let smallRects = touchedItem.rect.split(into: 2, in: touchItemAxis)
            if let index = smallRects.firstIndex(where: { $0.contains(location) }) {
                tempItem.rect = smallRects[index]
                touchedItem.rect = smallRects[1 - index]
            }
            if touchedStack.id == stack.id && touchedStack.contents.count == 1 {
                stack.axis = touchStackAxis
            }
        }
    }

    func dragOutside() {
        draggingItem = nil
        items = allColorItems
    }

    /// When user release finger
    func endDragging(at location: CGPoint) {
        if let dragItem = draggingItem {
            if allColorItems.isEmpty {
                stack.addContent(dragItem)
            } else {
                if let touchedItem = getTouchItem(at: location),
                   let (touchedStack, stackRect) = getTouchStackRect(at: touchedItem) {
                    let (_, touchItemAxis) = hitTest(in: touchedItem.rect, withDragLocation: location)
                    if touchItemAxis == touchedStack.axis {
                        let rects = stackRect.split(into: touchedStack.contents.count + 1, in: touchedStack.axis)
                        if let index = rects.firstIndex(where: { $0.contains(location) }) {
                            touchedStack.addContent(dragItem, at: index)
                        }
                    } else { // touchItemAxis != touchedStack.axis
                        let rects = stackRect.split(into: touchedStack.contents.count, in: touchedStack.axis)
                        let smallRects = touchedItem.rect.split(into: 2, in: touchItemAxis)
                        var array: [ColorItem] = []
                        if let index = smallRects.firstIndex(where: { $0.contains(location) }) {
                            let oldItem = ColorItem(rect: smallRects[1 - index], color: touchedItem.color)
                            if index == 0 {
                                array.append(contentsOf: [dragItem, oldItem])
                            } else {
                                array.append(contentsOf: [oldItem, dragItem])
                            }
                        }
                        let newStack = Stack(contents: array, axis: touchItemAxis, rect: touchedItem.rect)
                        if let touchIndex = rects.firstIndex(where: { $0.contains(location) }) {
                            touchedStack.contents.remove(at: touchIndex)
                            touchedStack.addContent(newStack, at: touchIndex)
                        }
                    }
                }
            }
        }
        draggingItem = nil
        items = allColorItems
        player?.play()
    }

    func reset() {
        stack.contents.removeAll()
        items = allColorItems
    }

    func setMute(isMute: Bool) {
        player?.volume = isMute ? 0 : 0.6
    }
}
