//
//  SquareWidget.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct SquareWidget: View {
    var mainText: String
    var icon: String
    var value: String
    var measurement: String?
    var space: CGFloat
    var divider: Double
    var background: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            Text(mainText)
                .font(.system(size: 24))
                .bold()
            
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 35))
                    .padding(.trailing, 10)
                Text(value)
                    .font(.system(size: 24))
                Text(measurement ?? "")
                    .font(.system(size: 16))
            }
        }
        .padding()
        .frame(maxWidth: space/CGFloat(divider), minHeight: space/CGFloat(divider), maxHeight: space/CGFloat(divider))
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(background)
                .shadow(color: Color.prim.opacity(0.5), radius: 2, x: 1, y: 1)
        }
        
    }
}

#Preview {
    SquareWidget(mainText: "Resting Heart Rate", icon: "heart.fill", value: "XX", measurement: "bpm", space: UIScreen.main.bounds.width, divider: 2.0, background: Color.stressorange)
}
