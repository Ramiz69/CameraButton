//
//  CameraModel.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import SwiftUI

/// Drives the demo camera: live preview on device, a simulated scene everywhere else.
@MainActor
@Observable
final class CameraModel {

    enum Source {
        case loading
        case live
        case simulated
        case denied
    }

    struct Capture: Identifiable {
        let id = UUID()
        let image: UIImage
        let videoDuration: TimeInterval?
    }

    // MARK: Properties

    let service = CaptureService()
    private(set) var source: Source = .loading
    private(set) var lastCapture: Capture?
    private(set) var flashCount = 0
    private(set) var recordingStart: Date?
    var isRecording = false {
        didSet {
            guard oldValue != isRecording else { return }

            isRecording ? startRecording() : stopRecording()
        }
    }
    var maxRecordingDuration: TimeInterval = 15

    private var autoStopTask: Task<Void, Never>?

    // MARK: Public methods

    func start() async {
        guard source == .loading else { return }

        #if targetEnvironment(simulator)
        source = .simulated
        #else
        guard await CaptureService.requestAccess() else {
            source = .denied
            return
        }

        source = await service.configure() ? .live : .simulated
        #endif
    }

    func capturePhoto() {
        flashCount += 1
        Task {
            if let image = await snapshot() {
                lastCapture = Capture(image: image, videoDuration: nil)
            }
        }
    }

    func recordingProgress(at date: Date) -> CGFloat {
        guard let recordingStart else { return 0 }

        return min(date.timeIntervalSince(recordingStart) / maxRecordingDuration, 1)
    }

    // MARK: Private methods

    private func startRecording() {
        let start = Date()
        recordingStart = start
        autoStopTask?.cancel()
        autoStopTask = Task { [maxRecordingDuration] in
            try? await Task.sleep(for: .seconds(maxRecordingDuration))
            guard !Task.isCancelled, recordingStart == start else { return }

            isRecording = false
        }
    }

    private func stopRecording() {
        autoStopTask?.cancel()
        guard let recordingStart else { return }

        let duration = Date().timeIntervalSince(recordingStart)
        self.recordingStart = nil
        Task {
            if let image = await snapshot() {
                lastCapture = Capture(image: image, videoDuration: duration)
            }
        }
    }

    private func snapshot() async -> UIImage? {
        switch source {
        case .live:
            return await service.capturePhoto()
        case .simulated, .denied, .loading:
            let renderer = ImageRenderer(content: SimulatedScene(date: .now).frame(width: 300, height: 400))
            renderer.scale = 2

            return renderer.uiImage
        }
    }

}
