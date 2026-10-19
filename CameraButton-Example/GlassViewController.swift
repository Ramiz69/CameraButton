//
//  GlassViewController.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import UIKit
import SwiftUI
import CameraButton

final class GlassViewController: UIViewController {

    // MARK: Properties

    private let maxRecordingDuration: TimeInterval = 10

    private lazy var cameraButton: CameraButton = {
        let button = CameraButton()
        button.style = .glass
        button.delegate = self
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Camera", "Video"])
        control.selectedSegmentIndex = .zero
        control.addAction(UIAction { [unowned self] _ in
            self.cameraButton.type = CameraType(withValue: control.selectedSegmentIndex)
        }, for: .valueChanged)

        return control
    }()

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = segmentedControl
        configureBackground()
        configureLayout()
    }

    // MARK: Private methods

    private func configureBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.systemPink, .systemOrange, .systemTeal].map(\.cgColor)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        let background = GradientView(gradient: gradient)
        background.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(background)
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureLayout() {
        let uiKitLabel = makeCaption("UIKit · CameraButton")
        let swiftUILabel = makeCaption("SwiftUI · CameraShutterButton")
        let hosting = UIHostingController(rootView: SwiftUIDemo())
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hosting)

        let stack = UIStackView(arrangedSubviews: [uiKitLabel, cameraButton, swiftUILabel, hosting.view])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.setCustomSpacing(56, after: cameraButton)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        hosting.didMove(toParent: self)

        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 76),
            cameraButton.heightAnchor.constraint(equalToConstant: 76),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func makeCaption(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .white

        return label
    }

}

// MARK: - CameraButtonDelegate

extension GlassViewController: CameraButtonDelegate {

    func didTapButton(_ button: CameraButton) {
        guard button.type == .video, button.isSelected else { return }

        button.animateRecordingProgress(duration: maxRecordingDuration)
    }

}

// MARK: - SwiftUI demo

private struct SwiftUIDemo: View {

    @State private var isRecording = false
    @State private var takenPhotos = 0

    var body: some View {
        HStack(spacing: 40) {
            VStack(spacing: 8) {
                CameraShutterButton(type: .photo, style: .glass) {
                    takenPhotos += 1
                }
                .frame(width: 64, height: 64)
                Text("Photos: \(takenPhotos)")
            }
            VStack(spacing: 8) {
                CameraShutterButton(type: .video, style: .glass, isRecording: $isRecording)
                    .frame(width: 64, height: 64)
                Text(isRecording ? "Recording" : "Idle")
            }
        }
        .font(.footnote)
        .foregroundStyle(.white)
    }

}

// MARK: - GradientView

private final class GradientView: UIView {

    private let gradient: CAGradientLayer

    init(gradient: CAGradientLayer) {
        self.gradient = gradient
        super.init(frame: .zero)

        layer.addSublayer(gradient)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = bounds
    }

}
