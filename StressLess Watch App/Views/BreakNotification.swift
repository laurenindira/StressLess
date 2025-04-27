//
//  BreakNotification.swift
//  StressLess Watch App
//
//  Created by Raihana Zahra on 4/25/25.
//

import SwiftUI

struct BreakNotification: View {
    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Spacer()
                
                Text("It’s time for a\nbreak!")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(12)
                    .frame(width: 160, height: 60)
                
                Button(action: {
                    // TODO: skip break when over threshold
                }) {
                    Text("Skip Break")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                }
                
                Spacer()
                
            }
            .padding()
        }
        .background(Color.background)
    }
}

#Preview {
    BreakNotification()
}
