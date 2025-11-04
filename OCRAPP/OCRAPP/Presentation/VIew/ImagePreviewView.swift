//
//  ImagePreviewView.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import SwiftUI
struct ImagePreviewView: View {
    let image: UIImage
    @StateObject private var scanVM = ScanViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .cornerRadius(12)
                
                Button(action: {
                    scanVM.inputImage = image
                    scanVM.runFullPipeline()
                }) {
                    if scanVM.isScanning {
                        ProgressView()
                            .padding()
                    } else {
                        Text("Run OCR")
                            .font(.headline)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding(.horizontal)
                
                if let bill = scanVM.billData {
                    BillDataCardView(bill: bill)
                        .padding(.top, 10)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
}
