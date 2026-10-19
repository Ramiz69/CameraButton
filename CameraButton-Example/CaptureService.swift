//
//  CaptureService.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import AVFoundation
import UIKit

/// Minimal photo capture pipeline. All session work runs on a private serial queue.
final class CaptureService: NSObject, @unchecked Sendable {

    // MARK: Properties

    let session = AVCaptureSession()

    private let queue = DispatchQueue(label: "CameraButtonExample.capture")
    private let photoOutput = AVCapturePhotoOutput()
    private var photoContinuation: CheckedContinuation<UIImage?, Never>?

    // MARK: Public methods

    static func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: true
        case .notDetermined: await AVCaptureDevice.requestAccess(for: .video)
        default: false
        }
    }

    /// Configures the back camera. Returns `false` when there is no camera, e.g. in the Simulator.
    func configure() async -> Bool {
        await withCheckedContinuation { continuation in
            queue.async {
                guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                      let input = try? AVCaptureDeviceInput(device: device) else {
                    continuation.resume(returning: false)
                    return
                }

                self.session.beginConfiguration()
                self.session.sessionPreset = .photo
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                }
                self.session.commitConfiguration()
                self.session.startRunning()
                continuation.resume(returning: true)
            }
        }
    }

    func stop() {
        queue.async {
            self.session.stopRunning()
        }
    }

    func capturePhoto() async -> UIImage? {
        await withCheckedContinuation { continuation in
            queue.async {
                guard self.session.isRunning, self.photoContinuation == nil else {
                    continuation.resume(returning: nil)
                    return
                }

                self.photoContinuation = continuation
                self.photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            }
        }
    }

}

// MARK: - AVCapturePhotoCaptureDelegate

extension CaptureService: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        let image = photo.fileDataRepresentation().flatMap(UIImage.init(data:))
        queue.async {
            self.photoContinuation?.resume(returning: image)
            self.photoContinuation = nil
        }
    }

}
