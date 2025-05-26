//
//  Models.swift
//  codingtest
//
//  Created by NgocThai on 2025/05/20.
//

import SwiftUI

class Stack: Item {
    let id = UUID()
    var contents: [Item]
    var axis: Axis
    var rect: CGRect {
        didSet {
            adjustContentsSize()
        }
    }

    func getRectForContents(in rect: CGRect) -> [CGRect] {
        if axis == .horizontal {
            let width = rect.width / CGFloat(contents.count)
            return (0 ..< contents.count).map { i in
                CGRect(x: rect.minX + (width * CGFloat(i)),
                       y: rect.minY,
                       width: width,
                       height: rect.height)
            }
        } else if axis == .vertical {
            let height = rect.height / CGFloat(contents.count)
            return (0 ..< contents.count).map { i in
                CGRect(x: rect.minX,
                       y: rect.minY + (height * CGFloat(i)),
                       width: rect.width,
                       height: height)
            }
        }
        return [rect]
    }

    func getColorItems(in rect: CGRect) -> [ColorItem] {
        let rects = getRectForContents(in: rect)
        var items: [ColorItem] = []
        for (index, content) in contents.enumerated() {
            if let stack = content as? Stack {
                let colorItems = stack.getColorItems(in: rects[index])
                items.append(contentsOf: colorItems)
            } else if let colorItem = content as? ColorItem {
                colorItem.rect = rects[index]
                items.append(colorItem)
            }
        }
        return items
    }

    func getStacks() -> [Stack] {
        var items: [Stack] = [self]
        for content in contents {
            if let stack = content as? Stack {
                let colorItems = stack.getStacks()
                items.append(contentsOf: colorItems)
            }
        }
        return items
    }

    func getStack(in rect: CGRect) -> [(Stack, CGRect)] {
        let rects = getRectForContents(in: rect)
        var items: [(Stack, CGRect)] = [(self, rect)]
        for (index, content) in contents.enumerated() {
            if let stack = content as? Stack {
                let stacks = stack.getStack(in: rects[index])
                items.append(contentsOf: stacks)
            }
        }
        return items
    }

    init(contents: [Item] = [], axis: Axis = .horizontal, rect: CGRect = .zero) {
        self.contents = contents
        self.axis = axis
        self.rect = rect
    }

    /// Adjust all contents in this stack to appropriate size by content's order.
    func adjustContentsSize() {
        let numberChildren = CGFloat(contents.count)
        if axis == .horizontal {
            let width = rect.width / numberChildren
            for i in 0 ..< contents.count {
                contents[i].rect = CGRect(x: rect.minX + (width * CGFloat(i)),
                                          y: rect.minY,
                                          width: width,
                                          height: rect.height)
            }
        } else if axis == .vertical {
            let height = rect.height / numberChildren
            for i in 0 ..< contents.count {
                contents[i].rect = CGRect(x: rect.minX,
                                          y: rect.minY + (height * CGFloat(i)),
                                          width: rect.width,
                                          height: height)
            }
        }
    }

    func addContent(_ stack: Stack, at pos: Int = 0) {
        let add = Stack(contents: stack.contents, axis: stack.axis, rect: stack.rect)
        contents.insert(add, at: pos)
    }

    func addContent(_ item: ColorItem, at pos: Int = 0) {
        let add = ColorItem(rect: item.rect, color: item.color)
        contents.insert(add, at: pos)
    }
}

class ColorItem: Item {
    let id = UUID()
    var rect: CGRect = .zero
    var color: Color = .clear

    init(rect: CGRect = .zero, color: Color = .clear) {
        self.rect = rect
        self.color = color
    }
}

protocol Item {
    var id: UUID { get }
    var rect: CGRect { get set }
}
