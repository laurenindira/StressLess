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
                        .frame(maxWidth: .infinity)
                    
                    // acute stress moments chart
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
                                ForEach(stressData.indices, id: \.self) { index in
                                    let dataPoint = stressData[index]

                                    PointMark(
                                        x: .value("Date", dataPoint.dateLabel),
                                        y: .value("Stress Events", dataPoint.stressEvents)
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
                    .frame(maxWidth: .infinity)
                    
                    // peak heart rate chart
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Peak Heart Rate")
                            .font(.title3)
                            .bold()

                        Text("These are the recorded maximum heart rates recorded for each day a study session is initiated")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if sessions.isEmpty {
                            Text("No session data available yet.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            Chart {
                                ForEach(heartRateData.indices, id: \.self) { index in
                                    let dataPoint = heartRateData[index]

                                    LineMark(
                                        x: .value("Date", dataPoint.dateLabel),
                                        y: .value("Max HR", dataPoint.maxHR)
                                    )
                                    .foregroundStyle(Color.purple)
                                    .lineStyle(StrokeStyle(lineWidth: 1))

                                    PointMark(
                                        x: .value("Date", dataPoint.dateLabel),
                                        y: .value("Max HR", dataPoint.maxHR)
                                    )
                                    .foregroundStyle(Color.purple)
                                    .symbol(Circle())
                                }
                            }
                            .chartYScale(domain: 100...180)
                            .frame(height: 250)
                            .padding()
                            .chartXAxisLabel("Session Date", alignment: .center)
                            .chartYAxisLabel("Max Heart Rate (BPM)", alignment: .center)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                    .frame(maxWidth: .infinity)
                    
                }
                .padding()
                .frame(maxWidth: .infinity)
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
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
    
    private var stressData: [(dateLabel: String, stressEvents: Int)] {
        sessions.map {
            (dateLabel: formattedDate($0.sessionDate), stressEvents: $0.stressEvents)
        }
    }

    private var heartRateData: [(dateLabel: String, maxHR: Double)] {
        sessions.map {
            (dateLabel: formattedDate($0.sessionDate), maxHR: $0.maxHeartRate)
        }
    }

}

#Preview {
    TrendsView()
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
