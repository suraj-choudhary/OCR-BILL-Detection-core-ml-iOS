//
//  HomeView.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import SwiftUI
import PhotosUI

import SwiftUI
import PhotosUI

struct HomeView: View {
    @State private var showScanner = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                
                Text("Smart OCR Scanner")
                    .font(.title.bold())
                    .padding(.bottom, 40)
                
                Button(action: { showScanner = true }) {
                    Text("Open Camera")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Select From Gallery")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.green)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .padding()

                    NavigationLink(destination: ImagePreviewView(image: selectedImage)) {
                        Text("Proceed")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 10)
                }
            }
            .padding()
        }
        .fullScreenCover(isPresented: $showScanner) {
            LiveScannerView { scannedImage in
                self.selectedImage = scannedImage
            }
        }
        .onChange(of: selectedPhoto) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
}
