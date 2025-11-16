//
//  FlowLayout.swift
//  RuntimeHackathon
//
//  Created by SHILO Yulia on 23.08.2025.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat
    var lineSpacing: CGFloat

    init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let maxWidth = proposal.replacingUnspecifiedDimensions().width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > maxWidth && lineWidth > 0 {
                width = max(width, lineWidth)
                height += lineHeight + lineSpacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }

        width = max(width, lineWidth)
        height += lineHeight

        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard !subviews.isEmpty else { return }

        let maxWidth = proposal.replacingUnspecifiedDimensions().width
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }

        var x = bounds.minX
        var y = bounds.minY
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]

            if lineWidth + size.width > maxWidth && lineWidth > 0 {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            subview.place(
                at: CGPoint(x: x + size.width/2, y: y + size.height/2),
                anchor: .center,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            x += size.width + spacing
        }
    }
}

#Preview {
    FlowLayout(spacing: 8, lineSpacing: 8) {
        Text("Тег 1")
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(12)
        
        Text("Тег 2")
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.2))
            .cornerRadius(12)
        
        Text("Очень длинный тег")
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(12)
    }
    .padding()
}
