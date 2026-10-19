//
//  PlaygroundView.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import SwiftUI
import CameraButton

/// Live editor for every `CameraButton` property, with the matching Swift code.
struct PlaygroundView: View {

    // MARK: Properties

    @Bindable var configuration: ButtonConfiguration
    let type: CameraType
    @Environment(\.dismiss) private var dismiss
    @State private var didCopy = false

    // MARK: Body

    var body: some View {
        NavigationStack {
            Form {
                Section("Style") {
                    Picker("Style", selection: $configuration.style) {
                        Text("Glass").tag(CameraButton.Style.glass)
                        Text("Classic").tag(CameraButton.Style.classic)
                    }
                    .pickerStyle(.segmented)
                    if configuration.style == .glass {
                        OptionalColorRow(title: "Glass tint", color: $configuration.glassTint, fallback: .blue.opacity(0.3))
                    }
                }

                Section("Colors") {
                    OptionalColorRow(title: "Photo fill", color: $configuration.photoColor, fallback: .white)
                    OptionalColorRow(title: "Video fill", color: $configuration.videoColor, fallback: .red)
                    ColorPicker("Ring", selection: $configuration.ringColor)
                    ColorPicker("Recording progress", selection: $configuration.progressColor)
                }

                Section("Ring") {
                    LabeledSlider(title: "Line width", value: $configuration.ringLineWidth, range: 1...8)
                    LabeledSlider(title: "Offset", value: $configuration.ringOffset, range: 0...8)
                }

                Section("Behavior") {
                    Toggle("Haptic feedback", isOn: $configuration.isHapticFeedbackEnabled)
                    Stepper(value: $configuration.maxRecordingDuration, in: 5...60, step: 5) {
                        LabeledContent("Max video length",
                                       value: Duration.seconds(configuration.maxRecordingDuration),
                                       format: .time(pattern: .minuteSecond))
                    }
                }

                Section {
                    Text(configuration.snippet(for: type))
                        .font(.caption.monospaced())
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button(didCopy ? "Copied" : "Copy Code", systemImage: didCopy ? "checkmark" : "doc.on.doc") {
                        UIPasteboard.general.string = configuration.snippet(for: type)
                        didCopy = true
                    }
                } header: {
                    Text("\(configuration.framework.rawValue) code")
                }
            }
            .navigationTitle("Playground")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        configuration.reset()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onChange(of: configuration.snippet(for: type)) {
                didCopy = false
            }
        }
    }

}

// MARK: - Rows

private struct OptionalColorRow: View {

    let title: LocalizedStringKey
    @Binding var color: Color?
    let fallback: Color

    var body: some View {
        Toggle(isOn: Binding(get: { color != nil },
                             set: { color = $0 ? fallback : nil })) {
            HStack {
                Text(title)
                Spacer()
                if color != nil {
                    ColorPicker(title, selection: Binding(get: { color ?? fallback },
                                                          set: { color = $0 }))
                        .labelsHidden()
                }
            }
        }
    }

}

private struct LabeledSlider: View {

    let title: LocalizedStringKey
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>

    var body: some View {
        VStack(alignment: .leading) {
            LabeledContent(title, value: value, format: .number.precision(.fractionLength(1)))
            Slider(value: $value, in: range, step: 0.5)
        }
    }

}
