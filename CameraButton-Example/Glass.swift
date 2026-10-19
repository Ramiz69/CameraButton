//
//  Glass.swift
//  CameraButton-Example
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import SwiftUI

extension View {

    /// Liquid Glass on iOS 26 and later, a material on earlier systems.
    @ViewBuilder
    func glassBackground<S: Shape>(in shape: S, interactive: Bool = false) -> some View {
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            glassEffect(interactive ? .regular.interactive() : .regular, in: shape)
        } else {
            background(.ultraThinMaterial, in: shape)
        }
        #else
        background(.ultraThinMaterial, in: shape)
        #endif
    }

}

/// Round glass button with an SF Symbol.
struct GlassIconButton: View {

    let systemImage: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassBackground(in: Circle(), interactive: true)
        .accessibilityLabel(accessibilityLabel)
    }

}
