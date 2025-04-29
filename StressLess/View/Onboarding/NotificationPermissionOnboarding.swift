//
//  NotificationPermission.swift
//  StressLess
//
//  Created by Lauren Indira on 4/29/25.
//

import SwiftUI

struct NotificationPermissionOnboarding: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var healthKitManager: HealthKitViewModel
    
    @Binding var user: User
    @Binding var step: Int
    
    @State var notificationsEnabled: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Notification Authorization")
                .font(.headline)
            
            Text("StressLess sends you real-time notifications when it detects instances of acute stress. The app works best if you accept our notifications. We promise not to bother you too much.")
                .font(.body)
            
            Button {
                Task {
                    NotificationManager.requestNotificationAuthorization()
                    notificationsEnabled = true
                }
            } label: {
                GenButton(text: "Authorize Notifications", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: false)
            }
            
            Button {
                if notificationsEnabled { step += 1 }
            } label: {
                GenButton(text: "Next", backgroundColor: Color.prim, textColor: Color.lod, isSystemImage: true,  imageRight: "arrow.right")
            }
            .disabled(!notificationsEnabled)
            .opacity(notificationsEnabled ? 1 : 0.5)
            .padding(.top, 20)
            
        }
        .padding()
        .navigationBarBackButtonHidden()
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button() {
//                    step -= 1
//                } label: {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                            .font(.body)
//                        Text("Back")
//                    }
//                    .foregroundStyle(Color.prim)
//                }
//            }
//        }
    }
}

#Preview {
    NotificationPermissionOnboarding(user: .constant(User(id: "", displayName: "", email: "", providerRef: "", creationDate: Date(), goals: [], totalSessions: 0, averageHeartRate: 0, averageHRV: 0)), step: .constant(1))
        .environmentObject(AuthViewModel())
        .environmentObject(HealthKitViewModel())
}
