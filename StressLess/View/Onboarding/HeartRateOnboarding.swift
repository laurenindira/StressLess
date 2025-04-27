//
//  HeartRateOnboarding.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct HeartRateOnboarding: View {
    @Binding var user: User
    @Binding var step: Int
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    HeartRateOnboarding(user: .constant(User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0)), step: .constant(1))
}
