//
//  File.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import Foundation
import CoreGraphics

struct BillData {
    var merchantName: String?
    var invoiceNumber: String?
    var date: String?
    var time: String? 
    var totalAmount: String?
    var currency: String?
    var rawText: String
    var confidence: Double
    var billNumber: String?
}
