//
//  CameraButtonDelegate.swift
//  CameraButton
//
//  Created by Рамиз Кичибеков on 06.01.2025.
//  Copyright © 2025 Ramiz Kichibekov. All rights reserved.
//

import UIKit

@MainActor
public protocol CameraButtonDelegate: AnyObject, Sendable {
    func didTapDownButton(_ button: CameraButton)
    func didTapButton(_ button: CameraButton)
    func didTapCancelButton(_ button: CameraButton)
}

public extension CameraButtonDelegate {
    func didTapDownButton(_ button: CameraButton) {}
    func didTapButton(_ button: CameraButton) {}
    func didTapCancelButton(_ button: CameraButton) {}
}
