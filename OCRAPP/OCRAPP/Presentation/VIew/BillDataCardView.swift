//
//  File.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import SwiftUI

struct BillDataCardView: View {
    let bill: BillData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(bill.merchantName ?? "Unknown Merchant")
                .font(.title3.bold())
            
            if let number = bill.billNumber {
                row(label: "Bill Number", value: number)
            }
            if let date = bill.date {
                row(label: "Date", value: date)
            }
            if let time = bill.time {
                row(label: "Time", value: time)
            }
            if let total = bill.totalAmount {
                row(label: "Total Amount", value: total)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(14)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
    
    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
        .font(.system(size: 16))
    }
}
