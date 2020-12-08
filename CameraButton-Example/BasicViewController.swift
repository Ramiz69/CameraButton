//
//  BasicViewController.swift
//  CameraButton-Example
//
//  Created by Рамиз Кичибеков on 26/09/2019.
//  Copyright © 2019 Ramiz Kichibekov. All rights reserved.
//

import UIKit
import CameraButton

final class BasicViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak private var cameraButton: CameraButton!
    
    // MARK: - Custom methods
    // MARK: - Actions
    
    @IBAction private func didChangeSegment(_ sender: UISegmentedControl) {
        cameraButton.type = CameraType(withValue: sender.selectedSegmentIndex)
    }
    
}
