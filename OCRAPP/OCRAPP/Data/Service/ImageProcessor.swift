//
//  ImageProcessor.swift
//  OCRAPP
//
//  Created by suraj_kumar on 29/10/25.
//

import Foundation
import UIKit
import Vision

class ImageProcessor {
    private let ciContext = CIContext()
    
    static let shared = ImageProcessor()
    private init() {}
    
    func detectDocument(in uiImage: UIImage, completionHandler: @escaping(VNRectangleObservation?) -> Void) {
        
        guard let cgImage = uiImage.cgImage else {
            completionHandler(nil)
            return
        }
        let request = VNDetectRectanglesRequest { req, err in
            guard let obs = req.results as? [VNRectangleObservation], !obs.isEmpty else {
                completionHandler(nil)
                return
            }
            let sorted = obs.sorted { a, b in
                return a.boundingBox.width * a.boundingBox.height > b.boundingBox.width * b.boundingBox.height
                
            }
            completionHandler(sorted.first)
        }
        request.minimumAspectRatio = 0.3
        request.maximumObservations = 5
        request.minimumSize = 0.2
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
    }
    
    
    func perspectiveCorrect(image: UIImage, rectangle: VNRectangleObservation) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        func point(_ normalized: CGPoint) -> CGPoint {
            return CGPoint(x: normalized.x * ciImage.extent.width, y: (1 - normalized.y) * ciImage.extent.height)
        }
        let topLeft = point(rectangle.topLeft)
        let topRight = point(rectangle.topRight)
        let bottomLeft = point(rectangle.bottomLeft)
        let bottomRight = point(rectangle.bottomRight)
        
        let filter = CIFilter(name: "CIPerspectiveCorrection")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgPoint: topLeft), forKey: "inputTopLeft")
        filter.setValue(CIVector(cgPoint: topRight), forKey: "inputTopRight")
        filter.setValue(CIVector(cgPoint: bottomLeft), forKey: "inputBottomLeft")
        filter.setValue(CIVector(cgPoint: bottomRight), forKey: "inputBottomRight")
        guard let output = filter.outputImage else { return nil }
        guard let outCG = ciContext.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: outCG)
    }
    
    func enhance(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        var ciImage = CIImage(cgImage: cgImage)
        let adjustments = ciImage.autoAdjustmentFilters()
        for f in adjustments {
            f.setValue(ciImage, forKey: kCIInputImageKey)
            if let out = f.outputImage { ciImage = out }
        }
        if let sharpen = CIFilter(name: "CISharpenLuminance") {
            sharpen.setValue(ciImage, forKey: kCIInputImageKey)
            sharpen.setValue(0.6, forKey: kCIInputSharpnessKey)
            if let out = sharpen.outputImage { ciImage = out }
        }
        guard let outCG = ciContext.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: outCG)
    }
    
    func preprocessForOCR(_ image: UIImage, completion: @escaping (UIImage) -> Void) {
        detectDocument(in: image) { [weak self] rect in
            var processed = image
            if let rect = rect, let corrected = self?.perspectiveCorrect(
                image: image,
                rectangle: rect
            ) {
                processed = corrected
            }
            if let enhanced = self?.enhance(
                image: processed
            ) {
                processed = enhanced
            }
            completion(
                processed
            )
        }
    }
}
