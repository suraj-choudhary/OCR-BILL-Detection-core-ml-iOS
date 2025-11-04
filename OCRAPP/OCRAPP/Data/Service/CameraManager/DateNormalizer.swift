//
//  File.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import Foundation

class DateNormalizer {
    static let shared = DateNormalizer()
    private init() {}
    
    // Candidate date formats in order (extend as needed)
    private let dateFormats = [
        "dd/MM/yy", "dd/MM/yyyy", "MM/dd/yy", "MM/dd/yyyy",
        "yyyy-MM-dd", "dd-MM-yyyy", "dd MMM yyyy", "MMM dd yyyy",
        "d MMM yyyy", "dd.MM.yyyy", "yyyy.MM.dd"
    ]
    
    func parseAnyDate(from text: String) -> Date? {
        let cleaned = text.replacingOccurrences(of: ",", with: " ")
        let tokens = cleaned.components(separatedBy: " ")
        // try direct parse with multiple formatters
        for format in dateFormats {
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.dateFormat = format
            if let d = fmt.date(from: text) { return d }
            // Try tokens joined
            for t in tokens {
                if let d = fmt.date(from: t) { return d }
            }
        }
        // try flexible parser using NSDataDetector
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) {
            let matches = detector.matches(in: text, options: [], range: NSRange(location:0, length:text.utf16.count))
            if let m = matches.first, let d = m.date {
                return d
            }
        }
        return nil
    }
    
    func normalizeTo_dd_MMM_yyyy(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "dd-MMM-yyyy"
        return fmt.string(from: date)
    }
    
    func parseAndFormat(_ input: String) -> String? {
        if let d = parseAnyDate(from: input) {
            return normalizeTo_dd_MMM_yyyy(d)
        }
        return nil
    }
    
    // Time parse
    func parseTime(_ input: String) -> String? {
        // try patterns
        let patterns = ["HH:mm", "hh:mm a", "H:mm", "hh:mma", "h:mm a"]
        for p in patterns {
            let fmt = DateFormatter(); fmt.locale = Locale(identifier: "en_US_POSIX"); fmt.dateFormat = p
            if let d = fmt.date(from: input) {
                let out = DateFormatter(); out.locale = Locale(identifier: "en_US_POSIX"); out.dateFormat = "HH:mm"
                return out.string(from: d)
            }
        }
        // try NSDataDetector for date/time
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) {
            let matches = detector.matches(in: input, options: [], range: NSRange(location:0, length:input.utf16.count))
            if let m = matches.first, let d = m.date {
                let out = DateFormatter(); out.locale = Locale(identifier: "en_US_POSIX"); out.dateFormat = "HH:mm"
                return out.string(from: d)
            }
        }
        return nil
    }
}
