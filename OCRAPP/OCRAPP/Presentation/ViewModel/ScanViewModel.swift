//
//  ScanViewModel.swift
//  OCRAPP
//
//  Created by suraj_kumar on 29/10/25.
//

import SwiftUI
import Combine
import Vision

final class ScanViewModel: ObservableObject {
    @Published var inputImage: UIImage?
    @Published var preprocessedImage: UIImage?
    @Published var rawLines: [RecognizedLine] = []
    
    @Published var isScanning = false
    @Published var billData: BillData?
    
    private let processor = ImageProcessor.shared
    private let ocr = OCRService()
    private let extractor = TextExtractor()
    
    func runFullPipeline() {
        guard let img = inputImage else { return }
        isScanning = true
        
        self.ocr.recoginzeText(from: img) { [weak self] recognizedLines in
            guard let self = self else { return }
            
            let correctedLines = recognizedLines.map { line in
                let corrected = self.applyCorrections(on: line.text, conf: line.confidence)
                return RecognizedLine(
                    text: corrected,
                    boundingBox: line.boundingBox,
                    confidence: line.confidence
                )
            }
            
            let extractedBill = self.extractor.extract(from: correctedLines)
            
            DispatchQueue.main.async {
                self.rawLines = correctedLines
                self.billData = extractedBill
                self.isScanning = false
            }
        }

    }
    
    // Optional OCR correction layer
    private func applyCorrections(on line: String, conf: VNConfidence) -> String {
        let corr = OCRCorrectionLayer()
        return corr.correctLine(line, confidence: conf)
    }
}
