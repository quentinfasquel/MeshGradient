//
//  Color_float3.swift
//  MeshGradientCreator
//
//  Created by Quentin Fasquel on 22/06/2024.
//

import SwiftUI
import simd
#if os(iOS)
import UIKit
#else
import AppKit
#endif

extension SwiftUI.Color {
    var vector: simd_float3 {
        var r: CGFloat = -1
        var g: CGFloat = -1
        var b: CGFloat = -1
        var a: CGFloat = -1
        #if os(iOS)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        NSColor(self).usingColorSpace(.sRGB)?.getRed(&r, green: &g, blue: &b, alpha: &a)
        #endif
        return simd_float3(Float(r), Float(g), Float(b))
    }
}
