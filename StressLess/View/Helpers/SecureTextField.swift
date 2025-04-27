//
//  SecureTextField.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct SecureTextField: View {
    var placeholder: String
    @State var showPassword: Bool
    @Binding var text: String
    
    var body: some View {
        if showPassword {
            GenTextField(placeholder: placeholder, text: $text)
                .textContentType(.password)
                .overlay(alignment: .trailing) {
                    Button(role: .cancel) {
                        withAnimation(.easeIn) {
                            showPassword = false
                        }
                    } label: {
                        Image(systemName: "eye")
                            .foregroundStyle(Color.prim)
                            .padding()
                            .contentTransition(.symbolEffect)
                    }
                }
        } else {
            SecureField(placeholder, text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .foregroundStyle(Color.sectext)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.surface)
                        .stroke(Color.sec.opacity(0.2), style: StrokeStyle(lineWidth:  0.25))
                }
                .overlay(alignment: .trailing) {
                    Button(role: .cancel) {
                        withAnimation(.easeIn) {
                            showPassword = true
                        }
                    } label: {
                        Image(systemName: "eye.slash")
                            .foregroundStyle(Color.prim)
                            .padding()
                            .contentTransition(.symbolEffect)
                    }
                }
        }
    }
}

#Preview {
    SecureTextField(placeholder: "password", showPassword: true, text: .constant("some other text"))
}
