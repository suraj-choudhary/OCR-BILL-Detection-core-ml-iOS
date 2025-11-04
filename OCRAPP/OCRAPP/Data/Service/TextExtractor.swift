//
//  TextRecognizer.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

//
//  TextExtractor.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import Foundation
import NaturalLanguage

class TextExtractor {
    
    // common keywords used for fallback extraction
    private let invoiceKeywords = ["invoice", "invoice no", "bill no", "bill #", "receipt id", "txn id", "receipt no", "inv"]
    
    private let totalKeywords = ["total", "grand total", "amount paid", "net payable", "balance due", "total amount"]
    
    private let dateKeywords = ["date", "transaction date", "invoice date", "bill date"]
    
    private let timeKeywords = ["time", "transaction time"]
    
    func extract(from lines: [RecognizedLine]) -> BillData {
        
        let raw = lines.map { $0.text }.joined(separator: "\n")
        
        var bill = BillData(
            merchantName: nil,
            invoiceNumber: nil,
            date: nil,
            time: nil,
            totalAmount: nil,
            currency: nil,
            rawText: raw,
            confidence: 0.0,
            billNumber: nil
        )
        
        for line in lines {
            let text = line.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let label = ModelManager.shared.classify(line: text).lowercased()
            
            switch label {
                
            case "merchant_name":
                if bill.merchantName == nil {
                    bill.merchantName = text
                }
                
            case "invoice_number", "bill_number", "receipt_number":
                if bill.invoiceNumber == nil {
                    bill.invoiceNumber = extractInvoiceNumber(from: text)
                }
                
            case "total_amount":
                if bill.totalAmount == nil {
                    if let amt = extractStrictAmount(from: text) {
                        bill.totalAmount = amt
                        bill.currency = detectCurrency(in: amt)
                    }
                }
                
            case "date":
                if bill.date == nil,
                   let parsed = DateNormalizer.shared.parseAnyDate(from: text) {
                    bill.date = DateNormalizer.shared.normalizeTo_dd_MMM_yyyy(parsed)
                }

            case "time":
                if bill.time == nil,
                   let parsed = DateNormalizer.shared.parseTime(text) {
                    bill.time = parsed
                }

            default:
                continue
            }
        }
        
        // --- FALLBACKS ---
        
        // invoice number via keywords
        if bill.invoiceNumber == nil {
            bill.invoiceNumber = findInvoiceViaKeywords(lines: lines)
        }
        
        // total amount fallback
        if bill.totalAmount == nil {
            if let amt = firstMatch(in: raw,
                patterns: ["[₹Rs\\$€]\\s*[\\d,]+\\.?\\d{0,2}", "\\b[\\d,]+\\.?\\d{2}\\b"]) {
                bill.totalAmount = amt
                bill.currency = detectCurrency(in: amt)
            }
        }
        
        // date fallback
        if bill.date == nil {
            if let match = firstMatch(in: raw, patterns: dateRegexes()),
               let parsed = DateNormalizer.shared.parseAnyDate(from: match) {
                bill.date = DateNormalizer.shared.normalizeTo_dd_MMM_yyyy(parsed)
            }
        }
        
        // time fallback
        if bill.time == nil {
            if let match = firstMatch(in: raw, patterns: ["\\b\\d{1,2}:\\d{2}\\b", "\\b\\d{1,2}:\\d{2}\\s*(AM|PM)\\b"]) {
                bill.time = DateNormalizer.shared.parseTime(match)
            }
        }

        // merchant name fallback → top line is usually merchant
        if bill.merchantName == nil {
            bill.merchantName = lines.first?.text
        }
        
        // confidence calculation
        bill.confidence = lines.map { Double($0.confidence) }.reduce(0, +) / Double(max(1, lines.count))
        
        return bill
    }

    // MARK: - Helpers
    
    private func firstMatch(in text: String, patterns: [String]) -> String? {
        for p in patterns {
            if let r = try? NSRegularExpression(pattern: p, options: [.caseInsensitive]) {
                if let m = r.firstMatch(in: text, options: [], range: NSRange(location:0, length:text.utf16.count)) {
                    return (text as NSString).substring(with: m.range)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return nil
    }
    
    private func dateRegexes() -> [String] {
        return [
            "\\b\\d{1,2}[\\-/]\\d{1,2}[\\-/]\\d{2,4}\\b",
            "\\b\\d{4}[\\-/]\\d{1,2}[\\-/]\\d{1,2}\\b",
            "\\b[A-Za-z]{3,9}\\s+\\d{1,2},?\\s*\\d{4}\\b"
        ]
    }
    
    private func extractInvoiceNumber(from text: String) -> String? {
        return firstMatch(in: text, patterns: ["[A-Za-z0-9-_/]+"])
    }
    
    private func findInvoiceViaKeywords(lines: [RecognizedLine]) -> String? {
        for line in lines {
            let lower = line.text.lowercased()
            for k in invoiceKeywords {
                if lower.contains(k) {
                    if let match = firstMatch(in: line.text, patterns: ["(?<=\(k)[:\\s-]*)([A-Za-z0-9-_/]+)"]) {
                        return match
                    }
                }
            }
        }
        return nil
    }
    
    private func extractStrictAmount(from text: String) -> String? {
        let patterns = [
            "[₹]\\s*[0-9,]+\\.?[0-9]{0,2}",
            "\\b[0-9,]+\\.?[0-9]{0,2}\\b"
        ]
        
        for p in patterns {
            if let r = try? NSRegularExpression(pattern: p, options: [.caseInsensitive]) {
                let matches = r.matches(in: text, options: [], range: NSRange(location:0, length:text.utf16.count))
                if let last = matches.last {
                    return (text as NSString).substring(with: last.range)
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return nil
    }

    private func detectCurrency(in text: String?) -> String? {
        guard let t = text else { return nil }
        if t.contains("₹") || t.lowercased().contains("rs") { return "INR" }
        if t.contains("$") { return "USD" }
        if t.contains("€") { return "EUR" }
        return nil
    }
}
