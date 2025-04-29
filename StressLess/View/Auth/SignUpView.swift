//
//  SignUpView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State var displayName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var showPassword: Bool = false
    @State var showConfirmPassword: Bool = false
    
    @State private var passwordMessage: String = ""
    @State private var confirmPasswordMessage: String = ""
    
    @State private var passwordValid: Bool = false
    @State private var confirmPasswordValid: Bool = false
    
    var tempUser: User
    
    var showPasswordToggle: Bool {
        get { showPassword }
        set { showPassword = newValue }
    }
    
    var showConfirmPasswordToggle: Bool {
        get { showConfirmPassword }
        set { showConfirmPassword = newValue}
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Spacer()
                
                //LOGO
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 100)
                
                Text("create an account")
                    .font(.title2).bold()
                
                //FIELDS
                VStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("email")
                            .font(.headline)
                            .foregroundStyle(Color.sectext)
                        GenTextField(placeholder: "email", text: $email)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("password")
                            .font(.headline)
                            .foregroundStyle(Color.sectext)
                        SecureTextField(placeholder: "password", showPassword: showPassword, text: $password)
                            .onChange(of: password) { newValue in
                                passwordValid = newValue.count >= 6
                                passwordMessage = passwordValid ? "✓ Password looks good" : "✘ Password must be at least six characters"
                                confirmPasswordValid = (newValue == password)
                                confirmPasswordMessage = newValue.isEmpty ? "" : (confirmPasswordValid ? "✓ Passwords match": "✘ Passwords do not match")
                            }
                        
                        if !password.isEmpty {
                            Text(passwordMessage)
                                .font(.caption)
                                .foregroundStyle(passwordValid ? Color.stressgreen : Color.stressred)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("confirm password")
                            .font(.headline)
                            .foregroundStyle(Color.sectext)
                        SecureTextField(placeholder: "confirm password", showPassword: showConfirmPassword, text: $confirmPassword)
                            .onChange(of: confirmPassword) { newValue in
                                confirmPasswordValid = (newValue == password)
                                confirmPasswordMessage = newValue.isEmpty ? "" : (confirmPasswordValid ? "✓ Passwords match": "✘ Passwords do not match")
                            }
                        
                        if !confirmPassword.isEmpty {
                            Text(confirmPasswordMessage)
                                .font(.caption)
                                .foregroundStyle(confirmPasswordValid ? Color.stressgreen : Color.stressred)
                        }
                    }
                }
                
                Spacer()
                
                //BUTTON
                VStack {
                    Button {
                        Task { await signUpWithEmail() }
                    } label: {
                        GenButton(text: "make my account!", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: false)
                    }
                    .disabled(!formIsValid)
                    
//                    Text("or")
//                    
//                    Button {
//                        //TODO: add Google sign in
//                    } label: {
//                        GenButton(text: "sign up with Google", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: false)
//                    }
//                    
                    HStack {
                        Text("already have an account?")
                        NavigationLink("sign in") { SignInView() }
                            .foregroundStyle(Color.prim)
                            .bold()
                    }
                    .font(.callout)
                }
                
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error making account"), message: Text(auth.errorMessage ?? ""), primaryButton: .default(Text("Try again!")), secondaryButton: .cancel(Text("Cancel")) { dismiss() })
        }
    }
    
    func signUpWithEmail() async {
        do {
            try await auth.signUpWithEmail(newUser: tempUser, email: email, password: password)
        } catch {
            showAlert = true
        }
    }
    
    func signUpWithGoogle() {
        //TODO: add google sign up
    }
}

extension SignUpView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && email.contains(".") && !password.isEmpty && password.count >= 6 && password == confirmPassword
    }
}

#Preview {
    SignUpView(tempUser: User(id: "", displayName: "", email: "", providerRef: "password", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0))
        .environmentObject(AuthViewModel())
}
