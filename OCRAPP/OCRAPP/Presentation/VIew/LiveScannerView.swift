//
//  LiveScannerView.swift
//  OCRAPP
//
//  Created by suraj_kumar on 29/10/25.
//

import SwiftUI

struct LiveScannerView: View {
    @StateObject private var cameraVM = CameraViewModel()
    @StateObject private var scanVM = ScanViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onScanCompleted: (UIImage) -> Void
    
    var body: some View {
        ZStack {
            CameraView(session: CameraManager.shared.session)
                .ignoresSafeArea()
            ScanOverlayView()
            VStack {
                HStack {
                    Button(action: {
                        cameraVM.stopCamera()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
                
                Button(action: { scanCurrentFrame() }) {
                    Text("Scan")
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(radius: 4)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear { cameraVM.startCamera() }
        .onDisappear { cameraVM.stopCamera() }
    }
    
    private func scanCurrentFrame() {
        guard let frame = cameraVM.frame else {
            return
        }
        let scannedImage = UIImage(cgImage: frame)
        onScanCompleted(scannedImage)
        dismiss()
    }
}
