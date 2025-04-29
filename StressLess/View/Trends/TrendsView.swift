//
//  TrendsView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//
// medium.com/@wesleymatlock/real-time-graphs-charts-in-swiftui-master-of-data-visualization-460cd03610a3

import SwiftUI
import Charts

struct TrendsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitViewModel
    
    @State private var sessions: [Session] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Trends")
                        .font(.system(size: 40, weight: .bold))
                    
                    Text("Our team here at StressLess constantly monitors our user’s trends to improve our models. This is the data that we track.")
                        .font(.body)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 2)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Acute Stress Moments")
                            .font(.title3)
                            .bold()
                        
                        Text("These are the recorded moments during study sessions that are detected as acute stress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if sessions.isEmpty {
                            Text("No session data available yet.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            Chart {
                                ForEach(sessions) { session in
                                    PointMark(
                                        x: .value("Date", formattedDate(session.sessionDate)),
                                        y: .value("Stress Events", session.stressEvents)
                                    )
                                    .foregroundStyle(Color.purple)
                                    .symbol(Circle())
                                }
                            }
                            .frame(height: 250)
                            .padding()
                            .chartXAxisLabel("Session Date", alignment: .center)
                            .chartYAxisLabel("# of Stress Events", alignment: .center)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                }
                .padding()
            }
            .background(Color.back.ignoresSafeArea())
            .task {
                let allSessions = await healthKitManager.fetchUserSessions()
                let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                self.sessions = allSessions.filter { $0.sessionDate >= sevenDaysAgo }
            }
        }
    }
    
    private func loadPastSessions() async {
        self.sessions = await healthKitManager.fetchUserSessions()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

}

#Preview {
    TrendsView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
