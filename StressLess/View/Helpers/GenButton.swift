//
//  GenButton.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct GenButton: View {
    var text: String
    var backgroundColor: Color
    var textColor: Color
    var isSystemImage: Bool
    var imageRight: String?
    var imageLeft: String?
    
    var body: some View {
        HStack (alignment: .center) {
            if imageLeft != nil {
                if isSystemImage {
                    Image(systemName: imageLeft ?? "")
                        .font(.title3)
                } else {
                    Image(imageLeft ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                }
            }
            
            Text(text)
                .font(.headline)
            
            if imageRight != nil {
                if isSystemImage {
                    Image(systemName: imageRight ?? "")
                        .font(.title3)
                } else {
                    Image(imageRight ?? "")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                }
            }
        }
        .foregroundStyle(textColor)
        .padding()
        .frame(maxWidth: UIScreen.main.bounds.width)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
        }
    }
}

#Preview {
    GenButton(text: "submit", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: true, imageRight: "paperplane")
}
