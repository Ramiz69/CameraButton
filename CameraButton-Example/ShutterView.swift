//
//  ShutterView.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import SwiftUI
import CameraButton

/// The same configured button, built either with the SwiftUI wrapper or with the UIKit API.
struct ShutterView: View {

    @Bindable var model: CameraModel
    let configuration: ButtonConfiguration
    let type: CameraType
    let progress: CGFloat

    var body: some View {
        switch configuration.framework {
        case .swiftUI:
            CameraShutterButton(type: type,
                                style: configuration.style,
                                isRecording: $model.isRecording,
                                recordingProgress: progress) {
                if type == .photo {
                    model.capturePhoto()
                }
            } configure: { button in
                configuration.apply(to: button)
            }
        case .uiKit:
            UIKitShutter(model: model, configuration: configuration, type: type, progress: progress)
        }
    }

}

/// Hosts `CameraButton` exactly as a UIKit screen would use it: properties plus `CameraButtonDelegate`.
private struct UIKitShutter: UIViewRepresentable {

    let model: CameraModel
    let configuration: ButtonConfiguration
    let type: CameraType
    let progress: CGFloat

    func makeUIView(context: Context) -> CameraButton {
        let button = CameraButton()
        button.delegate = context.coordinator

        return button
    }

    func updateUIView(_ button: CameraButton, context: Context) {
        configuration.apply(to: button)
        button.style = configuration.style
        if button.type != type {
            button.type = type
        }
        if type == .video, button.isSelected != model.isRecording {
            button.isSelected = model.isRecording
        }
        if button.recordingProgress != progress {
            button.recordingProgress = progress
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(model: model)
    }

    final class Coordinator: CameraButtonDelegate {

        private let model: CameraModel

        init(model: CameraModel) {
            self.model = model
        }

        func didTapButton(_ button: CameraButton) {
            switch button.type {
            case .photo: model.capturePhoto()
            case .video: model.isRecording = button.isSelected
            }
        }

    }

}
