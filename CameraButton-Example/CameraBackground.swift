//
//  CameraBackground.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import SwiftUI
import AVFoundation

/// Live camera preview on device, an animated scene in the Simulator.
struct CameraBackground: View {

    let model: CameraModel

    var body: some View {
        switch model.source {
        case .live:
            CameraPreview(session: model.service.session)
        case .simulated, .loading:
            TimelineView(.animation) { context in
                SimulatedScene(date: context.date)
            }
        case .denied:
            ZStack {
                SimulatedScene(date: .distantPast)
                ContentUnavailableView {
                    Label("Camera access is off", systemImage: "camera.fill")
                } description: {
                    Text("The demo works without it. Turn it on in Settings to see the button over a live preview.")
                } actions: {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
    }

}

/// Slowly drifting mesh gradient, so Liquid Glass has something to refract.
struct SimulatedScene: View {

    let date: Date

    var body: some View {
        let t = Float(date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 600))
        let drift = { (phase: Float) in 0.5 + 0.25 * sin(t * 0.4 + phase) }
        MeshGradient(width: 3,
                     height: 3,
                     points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [drift(0), drift(2)], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                     ],
                     colors: [
                        .indigo, .purple, .pink,
                        .blue, .orange, .red,
                        .teal, .mint, .yellow
                     ])
    }

}

private struct CameraPreview: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill

        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}

    final class PreviewView: UIView {

        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var previewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }

    }

}
