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
                    .environmentObject(auth)
            } else {
                TabView {
                    OverviewView()
                        .environmentObject(auth)
                        .tabItem {
                            Label("Overview", systemImage: "square.grid.2x2")
                        }
                    
                    TrendsView()
                        .environmentObject(auth)
                        .tabItem {
                            Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                        }
                    
                    ProfileView()
                        .environmentObject(auth)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
