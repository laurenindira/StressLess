//
//  SettingsView.swift
//  StressLess
//
//  Created by Lauren Indira on 4/27/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @AppStorage("notificationsOn") private var notificationsOn: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                //HEADER
                Text("Settings")
                    .font(.system(size: 35))
                    .bold()
                
                //NOTIFICATIONS
                VStack(alignment: .leading) {
                    Text("Notifications")
                        .font(.system(size: 25))
                        .bold()
                    Toggle(isOn: $notificationsOn) {
                        Text("Disable/Enable Notifications")
                    }
                    .onChange(of: notificationsOn) { _, newValue in
                        if newValue {
                            NotificationManager.requestNotificationAuthorization()
                        } else {
                            NotificationManager.cancelNotification()
                        }
                    }
                }
                
                Divider()
                
                //HEALTH DATA
                VStack(alignment: .leading, spacing: 20) {
                    Text("Health Data")
                        .font(.system(size: 25))
                        .bold()
                    Button {
                        //TODO: trigger alert
                    } label: {
                        Text("Delete my data")
                            .foregroundStyle(Color.stressred)
                    }
                }
                
                Divider()
                
                //ACCOUNT MANAGEMENT
                VStack(alignment: .leading, spacing: 20) {
                    Text("Account Management")
                        .font(.system(size: 25))
                        .bold()
                    Button("Log out") {
                        Task { await auth.signOut() }
                    }
                    Button {
                        //TODO: trigger delete account
                    } label: {
                        Text("Delete my account")
                            .foregroundStyle(Color.stressred)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
