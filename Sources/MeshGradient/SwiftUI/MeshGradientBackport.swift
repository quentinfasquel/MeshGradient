// The Swift Programming Language
// https://docs.swift.org/swift-book

import CoreGraphics.CGColorSpace
import MeshGradientCodable
import SwiftUI

private let defaultSubdivisions: Int = 18

public struct MeshGradientBackport: View {

    public var grid: Grid<ControlPoint>
    var background: Color
    var smoothsColors: Bool
    var colorSpace: Gradient.ColorSpace

    @available(iOS 16.0, macOS 14.0, *)
    public init(
        width: Int,
        height: Int,
        locations: MeshGradientData.Locations,
        colors: [Color],
        background: Color,
        smoothsColors: Bool = false,
        colorSpace: Gradient.ColorSpace = .device
    ) {
        self.grid = .init(width: width, locations: locations, colors: colors)
        self.background = background
        self.smoothsColors = smoothsColors
        self.colorSpace = colorSpace
    }

    public var body: some View {
        MeshView(
            grid: grid,
            grainAlpha: 0,
            subdivisions: defaultSubdivisions,
            background: background,
            colorSpace: colorSpace.cgColorSpace
        )
    }
}

extension Grid<ControlPoint> {
    init(
        width: Int,
        locations: MeshGradientData.Locations,
        colors: [Color]
    ) {
        switch locations {
        case .bezierPoints(let bezierPoints):
            self.init(width: width, bezierPoints: bezierPoints, colors: colors)
        case .points(let points):
            self.init(width: width, points: points, colors: colors)
        }
    }

    fileprivate init(
        width: Int,
        points: [SIMD2<Float>],
        colors: [Color]
    ) {
        print(#function)
        self.init(width: width, array: { points.enumerated().map { index, point in
            ControlPoint(
                color: colors[index].vector,
                location: point * .init(x: 2, y: -2) + .init(x: -1, y: 1),
                uTangent: .init(x: 0, y: 0),
                vTangent: .init(x: 0, y: 0)
            )
        } })
    }

    fileprivate init(
        width: Int,
        bezierPoints: [MeshGradientData.BezierPoint],
        colors: [Color]
    ) {
        //        private func uTangent(index: Int) -> SIMD2<Float> {
        //            let (x1, y1) = (index % width, index / width)
        //            let p0 = (x1 - 1) *
        //            bezierPoints[safe: ]
        //        }
        //        private func vTangent(index: Int) -> SIMD2<Float> {
        //
        //        }

        print("USING BEZIER POINTS")
        self.init(width: width, array: bezierPoints.enumerated().map { index, point in
            let scale = SIMD2<Float>(x: 2, y: -2)
            let translate = SIMD2<Float>(x: -1, y: 1)
            let location = point.position * scale + translate
            let leadingControlPoint = point.leadingControlPoint * scale + translate
            let topControlPoint = point.topControlPoint * scale + translate
            let trailingControlPoint = point.trailingControlPoint * scale + translate
            let bottomControlPoint = point.bottomControlPoint * scale + translate

            return ControlPoint(
                color: colors[index].vector,
                location: location,
//                uTangent: (point.leadingControlPoint * .init(x: 2, y: 2) - point.trailingControlPoint * .init(x: 2, y: 2)),
//                vTangent: (point.bottomControlPoint * .init(x: 2, y: 2) - point.topControlPoint * .init(x: 2, y: 2))
//                uTangent: (point.leadingControlPoint * .init(x: 0, y: 0) - point.trailingControlPoint * .init(x: 0, y: 0)),
//                vTangent: (point.bottomControlPoint * .init(x: 0, y: 0) - point.topControlPoint * .init(x: 0, y: 0))
                uTangent: leadingControlPoint - trailingControlPoint,
                vTangent: bottomControlPoint - topControlPoint
            )
        })
    }
}
