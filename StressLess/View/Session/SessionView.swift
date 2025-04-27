//
//  SessionView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State var sessionOngoing: Bool
    @State var sessionTime: Int
    
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
                VStack(alignment: .leading) {
                    Text("Controls")
                        .bold()
                    .font(.system(size: 30))
                    
                    //TODO: add button once this session thing is figured out
                    
                    HStack {
                        SquareWidget(mainText: "Resting Heart Rate", icon: "heart.fill", value: String(describing: auth.user?.averageHeartRate ?? 0) , measurement: "bpm", space: UIScreen.main.bounds.width, divider: 2.25, background: Color.stressorange)
                        SquareWidget(mainText: "Heart Rate Variability", icon: "heart.fill", value: String(describing: auth.user?.averageHRV ?? 0) , measurement: "ms", space: UIScreen.main.bounds.width, divider: 2.25, background: Color.stresspink)
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
    }
}

#Preview {
    SessionView(sessionOngoing: true, sessionTime: 688)
        .environmentObject(AuthViewModel())
}
