//
//  ButtonConfiguration.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import SwiftUI
import CameraButton

/// Every tweakable `CameraButton` property, edited live in the playground sheet.
@MainActor
@Observable
final class ButtonConfiguration {

    enum Framework: String, CaseIterable, Identifiable {
        case swiftUI = "SwiftUI"
        case uiKit = "UIKit"

        var id: Self { self }
    }

    // MARK: Properties

    var framework: Framework = .swiftUI
    var style: CameraButton.Style = .glass
    var glassTint: Color?
    var photoColor: Color?
    var videoColor: Color?
    var ringColor: Color = .white
    var progressColor: Color = .red
    var ringLineWidth: CGFloat = 4
    var ringOffset: CGFloat = 3
    var isHapticFeedbackEnabled = true
    var maxRecordingDuration: TimeInterval = 15

    // MARK: Public methods

    func apply(to button: CameraButton) {
        button.glassTintColor = glassTint.map(UIColor.init)
        button.photoColor = photoColor.map(UIColor.init) ?? .clear
        button.videoColor = videoColor.map(UIColor.init) ?? .clear
        button.ringColor = UIColor(ringColor)
        button.progressColor = UIColor(progressColor)
        button.ringLineWidth = ringLineWidth
        button.ringOffset = ringOffset
        button.isHapticFeedbackEnabled = isHapticFeedbackEnabled
    }

    func reset() {
        let defaults = ButtonConfiguration()
        style = defaults.style
        glassTint = defaults.glassTint
        photoColor = defaults.photoColor
        videoColor = defaults.videoColor
        ringColor = defaults.ringColor
        progressColor = defaults.progressColor
        ringLineWidth = defaults.ringLineWidth
        ringOffset = defaults.ringOffset
        isHapticFeedbackEnabled = defaults.isHapticFeedbackEnabled
        maxRecordingDuration = defaults.maxRecordingDuration
    }

    /// Swift code that reproduces the current configuration.
    func snippet(for type: CameraType) -> String {
        let properties = changedProperties()
        switch framework {
        case .uiKit:
            var lines = ["let button = CameraButton()",
                         "button.type = \(type == .photo ? ".photo" : ".video")",
                         "button.style = \(style == .glass ? ".glass" : ".classic")"]
            lines += properties.map { "button.\($0) = \($1)" }
            lines.append("button.delegate = self")

            return lines.joined(separator: "\n")
        case .swiftUI:
            let styleLine = "style: \(style == .glass ? ".glass" : ".classic")"
            var lines = type == .photo
                ? ["CameraShutterButton(type: .photo, \(styleLine)) {",
                   "    camera.capturePhoto()"]
                : ["CameraShutterButton(type: .video,",
                   "                    \(styleLine),",
                   "                    isRecording: $isRecording) {",
                   "    isRecording ? recorder.start() : recorder.stop()"]
            if properties.isEmpty {
                lines.append("}")
            } else {
                lines.append("} configure: { button in")
                lines += properties.map { "    button.\($0) = \($1)" }
                lines.append("}")
            }
            lines.append(".frame(width: 76, height: 76)")

            return lines.joined(separator: "\n")
        }
    }

    // MARK: Private methods

    private func changedProperties() -> [(String, String)] {
        let defaults = ButtonConfiguration()
        var result: [(String, String)] = []
        if let glassTint { result.append(("glassTintColor", glassTint.swiftLiteral)) }
        if let photoColor { result.append(("photoColor", photoColor.swiftLiteral)) }
        if let videoColor { result.append(("videoColor", videoColor.swiftLiteral)) }
        if ringColor != defaults.ringColor { result.append(("ringColor", ringColor.swiftLiteral)) }
        if progressColor != defaults.progressColor { result.append(("progressColor", progressColor.swiftLiteral)) }
        if ringLineWidth != defaults.ringLineWidth { result.append(("ringLineWidth", ringLineWidth.formatted())) }
        if ringOffset != defaults.ringOffset { result.append(("ringOffset", ringOffset.formatted())) }
        if !isHapticFeedbackEnabled { result.append(("isHapticFeedbackEnabled", "false")) }

        return result
    }

}

private extension Color {

    var swiftLiteral: String {
        let resolved = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let components = [red, green, blue].map { String(format: "%.2f", $0) }
        let alphaPart = alpha < 1 ? String(format: ", alpha: %.2f", alpha) : ", alpha: 1"

        return "UIColor(red: \(components[0]), green: \(components[1]), blue: \(components[2])\(alphaPart))"
    }

}
