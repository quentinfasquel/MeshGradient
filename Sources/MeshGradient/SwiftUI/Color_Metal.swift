//
//  Color_Metal.swift
//  
//
//  Created by Quentin Fasquel on 22/06/2024.
//

import SwiftUI
import Metal
#if os(iOS)
import UIKit
#else
import AppKit
#endif

extension MTLClearColor {
    init(_ color: SwiftUI.Color) {
        var r: CGFloat = -1
        var g: CGFloat = -1
        var b: CGFloat = -1
        var a: CGFloat = -1
#if os(iOS)
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
#else
        NSColor(color).usingType(.componentBased)?.getRed(&r, green: &g, blue: &b, alpha: &a)
#endif
        self.init(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }
}
