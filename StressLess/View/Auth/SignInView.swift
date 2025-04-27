//
//  SignInView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State var email: String = ""
    @State var password: String = ""
    @State var showPassword: Bool = false
    
    @State private var tempUser = User(id: "", displayName: "", email: "", profilePicture: "", providerRef: "", creationDate: Date(), dataSource: "", goals: [], totalSessions: 0, averageHeartRate: 0.0, averageHRV: 0.0, lastSession: Date())
    
    var showPasswordToggle: Bool {
        get { showPassword }
        set { showPassword = newValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                
                Text("Sign into your account")
                    .font(.headline).bold()
                
                //FIELDS
                VStack(alignment: .leading, spacing: 10) {
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
                    }
                }
                .padding(.bottom, 20)
                
                //BUTTON
                Button {
                    Task { await emailSignIn() }
                } label: {
                    GenButton(text: "sign in", backgroundColor: formIsValid ? Color.prim : Color.prim.opacity(0.5), textColor: Color.lod, isSystemImage: false)
                }
                
                HStack {
                    Text("Don't have an account yet?")
                    
                    NavigationLink("Sign up!") {
                        OnboardingControl(user: $tempUser)
                    }
                    .bold()
                }
                
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.back
                    .ignoresSafeArea()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error signing in"), message: Text(auth.errorMessage ?? ""), primaryButton: .default(Text("Try again")), secondaryButton: .cancel(Text("Go back")) { dismiss() })
        }
    }
    
    func emailSignIn() async {
        do {
            try await auth.signInWithEmail(email: email, password: password)
        } catch {
            showAlert = true
        }
    }
}

extension SignInView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && email.contains(".") && !password.isEmpty
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}
