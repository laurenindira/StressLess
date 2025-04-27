//
//  SplashView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var tempUser = User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0)
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 120)
                
                Spacer()
                
                NavigationLink {
                    OnboardingControl(user: $tempUser)
                } label: {
                    GenButton(text: "get started!", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: true, imageRight: "chevron.right")
                }
                
                HStack {
                    Text("Already have an account?")
                        .font(.callout)
                    NavigationLink("Sign in!") { SignInView() }
                        .foregroundStyle(Color.prim)
                        .font(.headline)
                }
            }
            .padding()
            .background(Color.back)
        }
    }
}

#Preview {
    SplashView()
}
