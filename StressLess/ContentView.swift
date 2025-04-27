//
//  ContentView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/22/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @AppStorage("isSignedIn") var isSignedIn = false
    
    var body: some View {
        Group {
            if !isSignedIn {
                SplashView()
                //SignUpView(tempUser: User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0))
                    .environmentObject(auth)
            } else {
                TabView {
                    //dashboard
                    //trends
                    //profile
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
