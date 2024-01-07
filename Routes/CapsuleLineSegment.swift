//
//  VerticalAccessoryGaugeStyle.swift
//  Routes
//
//  Created by Blake Haug on 1/5/24.
//

import Foundation
import SwiftUI

func mapVal(val: CGFloat, newMin: CGFloat, newMax: CGFloat) -> CGFloat {
    return (newMax - newMin) * val + newMin
}

func paddedVal(val: CGFloat) -> CGFloat {
    // Ensure even spacing between items
    return mapVal(val: val, newMin: 0.05, newMax: 0.95)
}

struct CapsuleLineSegment: View {
    @State var items: Array<String>

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    Capsule()
                        .fill(.tint)
                        .rotationEffect(.degrees(180))
                    ForEach(items, id: \.self) { item in
                        Circle()
                            .stroke(.background, style: StrokeStyle(lineWidth: 3))
                            .position(
                                x: 5,
                                y: proxy.size.height * paddedVal(val: CGFloat(items.firstIndex(of: item)!) / CGFloat(items.count-1))
                            )
                    }
                }
                .frame(width: 10, alignment: .leading)
                .clipped()
            }
            VStack(alignment: .leading, spacing: 0) {
                GeometryReader { proxy in
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .position(
                                x: proxy.size.width-165,
                                y: proxy.size.height * paddedVal(val: CGFloat(items.firstIndex(of: item)!) / CGFloat(items.count-1))
                            )
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.frame(height: 300)
    }
}
