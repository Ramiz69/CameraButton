//
//  CustomViewController.swift
//  CameraButton-Example
//
//  Created by Рамиз Кичибеков on 12/08/2020.
//  Copyright © 2020 Ramiz Kichibekov. All rights reserved.
//

import UIKit
import CameraButton

final class CustomViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var cameraButton: CameraButton = {
        let frame = CGRect(x: .zero, y: .zero, width: 60, height: 60)
        let button = CameraButton(frame: frame)
        button.photoColor = .black
        button.videoColor = .orange
        button.center = view.center
        
        return button
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(cameraButton)
    }
    
    // MARK: - Custom methods
    // MARK: - Actions
    
    @IBAction private func didChangeSegment(_ sender: UISegmentedControl) {
        cameraButton.type = CameraType(withValue: sender.selectedSegmentIndex)
    }
    
}
