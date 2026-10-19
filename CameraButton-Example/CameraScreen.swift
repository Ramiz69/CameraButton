//
//  CameraScreen.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import SwiftUI
import CameraButton

struct CameraScreen: View {

    // MARK: Properties

    @State private var model = CameraModel()
    @State private var configuration = ButtonConfiguration()
    @State private var mode: CameraType = .photo
    @State private var isPlaygroundPresented = false
    @State private var previewedCapture: CameraModel.Capture?
    @State private var flashOpacity: Double = 0

    // MARK: Body

    var body: some View {
        ZStack {
            CameraBackground(model: model)
                .ignoresSafeArea()

            Color.white
                .opacity(flashOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                topBar
                Spacer()
                modePicker
                    .padding(.bottom, 20)
                bottomBar
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
        }
        .task {
            await model.start()
        }
        .onChange(of: model.flashCount) {
            flash()
        }
        .onChange(of: configuration.maxRecordingDuration, initial: true) { _, duration in
            model.maxRecordingDuration = duration
        }
        .sheet(isPresented: $isPlaygroundPresented) {
            PlaygroundView(configuration: configuration, type: mode)
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $previewedCapture) { capture in
            CapturePreview(capture: capture)
        }
    }

    // MARK: Subviews

    private var topBar: some View {
        HStack {
            Picker("Framework", selection: $configuration.framework) {
                ForEach(ButtonConfiguration.Framework.allCases) { framework in
                    Text(framework.rawValue).tag(framework)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 180)
            .disabled(model.isRecording)

            Spacer()

            if model.isRecording {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    RecordingTimer(start: model.recordingStart ?? .now, now: context.date)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.snappy, value: model.isRecording)
        .padding(.top, 8)
    }

    private var modePicker: some View {
        HStack(spacing: 4) {
            modeButton("Photo", type: .photo)
            modeButton("Video", type: .video)
        }
        .padding(4)
        .glassBackground(in: Capsule())
        .disabled(model.isRecording)
        .opacity(model.isRecording ? 0 : 1)
        .animation(.snappy, value: model.isRecording)
    }

    private func modeButton(_ title: LocalizedStringKey, type: CameraType) -> some View {
        Button {
            withAnimation(.snappy) {
                mode = type
            }
        } label: {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(mode == type ? Color.yellow : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    if mode == type {
                        Capsule().fill(.white.opacity(0.15))
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(mode == type ? .isSelected : [])
    }

    private var bottomBar: some View {
        HStack {
            thumbnail
            Spacer()
            TimelineView(.animation(paused: !model.isRecording)) { context in
                ShutterView(model: model,
                            configuration: configuration,
                            type: mode,
                            progress: model.recordingProgress(at: context.date))
            }
            .frame(width: 76, height: 76)
            Spacer()
            GlassIconButton(systemImage: "slider.horizontal.3", accessibilityLabel: "Playground") {
                isPlaygroundPresented = true
            }
            .frame(width: 56, height: 56)
            .disabled(model.isRecording)
        }
    }

    private var thumbnail: some View {
        Button {
            previewedCapture = model.lastCapture
        } label: {
            ZStack(alignment: .bottomTrailing) {
                if let capture = model.lastCapture {
                    Image(uiImage: capture.image)
                        .resizable()
                        .scaledToFill()
                        .id(capture.id)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                    if capture.videoDuration != nil {
                        Image(systemName: "video.fill")
                            .font(.caption2)
                            .foregroundStyle(.white)
                            .padding(4)
                    }
                } else {
                    Color.clear
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .glassBackground(in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .animation(.bouncy, value: model.lastCapture?.id)
        }
        .buttonStyle(.plain)
        .disabled(model.lastCapture == nil || model.isRecording)
        .accessibilityLabel("Last capture")
    }

    // MARK: Private methods

    private func flash() {
        flashOpacity = 0.85
        withAnimation(.easeOut(duration: 0.35)) {
            flashOpacity = 0
        }
    }

}

// MARK: - RecordingTimer

private struct RecordingTimer: View {

    let start: Date
    let now: Date

    var body: some View {
        let seconds = max(Int(now.timeIntervalSince(start)), 0)
        HStack(spacing: 6) {
            Circle()
                .fill(.red)
                .frame(width: 8, height: 8)
            Text(Duration.seconds(seconds), format: .time(pattern: .minuteSecond))
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .glassBackground(in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recording")
    }

}

// MARK: - CapturePreview

private struct CapturePreview: View {

    let capture: CameraModel.Capture
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Image(uiImage: capture.image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }

    private var title: String {
        guard let duration = capture.videoDuration else { return "Photo" }

        return "Video · " + Duration.seconds(Int(duration)).formatted(.time(pattern: .minuteSecond))
    }

}
