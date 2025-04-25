//
//  HeartRateView.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/25/25.
//

import SwiftUI

struct HeartRateView: View {
    @StateObject private var heartRateVM = HeartRateViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("❤️")
                .font(.system(size: 50))

            Text("\(heartRateVM.bpm)")
                .font(.system(size: 60))
                .fontWeight(.medium)

            Text("BPM")
                .foregroundColor(.red)
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    HeartRateView()
}
