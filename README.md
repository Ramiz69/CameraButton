# CameraButton

[![Build Status](https://github.com/Ramiz69/CameraButton/workflows/Camera%20Button%20CI/badge.svg?branch=master)](https://github.com/Ramiz69/CameraButton/actions)
[![Version](https://img.shields.io/cocoapods/v/RKCameraButton.svg?style=flat)](https://cocoapods.org/pods/RKCameraButton)
[![License](https://img.shields.io/cocoapods/l/RKCameraButton.svg?style=flat)](https://cocoapods.org/pods/RKCameraButton)
[![Platform](https://img.shields.io/cocoapods/p/RKCameraButton.svg?style=flat)](https://cocoapods.org/pods/RKCameraButton)
[![Swift](https://img.shields.io/badge/swift-5.9-orange.svg)](https://swift.org)

- [Installation](#installation)
- [Author](#author)
- [License](#license)

## Requirements

- iOS 15.0+
- Xcode 16.0+
- Swift 5+

## Preview
<img src="https://github.com/Ramiz69/CameraButton/blob/master/example.gif" width="200" height="400">

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Slider as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

```swift
dependencies: [
    .package(url: "https://github.com/Ramiz69/CameraButton.git", .upToNextMajor(from: "0.0.4"))
]
```

Normally you'll want to depend on the `CameraButton` target:

```swift
.product(name: "CameraButton", package: "CameraButton")
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate CameraButton into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'RKCameraButton'
```

### Manually
copy `CameraButton.swift` to your project

### Usage

#### code
- init CameraButton with frame or use Auto Layout
- add a button to your view

#### storyboard
- add a button to your view
- in the "Identity Inspector" in xCode, change the class to "CameraButton"
- add constraint for the placement of the button

## Author

ramiz69, ramiz161@icloud.com

## License

CameraButton is available under the MIT license. [See LICENSE](https://github.com/Ramiz69/CameraButton/blob/master/LICENSE) for details.
