//
//  GenTextField.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct GenTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding()
            .foregroundStyle(Color.sectext)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.surface)
                    .stroke(Color.sec.opacity(0.2), style: StrokeStyle(lineWidth:  0.25))
            }
    }
}

#Preview {
    GenTextField(placeholder: "placeholder", text: .constant(""))
}
