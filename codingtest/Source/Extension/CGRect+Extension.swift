//
//  CGRect+Extension.swift
//  codingtest
//
//  Created by NgocThai on 2025/05/24.
//

import SwiftUI

extension CGRect {
    func split(into count: Int, in axis: Axis) -> [CGRect] {
        guard count > 0 else { return [] }
        if axis == .horizontal {
            let width = self.width / CGFloat(count)
            return (0 ..< count).map { i in
                CGRect(x: self.minX + (width * CGFloat(i)),
                       y: self.minY,
                       width: width,
                       height: self.height)
            }
        } else if axis == .vertical {
            let height = self.height / CGFloat(count)
            return (0 ..< count).map { i in
                CGRect(x: self.minX,
                       y: self.minY + (height * CGFloat(i)),
                       width: self.width,
                       height: height)
            }
        }
        return []
    }
}
