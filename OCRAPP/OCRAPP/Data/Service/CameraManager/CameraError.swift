//
//  CameraError.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//


import Foundation

enum CameraError: Error {
  case cameraUnavailable
  case cannotAddInput
  case cannotAddOutput
  case createCaptureInput(Error)
  case deniedAuthorization
  case restrictedAuthorization
  case unknownAuthorization
}

extension CameraError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "camera_unavailable"
        case .cannotAddInput:
            return "cannot_add_capture_input"
        case .cannotAddOutput:
            return "cannot_add_video_output"
        case .createCaptureInput(let error):
            return "creating_capture_input"
        case .deniedAuthorization:
            return "camera_access_denied"
        case .restrictedAuthorization:
            return "attempting_to_access"
        case .unknownAuthorization:
            return "Unknown_authorization_status"
        }
    }
}
