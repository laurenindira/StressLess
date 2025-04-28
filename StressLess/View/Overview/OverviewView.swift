//
//  OverviewView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct OverviewView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                //HEADER
                VStack(alignment: .leading, spacing: 10) {
                    Text("Hey \(auth.user?.displayName ?? "friend"),")
                        .bold()
                        .font(.system(size: 40))
                    Text("Ready to start your next session?")
                        .font(.title2)
                        .font(.system(size: 35))
                        .padding(.bottom, 20)
                    
                    HStack {
                        Spacer()
                        NavigationLink {
                            SessionView()
                        } label: {
                            Text("Let's go!")
                                .font(.title3).bold()
                                .padding()
                                .foregroundStyle(Color.lod)
                                .background {
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.prim)
                                }
                        }
                    }
                }
                
                //WIDGET THINGS
                VStack(alignment: .leading, spacing: 20) {
                    Text("Daily Overview")
                        .font(.system(size: 30))
                        .bold()
                    HStack (spacing: 20) {
                        SquareWidget(mainText: "Resting Heart Rate", icon: "heart.fill", value: String(describing: auth.user?.averageHeartRate ?? 0) , measurement: "bpm", space: UIScreen.main.bounds.width, divider: 2.25, background: Color.stressorange)
                        SquareWidget(mainText: "Last Study Session", icon: "calendar", value: dateFormatter.string(from:  auth.user?.lastSession ?? Date()) , space: UIScreen.main.bounds.width, divider: 2.25, background: Color.stressyellow)
                    }
                    
                    HStack (spacing: 20) {
                        SquareWidget(mainText: "Heart Rate Variability", icon: "heart.fill", value: String(describing: auth.user?.averageHRV ?? 0) , measurement: "ms", space: UIScreen.main.bounds.width, divider: 2.25, background: Color.stresspink)
                        NavigationLink {
                            //TODO: add nav link to quiz
                        } label: {
                            SquareWidget(mainText: "Assess your stress levels", icon: "arrow.right.circle", value: "", space: UIScreen.main.bounds.width, divider: 2.25, background: Color.stresspurple)

                        }
                        .buttonStyle(.plain)
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
    OverviewView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
