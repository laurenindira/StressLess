//
//  OnboardingControl.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct OnboardingControl: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var user: User
    @State private var step: Int = 1
    
    var body: some View {
        VStack {
            if step == 1 {
                NameInputOnboarding(user: $user, step: $step)
            } else if step == 2 {
                DataSourceOnboarding(user: $user, step: $step)
            } else if step == 3 {
                HeartRateOnboarding(user: $user, step: $step)
            } else if step == 4 {
                HRVOnboarding(user: $user, step: $step)
            }
            
            
        }
        .animation(.easeInOut, value: step)
    }
}

#Preview {
    OnboardingControl(user: .constant(User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0)))
}
