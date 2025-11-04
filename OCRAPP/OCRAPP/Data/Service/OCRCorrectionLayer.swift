//
//  OCRCorrectionLayer.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import Foundation
import Foundation

class OCRCorrectionLayer {

    private let currencySubstitutions: [String: String] = [
        "rs.": "₹", "rs": "₹", "inr": "₹"
    ]

    /// Corrects a single token based on context
    func correct(token: String, confidence: Float) -> String {
        var t = token.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) Normalize currency only if near numbers
        let lower = t.lowercased()
        for (k, v) in currencySubstitutions {
            if lower.contains(k) {
                // Only replace if token contains digits or will be paired with digits later
                if t.contains(where: { $0.isNumber }) || confidence > 0.80 {
                    t = t.replacingOccurrences(of: k, with: v, options: .caseInsensitive)
                }
            }
        }

        // 2) Fix digit misreads **only if token is predominantly numeric**
        if looksNumeric(t) {
            t = t
                .replacingOccurrences(of: "O", with: "0")
                .replacingOccurrences(of: "o", with: "0")
                .replacingOccurrences(of: "I", with: "1")
                .replacingOccurrences(of: "l", with: "1")
                .replacingOccurrences(of: "S", with: "5")
        }

        return t
    }

    /// Fix entire line safely
    func correctLine(_ line: String, confidence: Float) -> String {
        line.split(separator: " ").map {
            correct(token: String($0), confidence: confidence)
        }.joined(separator: " ")
    }

    /// Detect if token is amount-like or numeric-heavy
    private func looksNumeric(_ s: String) -> Bool {
        let digitCount = s.filter(\.isNumber).count
        return digitCount >= max(1, s.count / 2) // more than half digits → treat as numeric
    }
}
