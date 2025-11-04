//
//  File.swift
//  OCRAPP
//
//  Created by suraj_kumar on 30/10/25.
//

import Foundation
import CoreGraphics
import Vision
import CoreML

struct RecognizedLine {
    let text: String
    let boundingBox: CGRect
    let confidence: VNConfidence
}

