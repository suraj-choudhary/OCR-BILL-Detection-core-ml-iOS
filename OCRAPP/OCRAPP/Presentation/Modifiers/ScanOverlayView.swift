//
//  ScanOverlayView.swift
//  OCRAPP
//
//  Created by suraj_kumar on 31/10/25.
//

import SwiftUI

struct ScanOverlayView: View {
    @State private var move = false
    
    var body: some View {
        GeometryReader { geo in
            let width: CGFloat = geo.size.width * 0.75
            let frameHeight: CGFloat = width * 1.2
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.green, lineWidth: 3)
                    .frame(width: width, height: frameHeight)
                
                Rectangle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: width * 0.9, height: 3)
                    .offset(y: move ? frameHeight/2 - 10 : -frameHeight/2 + 10)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: false), value: move)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { move = true }
        }
        .allowsHitTesting(false)
    }
}
