//
//  CameraShutterButton.swift
//  CameraButton
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import SwiftUI

/// SwiftUI wrapper around `CameraButton`.
///
/// ```swift
/// CameraShutterButton(type: .video, style: .glass, isRecording: $isRecording) {
///     isRecording ? recorder.start() : recorder.stop()
/// }
/// .frame(width: 72, height: 72)
/// ```
public struct CameraShutterButton: UIViewRepresentable {

    // MARK: Properties

    private let type: CameraType
    private let style: CameraButton.Style
    private let recordingProgress: CGFloat
    private let action: () -> Void
    @Binding private var isRecording: Bool

    // MARK: Life cycle

    public init(type: CameraType = .photo,
                style: CameraButton.Style = .classic,
                isRecording: Binding<Bool> = .constant(false),
                recordingProgress: CGFloat = 0,
                action: @escaping () -> Void = {}) {
        self.type = type
        self.style = style
        self._isRecording = isRecording
        self.recordingProgress = recordingProgress
        self.action = action
    }

    // MARK: UIViewRepresentable

    public func makeUIView(context: Context) -> CameraButton {
        let button = CameraButton()
        button.delegate = context.coordinator
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)

        return button
    }

    public func updateUIView(_ button: CameraButton, context: Context) {
        context.coordinator.parent = self
        button.style = style
        if button.type != type {
            button.type = type
        }
        if type == .video, button.isSelected != isRecording {
            button.isSelected = isRecording
        }
        if recordingProgress != button.recordingProgress {
            button.recordingProgress = recordingProgress
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: Coordinator

    public final class Coordinator: CameraButtonDelegate {

        fileprivate var parent: CameraShutterButton

        fileprivate init(parent: CameraShutterButton) {
            self.parent = parent
        }

        public func didTapButton(_ button: CameraButton) {
            if button.type == .video {
                parent.isRecording = button.isSelected
            }
            parent.action()
        }
    }

}
