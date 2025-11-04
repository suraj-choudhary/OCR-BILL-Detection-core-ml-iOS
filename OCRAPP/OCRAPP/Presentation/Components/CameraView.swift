//
//  CameraView.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import Foundation
import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreview {
        let view = CameraPreview()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: CameraPreview, context: Context) {
        uiView.videoPreviewLayer.frame = uiView.bounds
    }
}

final class CameraPreview: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
    }
}
