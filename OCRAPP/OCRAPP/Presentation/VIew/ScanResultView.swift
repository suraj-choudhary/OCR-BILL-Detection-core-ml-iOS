//
//  ScanResultView.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import SwiftUI

struct ScanResultView: View {
    @ObservedObject var vm: ScanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                if let processed = vm.preprocessedImage {
                    Image(uiImage: processed)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                }

                if let bill = vm.billData {
                    BillDataCardView(bill: bill)   // ✅ Show Card Here
                } else {
                    Text("No structured data detected.")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.top)
        .navigationTitle("Scan Result")
    }
}

