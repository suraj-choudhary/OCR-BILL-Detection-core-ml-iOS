//
//  OCRService.swift
//  OCRAPP
//
//  Created by suraj_kumar on 30/10/25.
//

import Foundation
import Vision
import UIKit

final class OCRService {
    
    func recoginzeText(from image: UIImage, completion: @escaping([RecognizedLine]) -> Void) {
        guard let image = image.cgImage else {
            completion([])
            return
        }
        let request = VNRecognizeTextRequest { req, error in
            
            guard let obj = req.results as? [VNRecognizedTextObservation] else {
                completion([])
                return
            }
            var lines = [RecognizedLine]()
            for object in obj {
                guard let candidate = object.topCandidates(1).first else {
                    continue
                }
                let req = VNImageRectForNormalizedRect(object.boundingBox, Int(image.width), Int(image.height))
                lines.append(RecognizedLine(text: candidate.string, boundingBox: req, confidence: candidate.confidence))
            }
            lines.sort { (a, b) -> Bool in
                return a.boundingBox.origin.y + a.boundingBox.height > b.boundingBox.origin.y + b.boundingBox.height
            }
            completion(lines)
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
}
