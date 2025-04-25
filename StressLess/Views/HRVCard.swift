//
//  HRVCard.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/25/25.
//

import SwiftUI

struct HRVCard: View {
    @StateObject private var heartRateVM = HeartRateViewModel()
    
    var hrv: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Heart\nRate\nVariability")
                .font(.headline)
                .foregroundColor(.black)

            HStack {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(.black)

                Text(String(format: "%.0f ms", hrv))
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(width: 165, height: 165)
        .background(Color.stresspink)
        .cornerRadius(20)
    }
}

#Preview {
    HRVCard(hrv: 3.1)
}
