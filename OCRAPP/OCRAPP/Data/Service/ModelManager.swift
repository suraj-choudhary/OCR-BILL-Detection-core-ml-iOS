//
//  File.swift
//  OCRAPP
//
//  Created by suraj_kumar on 04/11/25.
//

import Foundation
import CoreML

final class ModelManager {
    static let shared = ModelManager()
    let classifier: InvoiceFieldClassifier?

    private init() {
        do {
            self.classifier = try InvoiceFieldClassifier(configuration: MLModelConfiguration())
        } catch {
            print("Failed to load model: \(error)")
            self.classifier = nil
        }
    }

    /// Classify a single text line. Returns the predicted label or "other".
    func classify(line: String) -> String {
        guard let model = classifier else { return "other" }
        do {
            let pred = try model.prediction(text: line)
            return pred.label
        } catch {
            print("Model prediction failed: \(error)")
            return "other"
        }
    }
}
