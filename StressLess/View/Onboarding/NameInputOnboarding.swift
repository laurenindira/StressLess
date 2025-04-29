//
//  NameInputOnboarding.swift
//  StressLess
//
//  Created by Lauren Indira on 4/26/25.
//

import SwiftUI

struct NameInputOnboarding: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitViewModel
    
    @Binding var user: User
    @Binding var step: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("So, what do you want us to call you?")
                .font(.headline)
            
            GenTextField(placeholder: "enter your name", text: $user.displayName)
            
            Button {
                if !user.displayName.isEmpty { step += 1 }
            } label: {
                GenButton(text: "Next", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: true,  imageRight: "arrow.right")
            }
            .disabled(user.displayName.isEmpty)
            .opacity((user.displayName == "") ? 0.5 : 1)
            .padding(.top, 20)
            
        }
        .padding()
    }
}

#Preview {
    NameInputOnboarding(user: .constant(User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0)), step: .constant(1))
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
