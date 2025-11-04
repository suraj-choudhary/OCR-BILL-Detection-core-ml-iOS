//
//  CameraViewModel.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import Combine
import CoreImage
import Foundation

class CameraViewModel: ObservableObject {
    @Published var frame: CGImage?
    
    private let context = CIContext()
    private let camera = CameraManager.shared
    private let frameManager = FrameManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
    }
    
    func setupSubscriptions() {
        frameManager.$current
            .compactMap { buffer in
                guard let image = CGImage.create(from: buffer) else { return nil }
                let ci = CIImage(cgImage: image)
                return self.context.createCGImage(ci, from: ci.extent)
            }
            .receive(on: RunLoop.main)
            .assign(to: &$frame)
    }
    
    func startCamera() {
        camera.start()
    }

    func stopCamera() {
        camera.stop()
    }
}
