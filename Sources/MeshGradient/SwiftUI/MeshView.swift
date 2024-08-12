
import Foundation
import MetalKit
@_implementationOnly import MeshGradientCHeaders

public enum MeshGradientDefaults {
	public static let grainAlpha: Float = 0.05
	public static let subdivisions: Int = 18
}

public enum MeshGradientState {
	case animated(initial: Grid<ControlPoint>, animatorConfiguration: MeshAnimator.Configuration)
	case `static`(grid: Grid<ControlPoint>)

    public func createDataProvider() -> MeshDataProvider {
        switch self {
        case .animated(let initial, let animatorConfiguration):
            return MeshAnimator(grid: initial, configuration: animatorConfiguration)
        case .static(let grid):
            return StaticMeshDataProvider(grid: grid)
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

#if canImport(UIKit)
import UIKit

public struct MeshView: UIViewRepresentable {

    private let grid: Grid<ControlPoint>
	private let state: MeshGradientState
	private let subdivisions: Int
    private let grainAlpha: Float
    private let background: Color
    private let colorSpace: CGColorSpace?

	public init(initialGrid: Grid<ControlPoint>,
				animatorConfiguration: MeshAnimator.Configuration,
				grainAlpha: Float = MeshGradientDefaults.grainAlpha,
				subdivisions: Int = MeshGradientDefaults.subdivisions,
                background: Color,
                colorSpace: CGColorSpace? = nil) {
		self.state = .animated(initial: initialGrid, animatorConfiguration: animatorConfiguration)
        self.grid = initialGrid
        self.grainAlpha = grainAlpha
		self.subdivisions = subdivisions
        self.background = background
        self.colorSpace = colorSpace
	}
	
	public init(grid: Grid<ControlPoint>,
				grainAlpha: Float = MeshGradientDefaults.grainAlpha,
				subdivisions: Int = MeshGradientDefaults.subdivisions,
                background: Color,
                colorSpace: CGColorSpace? = nil) {
		self.state = .static(grid: grid)
        self.grid = grid
		self.grainAlpha = grainAlpha
		self.subdivisions = subdivisions
        self.background = background
        self.colorSpace = colorSpace
	}

//    public init(provider: MeshDataProvider,
//                grainAlpha: Float = MeshGradientDefaults.grainAlpha,
//                subdivisions: Int = MeshGradientDefaults.subdivisions,
//                colorSpace: CGColorSpace? = nil) {
//        self.state = .interactive(provider)
//        self.grainAlpha = grainAlpha
//        self.subdivisions = subdivisions
//        self.colorSpace = colorSpace
//    }

	public func makeUIView(context: Context) -> MTKView {
		let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.clearColor = .init(background)
//        view.layer.isGeometryFlipped = true
        view.isUserInteractionEnabled = false
        let dataProvider = state.createDataProvider()
        context.coordinator.renderer = .init(metalKitView: view, meshDataProvider: dataProvider, grainAlpha: grainAlpha, subdivisions: subdivisions)

		switch state {
		case .animated:
			view.isPaused = false
			view.enableSetNeedsDisplay = false
		case .static:
			view.isPaused = true
			view.enableSetNeedsDisplay = true
		}
		
        view.backgroundColor = UIColor(background)
		view.delegate = context.coordinator.renderer
        view.preferredFramesPerSecond = (dataProvider as? MeshAnimator)?.configuration.framesPerSecond ?? 60
		return view
	}
	
	public func updateUIView(_ view: MTKView, context: Context) {
        switch state {
        case .animated(_, let animatorConfiguration):
            guard let animator = context.coordinator.renderer.meshDataProvider as? MeshAnimator else {
                fatalError("Incorrect mesh data provider type. Expected \(MeshAnimator.self), got \(type(of: context.coordinator.renderer.meshDataProvider))")
            }
            animator.configuration = animatorConfiguration
            animator.configuration.framesPerSecond = min(animatorConfiguration.framesPerSecond, view.preferredFramesPerSecond)
            view.preferredFramesPerSecond = animator.configuration.framesPerSecond
        case .static(let grid):
            guard let staticMesh = context.coordinator.renderer.meshDataProvider as? StaticMeshDataProvider else {
                fatalError("Incorrect mesh data provider type. Expected \(StaticMeshDataProvider.self), got \(type(of: context.coordinator.renderer.meshDataProvider))")
            }

            staticMesh.grid = grid
            view.setNeedsDisplay()
            view.preferredFramesPerSecond = 60
        }
//        withAnimation {
//            context.coordinator.grid = grid
//        }

		context.coordinator.renderer.mtkView(view, drawableSizeWillChange: view.drawableSize)
		context.coordinator.renderer.subdivisions = subdivisions
        context.coordinator.renderer.grainAlpha = grainAlpha

        view.clearColor = .init(background)
	}
	
	public func makeCoordinator() -> Coordinator {
        return .init()
	}
	
    public final class Coordinator {
		var renderer: MetalMeshRenderer!
//        public var grid: Grid<ControlPoint>
//        public var animatableData: Grid<ControlPoint> {
//            get { grid }
//            set { grid = newValue }
//        }
//        init(grid: Grid<ControlPoint>) {
//            self.grid = grid
//        }
	}
	
}

#elseif canImport(AppKit) // canImport(UIKit)

import AppKit

public struct MeshView: NSViewRepresentable {

    private let grid: Grid<ControlPoint>
	private let state: MeshGradientState
	private let subdivisions: Int
	private let grainAlpha: Float
    private let background: Color
    private let colorSpace: CGColorSpace?
	
	public init(initialGrid: Grid<ControlPoint>,
				animatorConfiguration: MeshAnimator.Configuration,
				grainAlpha: Float = MeshGradientDefaults.grainAlpha,
				subdivisions: Int = MeshGradientDefaults.subdivisions,
                background: Color,
                colorSpace: CGColorSpace? = nil) {
		self.state = .animated(initial: initialGrid, animatorConfiguration: animatorConfiguration)
        self.grid = initialGrid
		self.grainAlpha = grainAlpha
		self.subdivisions = subdivisions
        self.background = background
        self.colorSpace = colorSpace
	}
	
	public init(grid: Grid<ControlPoint>,
				grainAlpha: Float = MeshGradientDefaults.grainAlpha,
				subdivisions: Int = MeshGradientDefaults.subdivisions,
                background: Color,
                colorSpace: CGColorSpace? = nil) {
		self.state = .static(grid: grid)
        self.grid = grid
		self.grainAlpha = grainAlpha
		self.subdivisions = subdivisions
        self.background = background
        self.colorSpace = colorSpace
	}
//    public init(dataProvider: MeshDataProvider,
//                grainAlpha: Float = MeshGradientDefaults.grainAlpha,
//                subdivisions: Int = MeshGradientDefaults.subdivisions,
//                background: Color,
//                colorSpace: CGColorSpace? = nil) {
//        self.state = .interactive(dataProvider)
//        self.grainAlpha = grainAlpha
//        self.subdivisions = subdivisions
//        self.background = background
//        self.colorSpace = colorSpace
//    }
//
	public func makeNSView(context: Context) -> MTKView {
		let view = MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
        view.clearColor = .init(background)
        view.colorspace = CGColorSpace(name: CGColorSpace.acescgLinear)
        let dataProvider = state.createDataProvider()
		context.coordinator.renderer = .init(metalKitView: view, meshDataProvider: dataProvider, grainAlpha: grainAlpha, subdivisions: subdivisions)
		
		switch state {
        case .animated:
			view.isPaused = false
			view.enableSetNeedsDisplay = false
		case .static:
			view.isPaused = true
			view.enableSetNeedsDisplay = true
		}
		
		view.delegate = context.coordinator.renderer
        view.preferredFramesPerSecond = (dataProvider as? MeshAnimator)?.configuration.framesPerSecond ?? 60
		return view
	}
	
	public func updateNSView(_ view: MTKView, context: Context) {
		switch state {
		case .animated(_, let animatorConfiguration):
			guard let animator = context.coordinator.renderer.meshDataProvider as? MeshAnimator else {
				fatalError("Incorrect mesh data provider type. Expected \(MeshAnimator.self), got \(type(of: context.coordinator.renderer.meshDataProvider))")
			}
			animator.configuration = animatorConfiguration
			animator.configuration.framesPerSecond = min(animatorConfiguration.framesPerSecond, view.preferredFramesPerSecond)
            view.preferredFramesPerSecond = animator.configuration.framesPerSecond
		case .static(let grid):
			guard let staticMesh = context.coordinator.renderer.meshDataProvider as? StaticMeshDataProvider else {
				fatalError("Incorrect mesh data provider type. Expected \(StaticMeshDataProvider.self), got \(type(of: context.coordinator.renderer.meshDataProvider))")
			}
			staticMesh.grid = grid
			view.setNeedsDisplay(view.bounds)
            view.preferredFramesPerSecond = 60
		}

		context.coordinator.renderer.mtkView(view, drawableSizeWillChange: view.drawableSize)
		context.coordinator.renderer.subdivisions = subdivisions
        context.coordinator.renderer.grainAlpha = grainAlpha

        view.clearColor = .init(background)
//        view.colorspace = colorSpace
	}
	
	public func makeCoordinator() -> Coordinator {
        return .init(parent: self)
	}
	
    public final class Coordinator {
        var parent: MeshView
        var renderer: MetalMeshRenderer!

        init(parent: MeshView) {
            self.parent = parent
        }
	}
	
}
#endif // canImport(AppKit)

#endif // canImport(SwiftUI)
