//
//  HealthKitOnboarding.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct HealthKitOnboarding: View {
    @Binding var user: User
    @Binding var step: Int
    
    @StateObject var healthKitManager = HealthKitViewModel()
    @State var healthKitEnabled: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("HealthKit Authorization")
                .font(.headline)
            
            Text("StressLess uses HealthKit data as well as real-time heart rate monitoring to make stress predictions. Press the button below to grant us permission to use this data.")
                .font(.body) 
            
            Button {
                Task {
                    await triggerHealthKit()
                    healthKitEnabled = true
                }
            } label: {
                GenButton(text: "Authorize HealthKit", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: false)
            }
            
            NavigationLink {
                if healthKitEnabled { SignUpView(tempUser: user) }
            } label: {
                GenButton(text: "Next", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: true,  imageRight: "arrow.right")
            }
            .disabled(!healthKitEnabled)
            .opacity(healthKitEnabled ? 1 : 0.5)
            .padding(.top, 20)
            
        }
        .padding()
    }
    
    func triggerHealthKit() async {
        do {
            healthKitManager.requestAuthorization()
            user.averageHeartRate = try await healthKitManager.fetchRestingHeartRate() ?? 0.0
            user.averageHRV = try await healthKitManager.fetchHeartRateVariability() ?? 0.0
            print("SUCCESS: Authorized and fetched heart rate and HRV")
        } catch {
            print("ERROR: Could not perform all HealthKit functions")
        }
    }
}

#Preview {
    HealthKitOnboarding(user: .constant(User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0)), step: .constant(3))
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
