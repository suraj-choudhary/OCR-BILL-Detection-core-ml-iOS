//
//  CameraManager.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import Foundation
import AVFoundation

class CameraManager: ObservableObject {
    @Published var currentPosition: CameraPosition = .back

    enum Status {
        case unconfigured
        case configured
        case unauthorized
        case failed
    }
    
    enum CameraPosition {
        case front
        case back
    }
    
    static let shared = CameraManager()
    
    @Published var error: CameraError?
    
    let session = AVCaptureSession()
    
    private let sessionQueue = DispatchQueue(label: "com.ocr.SessionQ")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var status = Status.unconfigured
    
    private init() {
        configure()
    }
    private func set(error: CameraError?) {
        DispatchQueue.main.async {
            self.error = error
        }
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if !authorized {
                    self.status = .unauthorized
                    self.set(error: .deniedAuthorization)
                }
                self.sessionQueue.resume()
            }
        case .restricted:
            status = .unauthorized
            set(error: .restrictedAuthorization)
        case .denied:
            status = .unauthorized
            set(error: .deniedAuthorization)
        case .authorized:
            break
        @unknown default:
            status = .unauthorized
            set(error: .unknownAuthorization)
        }
    }
    
    func start() {
        sessionQueue.async {
            if self.status == .unconfigured {
                self.configure()
            }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }
    
    private func configureCaptureSession() {
        guard status == .unconfigured else {
            return
        }
        session.beginConfiguration()
        
        defer {
            session.commitConfiguration()
        }
        let desiredPosition: AVCaptureDevice.Position =
            (currentPosition == .front) ? .front : .back

        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: desiredPosition)

        guard let camera = device else {
            set(error: .cameraUnavailable)
            self.status = .failed
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                set(error: .cannotAddInput)
                self.status = .failed
                return
            }
        } catch {
            set(error: .createCaptureInput(error))
            self.status = .failed
            return
        }
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            
            videoOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
        } else {
            set(error: .cannotAddOutput)
            self.status = .failed
            return
        }
        
        self.status = .configured
    }
    
    func stop() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    func configure() {
        checkPermissions()
        
        sessionQueue.async {
            if self.status == .unconfigured {
                self.configureCaptureSession()
            }
        }
    }

    func set(
        _ delegate: AVCaptureVideoDataOutputSampleBufferDelegate,
        queue: DispatchQueue
    ) {
        sessionQueue.async {
            self.videoOutput.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
    
    func switchCamera() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            if let input = self.session.inputs.first {
                self.session.removeInput(input)
            }
            
            self.currentPosition = (self.currentPosition == .front) ? .back : .front
            
            let newPosition: AVCaptureDevice.Position =
            (self.currentPosition == .front) ? .front : .back
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
                self.set(error: .cameraUnavailable)
                return
            }
            do {
                let newInput = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                }
            } catch {
                self.set(error: .createCaptureInput(error))
            }
            
            self.session.commitConfiguration()
        }
    }

}
