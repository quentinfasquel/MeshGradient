//
//  Gradient_CGColorSpace.swift
//  MeshGradient
//
//  Created by Quentin Fasquel on 10/08/2024.
//

import SwiftUI

extension Gradient.ColorSpace {
    var cgColorSpace: CGColorSpace? {
        switch self {
        case .device:
            return CGColorSpaceCreateDeviceRGB()
        case .perceptual:
            return CGColorSpace(name: CGColorSpace.linearSRGB)
        default:
            return nil
        }
    }
}
