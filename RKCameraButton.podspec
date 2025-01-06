Pod::Spec.new do |spec|

  spec.name         = 'RKCameraButton'
  spec.version      = '0.0.4'
  spec.summary      = 'A CocoaPods library written in Swift'

  spec.description  = <<-DESC
This CocoaPods library helps you create application with the best button.
                   DESC

  spec.homepage     = 'https://github.com/Ramiz69/CameraButton'

  spec.license      = 'MIT'

  spec.author             = { 'Ramiz Kichibekov' => 'ramiz161@icloud.com' }
  spec.social_media_url   = 'https://instagram.com/kichibekov69'

  spec.ios.deployment_target = "15.0"

  spec.source       = { :git => 'https://github.com/Ramiz69/CameraButton.git', :tag => spec.version }

  spec.swift_version = ['6.0']
  
  spec.source_files  = 'CameraButton/*.swift'

end
