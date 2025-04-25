//
//  HeartRateView.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/25/25.
//
// medium.com/display-and-use-heart-rate-with-healthkit-on/display-and-use-heart-rate-with-healthkit-on-swiftui-for-watchos-2b26e29dc566

import SwiftUI

struct HeartRateCard: View {
    @StateObject private var heartRateVM = HeartRateViewModel()
    
    var bpm: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resting\nHeart\nRate")
                .font(.headline)
                .foregroundColor(.black)

            HStack {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(.black)

                Text("\(bpm) bpm")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.black)
            }
        }
        .padding()
        .frame(width: 165, height: 165)
        .background(Color(red: 1.0, green: 0.94, blue: 0.94))
        .cornerRadius(20)
    }
}

#Preview {
    HeartRateCard(bpm: 234)
}
