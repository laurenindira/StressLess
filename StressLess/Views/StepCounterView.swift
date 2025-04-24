//
//  StepCounterView.swift
//  StressLess
//
//  Created by Raihana Zahra on 4/24/25.
//

import SwiftUI

struct StepCounterView: View {
    @StateObject var healthKitManager = HealthKitManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Today's Steps")
                .font(.title2)

            Text("\(healthKitManager.stepCountToday)")
                .font(.largeTitle)
                .bold()

            Divider()

            Text("This Week")
                .font(.headline)

            ForEach(1..<8, id: \.self) { day in
                Text("Day \(day): \(healthKitManager.thisWeekSteps[day] ?? 0) steps")
            }
        }
        .padding()
    }
}

#Preview {
    StepCounterView()
}
