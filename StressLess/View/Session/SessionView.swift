//
//  SessionView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var sessionManager: HealthKitViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                //HEADER
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hey \(auth.user?.displayName ?? "friend"),")
                        .bold()
                        .font(.system(size: 40))
                    Text("Welcome to your session!")
                        .font(.title2)
                        .font(.system(size: 35))
                        .padding(.bottom, 20)
                }
                
                //CONTROLS
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Controls")
                            .bold()
                            .font(.system(size: 30))
                        
                        //Start/stop button
                        if sessionManager.isSessionActive {
                            Button {
                                Task { await sessionManager.endSession() }
                            } label: {
                                GenButton(text: "End Session", backgroundColor: Color.stressred, textColor: Color.lod, isSystemImage: false)
                            }
                        } else {
                            Button {
                                sessionManager.startSession()
                            } label: {
                                GenButton(text: "Start Session", backgroundColor: Color.stressgreen, textColor: Color.lod, isSystemImage: false)
                            }
                        }
                    }
                    
                    VStack(alignment: .center) {
                        Text("Session Duration: \(formatTime(sessionManager.sessionDuration))")
                            .font(.title2).bold()
                    }
                    
                    
                    VStack(alignment: .center) {
                        HStack {
                            SquareWidget(mainText: "Resting Heart Rate", icon: "heart.fill", value: String(format: "%.0f", sessionManager.sessionHeartRate), measurement: "bpm", space: UIScreen.main.bounds.width, divider: 2.25, background: Color.stressorange)
                            SquareWidget(mainText: "Heart Rate Variability", icon: "heart.fill", value: String(format: "%.0f", sessionManager.sessionhrv), measurement: "ms", space: UIScreen.main.bounds.width, divider: 2.25, background: Color.stresspink)
                        }
                    }
                }
                .padding(.vertical, 20)
                .background {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .padding(.horizontal, -15)
                    
                        .shadow(color: Color.prim.opacity(0.25), radius: 3, y: -2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.back
                    .ignoresSafeArea()
            }
        }
        .alert(isPresented: $sessionManager.triggerStress) {
            Alert(title: Text("Time for a breather"), message: Text("We've noticed a spike in your stress levels. Try taking a deep breath, or a short break"), dismissButton: .default(Text("I'm good now!")) { sessionManager.triggerStress = false } )
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds)/60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

#Preview {
    SessionView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
